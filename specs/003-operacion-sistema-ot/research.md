# Phase 0 Research — Spec 003

**Fecha**: 2026-10-06  
**Estado**: COMPLETADA — sin incógnitas técnicas bloqueantes

## 1. Runtime y dependencias frontend

**Decision**: React 19 estable con Vite estable compatible, JavaScript y npm sobre Node.js 22.12+ LTS.
React Router se usa solo para rutas declarativas. Las versiones exactas se fijan al implementar y el
lockfile se versiona.

**Rationale**: respeta Spec 000, funciona en Windows/PowerShell y evita canales experimentales. Vite
requiere una versión moderna de Node; npm reduce herramientas adicionales.

**Alternatives considered**: TypeScript, Next.js/SSR, React canary y otro gestor de paquetes se
descartan porque no están aprobados o no aportan valor al MVP.

Fuentes: [React versions](https://react.dev/versions), [Vite releases](https://vite.dev/releases),
[Vite guide](https://vite.dev/guide/).

## 2. Arquitectura frontend y estado

**Decision**: SPA organizada por features. Context global solo para sesión/perfil y avisos; filtros,
paginación y formularios permanecen locales. El formulario OT usa `useReducer` y validadores puros.
No Redux, TanStack Query ni librería de formularios en el MVP.

**Rationale**: nueve áreas funcionales justifican rutas y módulos, pero la escala no exige un gestor
global pesado. Los servicios encapsulan Supabase para impedir consultas dispersas en componentes.

**Alternatives considered**: estructura global por `components/services/models`, Redux y React Hook
Form se reconsiderarán únicamente si aparecen duplicación o invalidaciones medibles.

Fuentes: [Managing state](https://react.dev/learn/managing-state),
[Sharing state](https://react.dev/learn/sharing-state-between-components).

## 3. Cliente Supabase y claves

**Decision**: un singleton `supabase-js` v2 usa URL pública y clave `sb_publishable_*`. Cualquier
clave `sb_secret_*` o legacy `service_role` permanece solo en Edge Function/infraestructura segura.
RLS y grants explícitos protegen la Data API.

**Rationale**: Supabase depreca `anon`/`service_role` hacia fines de 2026. Todo `VITE_*` llega al
bundle, por lo que solo admite valores públicos.

**Alternatives considered**: secreto en Vercel frontend es inseguro; un proxy/backend propio es
innecesario.

Fuentes: [API keys](https://supabase.com/docs/guides/getting-started/api-keys),
[migración de claves](https://supabase.com/docs/guides/getting-started/migrating-to-new-api-keys),
[Vite env](https://vite.dev/guide/env-and-mode).

## 4. Auth, recuperación y sesión

**Decision**: `signInWithPassword`, registro público/anonymous sign-in deshabilitados,
`resetPasswordForEmail` con URLs permitidas y SMTP productivo. `persistSession` y `autoRefreshToken`
mantienen la sesión mientras sea renovable; logout, revocación o perfil inactivo impiden operar.

**Rationale**: cumple Spec 003 y la continuidad de Spec 001. Verificar `perfil_usuario.estado` en
cada operación crítica cubre la ventana en que un JWT emitido aún no expiró.

**Alternatives considered**: timeouts cortos forzosos contradicen la experiencia aprobada; cookies
HTTP-only/SSR no corresponden a una SPA rica.

Fuentes: [Password Auth](https://supabase.com/docs/guides/auth/passwords),
[Sessions](https://supabase.com/docs/guides/auth/sessions),
[Auth configuration](https://supabase.com/docs/guides/auth/general-configuration).

## 5. Administración de cuentas

**Decision**: una Edge Function `admin-users` valida JWT y perfil ADMINISTRADOR, usa Auth Admin para
invitar por correo y después crea/actualiza el perfil con el contexto del actor. Si falla la segunda
etapa, compensa la identidad nueva o reanuda por UUID/correo.

**Rationale**: Auth Admin exige secreto servidor y Auth/perfil no pueden compartir una transacción.
La invitación evita que el administrador conozca contraseñas temporales.

**Alternatives considered**: Dashboard no satisface la administración funcional; insertar en
`auth.users` no está soportado; backend tradicional agrega complejidad.

Fuentes: [Inviting users](https://supabase.com/docs/guides/auth/users#inviting-users),
[Auth in Edge Functions](https://supabase.com/docs/guides/functions/auth).

## 6. Esquema físico y claves

**Decision**: identities `integer` para entidades ordinarias y `bigint` para movimiento/auditoría;
texto sin límites arbitrarios, boolean para estado, `timestamptz` para hechos y `numeric` exacto para
dimensiones/gramajes. FKs se indexan y usan RESTRICT salvo dependencias OT eliminables.

**Rationale**: refleja tipos lógicos de Spec 002, preserva historia y favorece joins/cascadas
controladas.

**Alternatives considered**: UUID aleatorio agrega tamaño/fragmentación sin distribución real;
`varchar(n)` y float no aportan integridad.

Fuentes: [Identity columns](https://www.postgresql.org/docs/current/ddl-identity-columns.html),
[Data types](https://www.postgresql.org/docs/current/datatype.html).

## 7. Correlativo de OT

**Decision**: secuencia PostgreSQL dedicada convertida a `codigo_ot text`, UNIQUE y no editable. No
se define prefijo ni relleno no aprobado. Se aceptan huecos transaccionales. Una importación futura
puede insertar códigos explícitos y adelantar la secuencia.

**Rationale**: `MAX()+1` compite bajo concurrencia. PK y código visible cumplen propósitos distintos
sin duplicar dos códigos empresariales.

**Alternatives considered**: usar `id` como código impide preservar códigos históricos; tabla de
correlativos agregaría una entidad innecesaria.

Fuente: [Sequence functions](https://www.postgresql.org/docs/current/functions-sequence.html).

## 8. Integridad de agregados y reglas cruzadas

**Decision**: CHECK/FK/UNIQUE para reglas de fila; RPC y triggers diferibles para pisos consecutivos,
grupos de parámetros, material–gramaje, rol–sector y posición de acabados. La creación/edición de OT
procesa el agregado completo en una transacción.

**Rationale**: PostgreSQL no garantiza reglas entre tablas mediante CHECK. La doble capa RPC/trigger
protege rutas normales y privilegiadas.

**Alternatives considered**: validación solo React viola la Constitution; añadir gramaje al piso o
columnas auxiliares contradice Spec 002.

Fuente: [PostgreSQL constraints](https://www.postgresql.org/docs/current/ddl-constraints.html).

## 9. RLS, vistas y funciones

**Decision**: RLS en toda tabla expuesta, sin acceso de negocio `anon`; helpers privados resuelven
perfil/rol/sector. Vistas usan `security_invoker`. Funciones son invoker por defecto; los núcleos
definer imprescindibles viven fuera de esquemas expuestos, con `search_path=''`, actor derivado,
grants mínimos y ejecución revocada por defecto.

**Rationale**: reduce BOLA/IDOR, recursión RLS y escalamiento de privilegios. Una clave pública no
reemplaza autorización.

**Alternatives considered**: filtros React, claims de `user_metadata` o definer expuesto se descartan
por inseguridad; políticas con joins repetidos se sustituyen por helpers pequeños e indexados.

Fuentes: [RLS](https://supabase.com/docs/guides/database/postgres/row-level-security),
[Database functions](https://supabase.com/docs/guides/database/functions),
[Securing Data API](https://supabase.com/docs/guides/api/securing-your-api).

## 10. Movimiento, estados y concurrencia

**Decision**: RPC transaccional bloquea la OT, valida actor/estado/sector/destino/responsable, deriva
origen/tipo/timestamp y actualiza estado junto con el movimiento. Usa precondición del último
movimiento. Finalizar, anular, editar y eliminar comparten el mismo orden de bloqueo.

**Rationale**: evita estado parcial, doble clic y carreras. La matriz inicial coincide con comparar
el orden de los sectores participantes; ADMINISTRADOR conserva una ruta explícita de corrección.

**Alternatives considered**: varios requests desde frontend y advisory lock aislado no protegen el
agregado ni un reintento posterior.

Fuentes: [Row locks](https://www.postgresql.org/docs/current/explicit-locking.html),
[Transactions](https://www.postgresql.org/docs/current/tutorial-transactions.html).

## 11. Sector actual y paginación

**Decision**: vista normal con último movimiento ordenado por `(ocurrido_en, id)`; índice por OT y
orden descendente. Listados con cursor `(fecha_ot, id)`, filtros en servidor y sin OFFSET profundo.

**Rationale**: mantiene una sola fuente de verdad y rendimiento estable. 19.000 OT no justifican
materialización/denormalización prematura.

**Alternatives considered**: columnas actuales duplicadas contradicen Spec 002; vista materializada
exige sincronización adicional.

Fuentes: [Views](https://supabase.com/docs/guides/database/views),
[Pagination](https://supabase.com/docs/guides/database/pagination).

## 12. Auditoría

**Decision**: trigger genérico endurecido crea evento y cambios `jsonb` por fila, en la misma
transacción. Solo UPDATE de atributos realmente distintos produce cambios. Tablas de auditoría son
inmutables y seleccionables solo por ADMINISTRADOR.

**Rationale**: cubre DML directo autorizado y RPC de manera uniforme; `jsonb` preserva tipos. La
clave textual mantiene auditoría tras eliminar el registro.

**Alternatives considered**: auditoría solo en frontend/RPC deja rutas sin cubrir; mezclar movimiento
y auditoría rompe sus finalidades.

## 13. Eliminación

**Decision**: solo RPC, OT PENDIENTE y cero movimientos. Detalles/acabados usan cascada; movimiento y
referencias maestras RESTRICT. Auditoría no tiene FK al registro operacional.

**Rationale**: satisface la política funcional y evita una cascada hacia control histórico.

**Alternatives considered**: soft-delete agrega un atributo no aprobado; cascade general perdería
historia.

## 14. Pruebas

**Decision**: Vitest para lógica, Testing Library para componentes, pgTAP/Supabase local para
constraints/RLS/RPC, Playwright para E2E multi-navegador y axe más revisión manual para accesibilidad.

**Rationale**: cada capa verifica la responsabilidad que realmente protege. E2E no sustituye pruebas
negativas de RLS ni constraints.

**Alternatives considered**: solo pruebas manuales o solo E2E dejan seguridad e integridad sin
cobertura reproducible.

Fuentes: [Vitest](https://vitest.dev/guide/), [Testing Library](https://testing-library.com/docs/react-testing-library/intro/),
[Playwright browsers](https://playwright.dev/docs/browsers),
[Supabase database testing](https://supabase.com/docs/guides/local-development/testing/overview).

## 15. Responsive y accesibilidad

**Decision**: CSS mobile-first con variables y estilos por feature, HTML semántico, labels, foco
visible, teclado, mensajes asociados y controles táctiles adecuados. WCAG 2.2 AA es objetivo de
calidad, no certificación.

**Rationale**: cumple Constitution y la autorización actual sin introducir un framework visual.

**Alternatives considered**: UI kit completo se difiere hasta demostrar necesidad.

Fuente: [WCAG 2.2](https://www.w3.org/TR/WCAG22/).

## 16. Despliegue, recuperación y observabilidad

**Decision**: GitHub/Vercel previews, producción desde `main`, proyectos Supabase separados, PITR o
capacidad equivalente para RPO 1 h, runbook y simulacro para RTO 2 h. Región São Paulo es preferida
sujeta a medición/plan. Logs Supabase/Vercel y correlation IDs cubren diagnóstico inicial.

**Rationale**: rollback frontend no restaura datos. PITR y simulacros son necesarios para objetivos
de continuidad; no se añade SaaS de monitoreo sin aprobación.

**Alternatives considered**: backup diario incumple RPO; previews contra producción son inseguros;
un servicio observability adicional es YAGNI mientras no haya requisitos de retención cerrados.

Fuentes: [Supabase backups](https://supabase.com/docs/guides/platform/backups),
[Production checklist](https://supabase.com/docs/guides/deployment/going-into-prod),
[Vercel + Vite](https://vercel.com/docs/frameworks/frontend/vite).

## 17. Enmiendas técnicas resueltas y límites restantes

- **Idempotencia de creación — resuelta**: la enmienda controlada de Spec 002 autoriza
  `idempotencia_creacion` como UUID durable y único de la operación agregada. Repetir la misma
  solicitud con la misma clave retorna el resultado canónico y no crea otra OT; la protección reside
  en servidor/base de datos y no en el botón del navegador.
- **Cierre de OT anulada — resuelto**: la enmienda autoriza `anulado_en`, fijado atómicamente por la
  operación segura al cambiar a ANULADO. Ese timestamp cierra la última permanencia productiva y la
  duración continúa derivándose sin usar auditoría ni una columna `duracion_sector`.
- Retención de auditoría/diagnósticos, proveedor SMTP, plan comercial y coste PITR siguen siendo
  gates de producción, no decisiones funcionales ni bloqueos para implementar el MVP.
