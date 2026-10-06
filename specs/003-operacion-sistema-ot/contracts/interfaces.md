# Interface Contracts — Spec 003

**Status**: design contract; no endpoint, RPC or component is implemented by this artifact.

## General rules

- Browser sends the Supabase access token and publishable key only.
- Actor, role and sector are never accepted as authoritative parameters; server derives them from
  `auth.uid()` and `perfil_usuario`.
- IDs are opaque physical references. Business rules use stable codes.
- Timestamps used as facts are assigned by server.
- Success responses return the resulting canonical record or cursor needed to refresh.
- Errors use stable functional codes and safe messages; SQL, stack traces, tokens and secrets are not
  returned.

## Access matrix

| Capability | Interface | Protection |
|---|---|---|
| Login/logout/session | Supabase Auth client | Auth configuration; no public sign-up |
| Password recovery | Supabase Auth client | uniform response; configured redirects/SMTP |
| Create/manage Auth user | Edge Function `admin-users` | JWT + active ADMINISTRADOR + secret server-side |
| Read OT list/current situation | direct SELECT on security-invoker view | RLS by admin/current sector |
| Read OT detail/children/route | direct SELECT or read RPC | RLS inherited from visible OT |
| Read active masters | direct SELECT | authenticated; frontend filters Active |
| Read historical inactive labels | authorized joins/read contract | same visibility as historical OT |
| Mutate simple masters | direct INSERT/UPDATE | ADMINISTRADOR RLS + audit trigger; no normal DELETE |
| Save material/gramajes | RPC | ADMINISTRADOR; cross-table transaction |
| Reorder sectors | RPC | ADMINISTRADOR; cross-row transaction |
| Create/update OT aggregate | RPC | ADMINISTRADOR; transaction + audit |
| Move/finalize/annul/delete OT | RPC | state/role/sector validation + row lock |
| Read audit | direct paginated SELECT | ADMINISTRADOR only |
| Mutate audit or past movement | none | denied by grants/RLS |

## Auth contracts

### Sign in

Input: `email`, `password`. Output: valid Auth session, then active business profile with role and
sector. A missing/inactive profile ends application access even if Auth issued a token.

### Password recovery

Input: email and approved redirect URL. Response is intentionally uniform whether the account
exists. The update route requires a valid recovery session before accepting the new password.

### `admin-users` Edge Function

Operations: invite user, change business role/sector, activate/inactivate profile, resend invitation
when supported. It does not expose Auth Admin responses verbatim.

Invite request: email, business role code, optional sector code. Invite result: Auth UUID, profile ID
and status. Retry by same email/UUID resumes an incomplete operation instead of creating another
identity. If profile creation fails after a new invite, the function compensates or reports a
recoverable partial state for an administrator.

## Read contracts

### OT list

Inputs:

- cursor `{fecha_ot, id}` optional;
- page size bounded by server configuration;
- optional search text and filters: state code, sector code, client ID, responsible ID, date range;
- stable sort `fecha_ot DESC, id DESC`.

Output: rows with código, cliente, nombre trabajo, fecha, estado, sector actual and responsible
actual plus `next_cursor`. No exact total is required. USUARIO receives only its current sector;
ADMINISTRADOR receives all matching rows.

### OT detail and route

Output combines header, zero to three ordered floors, finishes, canonical state, current
sector/responsible and ordered movements. Each movement exposes origin, destination, responsible,
actor, type and time. Durations are derived; a repeated visit remains a distinct interval. The last
interval ends at the query time while in progress, at `terminado_en` when TERMINADO or at
`anulado_en` when ANULADO.

### Audit list/detail

ADMINISTRADOR may page/filter events by entity, record key, operation, actor and time. Event detail
returns attribute, previous JSON value and new JSON value. No mutation interface exists.

## Write RPC contracts

Names are stable conceptual names; signatures are fixed during migration implementation without
changing these semantics.

### `crear_ot`

Input: technical `idempotencia_creacion` UUID stable for the logical attempt, header, floors array
length 0..3 and finishes array. The key is operation metadata, not a visible business field. The
request does not accept ID, code, state, actor, trusted timestamps or current sector. Server validates
Active client/catalog values, assigns code and PENDIENTE, diffs no prior state and writes audit
atomically.

The server enforces uniqueness of `idempotencia_creacion`. Repeating exactly the same request with
the same key returns the canonical result already processed and does not insert another OT, floor,
finish or audit effect. Reusing a key with different content returns a controlled conflict rather
than mutating the prior OT.

Output: OT ID, code, canonical aggregate and `modificado_en` token. The UI disables duplicate submit
as feedback, but server/database idempotency is authoritative. After an ambiguous network result the
client may repeat only the same request with the same stable key and must use the canonical response.

### `actualizar_ot`

Input: OT ID, expected `modificado_en`, canonical header/floors/finishes, and confirmation of an
exceptional administrative correction when state is terminal. It does not accept a new state or
actor.

Server locks OT, checks ADMINISTRADOR and state policy, computes a diff, validates the final
aggregate, updates parent timestamp and audits only effective changes. Conflict returns current
token/state without overwriting. TERMINADO/ANULADO keep their state and create no movement.

### `mover_ot`

Input: OT ID, destination sector ID/code, destination responsible ID and
`expected_last_movement_id` (NULL only before INICIO). No origin, actor, type, timestamp or reason.

Server locks OT and validates:

1. active profile and allowed role;
2. PENDIENTE only for ADMINISTRADOR on INICIO, otherwise EN_PROCESO;
3. expected movement still current;
4. USUARIO belongs to current sector;
5. destination Active, participates in flow, is not current and is not ALMACEN;
6. responsible Active and belongs to destination;
7. matrix for normal USUARIO, or explicit administrative correction privilege.

Server derives origin and INICIO/AVANCE/DEVOLUCION, inserts one append-only row and changes PENDIENTE
to EN_PROCESO in the same transaction. A stale retry returns `CONFLICT_REFRESH_REQUIRED` and no row.

### `finalizar_ot`

Input: OT ID and expected last movement ID. Server requires EN_PROCESO, current sector PRODUCCION,
and either its USUARIO or ADMINISTRADOR. It sets TERMINADO/`terminado_en`, audits and inserts no
movement. State and server timestamp are written atomically. Repeating against an already identical
terminal result returns canonical success without a second effect; any different state is conflict.

### `anular_ot`

Input: OT ID and expected `modificado_en`/last movement. No reason. ADMINISTRADOR only; state must be
PENDIENTE or EN_PROCESO. Server sets ANULADO and server-generated `anulado_en` atomically, audits and
creates no product movement. When a productive interval is open, `anulado_en` closes that last
interval; a retry against the same canonical terminal result returns success without a second effect.

### `eliminar_ot`

Input: OT ID and expected `modificado_en`, with explicit UI confirmation. ADMINISTRADOR only. Server
locks and requires PENDIENTE plus zero movements, audits DELETE, deletes children/finishes and then
the OT. Retry after confirmed deletion returns an already-absent result without recreating effects.

### Administrative configuration RPC

- `guardar_material_configuracion`: saves material and its gramajes in one transaction and enforces
  the type requirement.
- `reordenar_sectores`: validates positive unique orders and keeps ALMACEN out of the flow.
- profile mutation invoked by `admin-users`: validates role/sector and serializes the rule of one
  active USUARIO per sector.

## Functional error taxonomy

| Code | Meaning | Client behavior |
|---|---|---|
| `AUTH_REQUIRED` | no valid session | preserve safe draft context and reauthenticate |
| `PROFILE_INACTIVE` | Auth valid, business access inactive | end protected operation |
| `FORBIDDEN_ROLE` | role lacks capability | show safe denial; do not retry |
| `WRONG_CURRENT_SECTOR` | USUARIO does not own current stage | refresh list/detail |
| `INVALID_STATE_TRANSITION` | operation not valid for state | refresh and explain |
| `INVALID_DESTINATION` | inactive/non-flow/disallowed/same destination | keep form and correct |
| `INVALID_RESPONSIBLE` | inactive or wrong sector | select another responsible |
| `VALIDATION_FAILED` | aggregate violates field/domain rules | map errors to fields |
| `CONFLICT_REFRESH_REQUIRED` | optimistic/last-movement precondition stale | fetch canonical state |
| `RESULT_UNKNOWN` | connectivity lost before confirmation | verify; never blind retry |
| `NOT_FOUND` | record absent or invisible | return to authorized list |
| `UNEXPECTED` | safe unexpected failure | show correlation ID; no internals |

## Session and retry behavior

- A pending action disables its trigger control locally, but database preconditions are the actual
  duplicate protection.
- If the session expires before commit, no ambiguous success is claimed. Refresh/re-authenticate and
  query canonical state before retry.
- Network retry policy is read-only automatic. Creation may be repeated only with the same stable
  `idempotencia_creacion` and identical content; other writes are never blindly repeated and rely on
  their expected state, locks and preconditions.
- Correlation IDs are diagnostic only and are not accepted as business identity or audit actor.

## Browser/UI boundaries

Presentation may hide unavailable actions for clarity, but the server always revalidates. The OT
form may derive floor number from array order and show conditional position/dimension fields; the
request contract still sends explicit normalized values and the database remains authoritative.
