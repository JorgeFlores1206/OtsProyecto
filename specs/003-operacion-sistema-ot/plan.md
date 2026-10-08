# Implementation Plan: Spec 003 — Operación funcional del sistema de Órdenes de Trabajo

> ⚠️ **OBSOLETO desde 2026-10-08.** Este artefacto se basa en la arquitectura anterior (frontend
> conectado directamente a Supabase, auditoría completa y eliminación física de OT). La Constitution
> v1.1.0, la Spec 000 v1.1.0, la Enmienda 3 de Spec 002 y la Enmienda funcional de esta Spec lo
> invalidan. **No implementar tareas de este archivo**; regenerar con `/speckit-plan` y
> `/speckit-tasks`.

**Branch**: `main` | **Date**: 2026-10-06 | **Spec**: [spec.md](./spec.md)
**Plan Status**: COMPLETO — aprobado y sincronizado con Tasks

**Input**: Spec 003 planificada, Constitution v1.0.0, Specs 000–002 y las decisiones
técnicas autorizadas para este Plan.

## Summary

El MVP será una SPA responsive React/Vite en JavaScript que usa `supabase-js` para Supabase Auth,
lecturas protegidas por RLS y una superficie pequeña de RPC para operaciones transaccionales. Las 16
entidades de Spec 002 se implementarán en PostgreSQL sin agregar entidades ni duplicar sector o
responsable actual. Los movimientos, finalización, anulación, edición agregada y eliminación
controlada se serializarán bloqueando la OT y se ejecutarán atómicamente. La auditoría se generará
mediante triggers endurecidos y permanecerá separada de `movimiento_ot`.

La enmienda controlada de Spec 002 incorpora únicamente `idempotencia_creacion` para deduplicar la
creación agregada y `anulado_en` para cerrar la última permanencia anulada; no altera las 16
entidades, cardinalidades ni reglas empresariales.

La única capacidad servidor fuera de PostgreSQL será una Supabase Edge Function administrativa para
invitar/administrar identidades Auth sin exponer claves privilegiadas. No se incorpora backend
tradicional, Redux, microservicios, colas, Redis, GraphQL ni infraestructura adicional.

## Technical Context

**Language/Version**: JavaScript; React 19 estable; Node.js 22.12+ LTS para build y pruebas  
**Primary Dependencies**: React, React DOM, Vite estable compatible, React Router declarativo,
`@supabase/supabase-js` v2; versiones exactas fijadas en `package-lock.json` al iniciar implementación  
**Storage**: PostgreSQL administrado por Supabase; 16 entidades de Spec 002; Supabase Auth para
identidades; sin almacenamiento offline de datos de negocio  
**Testing**: Vitest, React Testing Library/user-event, Playwright, axe para apoyo de accesibilidad,
pgTAP y Supabase CLI local; no se instalan durante Plan  
**Target Platform**: SPA web en Vercel; Chrome, Edge y Safari modernos en escritorio/laptop, Android,
iPhone e iPad; Windows 11/PowerShell/VS Code para desarrollo  
**Project Type**: Aplicación web SPA con backend administrado Supabase y una Edge Function mínima para
administración Auth  
**Performance Goals**: paginación desde la primera consulta; validación con al menos 19.000 OT y 10
usuarios simultáneos; tiempos de carga se medirán sin convertir recomendaciones no aprobadas de Spec
001 en límites contractuales  
**Constraints**: RPO máximo 1 hora; RTO máximo 2 horas; disponibilidad objetivo 99,5 % durante lunes a
viernes 08:00–19:00 y sábado 08:00–13:00; WCAG 2.2 AA como objetivo, no certificación formal  
**Scale/Scope**: nueve historias, 16 entidades, cuatro sectores productivos más ALMACÉN fuera del
flujo, aproximadamente 19.000 OT como volumen de referencia y crecimiento posterior

Los valores de RTO, disponibilidad, concurrencia, navegadores modernos y WCAG fueron pendientes o
recomendaciones en Spec 001 y quedan aprobados para este Plan por la instrucción humana del
2026-10-06. No se atribuyen retroactivamente a la versión documental de Spec 001.

## Constitution Check

*GATE inicial y posterior al diseño: PASS.*

| Principio constitucional | Comprobación del Plan | Estado |
|---|---|---|
| I. Arquitectura basada en datos | Spec 002 conserva autoridad; se implementan exactamente 16 entidades y no se agregan columnas de sector/responsable actual. | PASS |
| II. OT como núcleo | Creación, consulta, edición, recorrido, estados y auditoría se diseñan alrededor del agregado OT. | PASS |
| III y IX. Mobile-first/responsive | SPA mobile-first con adaptación de listados/formularios y pruebas Android/iOS/escritorio. | PASS |
| IV. Alcance controlado | Solo capacidades de Spec 003; migración histórica, reportes y cálculo automático quedan fuera. | PASS |
| V. Seguridad | Auth, RLS, grants y RPC protegen datos; ninguna clave secreta llega al navegador. | PASS |
| VI. Integridad | CHECK/FK/UNIQUE, triggers diferibles, locks y transacciones respaldan reglas críticas. | PASS |
| VII y VIII. Mantenibilidad/separación | Organización por features y capas; componentes no consultan Supabase directamente. | PASS |
| X. Auditoría | Evento/cambios inmutables y separados de movimiento productivo. | PASS |
| XI–XIII. Flujo y aceptación | Spec 003 está clarificada; contratos y quickstart hacen verificables sus escenarios. | PASS |
| XIV. Pruebas | Pirámide unitarias/componentes/BD/integración/E2E con permisos y concurrencia. | PASS |
| XV. Simplicidad | SPA + Supabase; sin backend tradicional ni tecnologías especulativas. | PASS |
| XVI–XVII. Gobernanza | Los dos metadatos técnicos se incorporan mediante enmienda controlada y sincronizada; no se cambia la semántica empresarial. | PASS |

## Architecture

```text
React/Vite SPA (Vercel)
  ├── presentación y estado local
  ├── servicios por feature
  └── supabase-js con URL + publishable key
          │
          ├── Supabase Auth (correo/contraseña, recuperación e invitación)
          ├── Data API (SELECT con RLS y vistas security_invoker)
          ├── RPC pública mínima (wrappers SECURITY INVOKER)
          │       └── funciones privadas controladas para transacciones críticas
          ├── PostgreSQL (constraints, RLS, triggers, auditoría)
          └── Edge Function admin-users
                  └── Auth Admin API con secret key solo en entorno servidor
```

### Separation of responsibilities

- **Presentación**: rutas, formularios, tablas responsive, estados de carga/error y accesibilidad.
  Variables CSS prepararán la paleta verde pino, blanco y neutros sin fijar todavía el diseño final.
- **Aplicación**: hooks/controladores de feature, mapeo de respuestas y reglas de interacción; no
  decide autorización ni integridad.
- **Acceso a datos**: módulos `api` de cada feature y un único cliente Supabase.
- **Autenticación**: Auth maneja credenciales/sesiones; `perfil_usuario` aporta rol, sector y estado.
- **Autorización/integridad**: RLS, grants, funciones privadas y constraints PostgreSQL.
- **Privilegios Auth**: Edge Function limitada; ninguna clave secret/service-role en `VITE_*`.

## Core Technical Decisions

### Database and atomic operations

- PK `integer identity` para entidades ordinarias; `bigint identity` para movimiento y auditoría.
- `codigo_ot` usa una secuencia dedicada, se almacena como texto único y no editable; no se usa
  `MAX()+1`. Una importación futura podrá insertar códigos y adelantar la secuencia sin duplicar un
  segundo campo empresarial.
- Creación/edición de OT reciben cabecera, pisos y acabados como agregado y se confirman en una sola
  transacción. La consecutividad de pisos se valida en RPC y mediante trigger diferible de respaldo.
- La creación recibe una `idempotencia_creacion` UUID estable para el intento lógico. Su unicidad se
  protege en servidor/base de datos: repetir exactamente la misma solicitud con la misma clave
  devuelve el resultado canónico previamente procesado y no crea otra OT. La clave no es visible ni
  sustituye `codigo_ot`.
- Movimiento, finalización, anulación y eliminación bloquean primero `orden_trabajo`, validan el
  actor desde `auth.uid()` y mantienen transacciones breves.
- Finalización cambia estado y establece `terminado_en` atómicamente; anulación cambia estado y
  establece `anulado_en` atómicamente. Ambos timestamps provienen del servidor y cierran la última
  permanencia productiva aplicable sin persistir una duración.
- Edición usa `modificado_en` como precondición optimista. Movimiento usa
  `expected_last_movement_id`; un segundo clic queda en conflicto y obliga a refrescar, sin duplicar.
- La creación solo se reintenta conservando la misma clave durable y el mismo contenido. Movimiento,
  finalización y anulación usan locks, estado esperado y precondiciones en lugar de agregar campos
  empresariales de idempotencia.

### RLS and grants

- RLS en las 16 tablas y grants explícitos; `anon` no recibe acceso a datos de negocio.
- Lecturas directas: vistas/listados de OT, detalle autorizado, recorrido y maestros bajo RLS.
- `ADMINISTRADOR` lee todas las OT; `USUARIO` solo OT cuyo último movimiento corresponde a su sector.
- Hijos y recorrido heredan visibilidad mediante la OT. Auditoría es seleccionable solo por
  `ADMINISTRADOR` y no admite DML operativo.
- Escrituras de OT, movimientos, estados y eliminación se realizan exclusivamente por RPC.
- Maestros simples admiten INSERT/UPDATE de ADMINISTRADOR bajo RLS y triggers; no DELETE normal.
  Material/gramajes, reordenamiento de sectores y perfiles usan operaciones controladas por sus
  reglas entre tablas.
- Rol, estado y sector siempre se resuelven desde `perfil_usuario`/`rol`, no desde `user_metadata`,
  parámetros del navegador ni botones ocultos.

### RPC and privileged functions

Se planifican `crear_ot`, `actualizar_ot`, `mover_ot`, `finalizar_ot`, `anular_ot`, `eliminar_ot`,
`guardar_material_configuracion`, `reordenar_sectores` y operaciones de perfil. Los wrappers
expuestos serán `SECURITY INVOKER`; núcleos privilegiados estrictamente necesarios residirán en un
esquema no expuesto, con `search_path` vacío, nombres calificados, propietario sin login y permisos
mínimos. Se revoca `EXECUTE` a `PUBLIC`/`anon` y se concede individualmente a `authenticated`.

### Current sector/responsible and pagination

- Una vista normal `security_invoker`, no materializada, obtiene el último movimiento por
  `ocurrido_en DESC, id DESC`; antes del inicio devuelve sector/responsable nulos.
- Índice principal: movimiento por `(orden_trabajo_id, ocurrido_en DESC, id DESC)`; no hay
  denormalización ni segunda fuente de verdad.
- Listados usan cursor keyset `(fecha_ot, id)` descendente, filtros server-side y tamaño de página
  configurable; no OFFSET profundo ni conteo exacto obligatorio en cada vista.
- Se indexan FKs y filtros comprobados. `pg_trgm` solo se añade si mediciones de búsqueda interna lo
  justifican; no se anticipa una columna de búsqueda.

### Audit and deletion

- Triggers por fila generan `auditoria_evento` y `auditoria_cambio` en la misma transacción; valores
  se representan como `jsonb`. El actor se deriva de `auth.uid()` y nunca de la solicitud.
- Cobertura: OT, pisos, acabados, clientes, catálogos, sectores, responsables, perfiles y cambio de
  rol. `movimiento_ot` es append-only y no se duplica como auditoría; sí se audita el cambio de estado
  de la OT que produzca una operación.
- Solo se elimina una OT `PENDIENTE` sin movimientos. Detalles y acabados usan cascada controlada;
  movimiento usa RESTRICT. Auditoría no tiene FK al registro operacional y nunca queda en cascada.
- Maestros, perfiles, sectores y responsables históricos se inactivan y usan RESTRICT.

### Auth, sessions and administration

- Acceso con correo/contraseña, recuperación por correo y registro público deshabilitado.
- `supabase-js` conserva y renueva sesión; reautentica ante revocación, invalidez o imposibilidad de
  renovación. Toda operación crítica comprueba además que el perfil esté Activo.
- La Edge Function `admin-users` valida JWT y rol ADMINISTRADOR antes de invitar por correo y usa la
  secret key moderna solo en servidor. La creación de perfil se ejecuta con contexto del actor; ante
  fallo parcial se compensa o reanuda por UUID/correo sin duplicar.
- SMTP propio, URLs de redirección y Site URL son gates de producción. El primer ADMINISTRADOR se
  provisiona mediante un procedimiento privilegiado único y auditable.

### Availability, deployment and observability

- Local/test y producción usan proyectos Supabase separados; Vercel Development/Preview/Production
  nunca comparten secretos ni datos reales accidentalmente.
- GitHub → Preview → validaciones → `main` → Production. Vercel sirve `frontend/dist` con rewrite SPA.
- RPO 1 h exige plan Supabase con PITR o capacidad equivalente; RTO 2 h se valida con simulacro de
  restauración y runbook. Región preferida: São Paulo si la medición desde Bolivia y el plan
  contratado la confirman antes de crear producción.
- Disponibilidad se mide durante el horario aprobado mediante carga del frontend y operación canario
  autenticada; el objetivo 99,5 % no se presenta como SLA del proveedor.
- Taxonomía común de errores y correlation ID; Supabase Logs y Vercel Observability son fuentes
  iniciales. Retención/acceso a diagnósticos y proveedor SMTP deben cerrarse antes de producción.

## Project Structure

### Documentation (this feature)

```text
specs/003-operacion-sistema-ot/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── interfaces.md
└── tasks.md                 # generado y sincronizado con este Plan
```

### Source Code (repository root)

```text
frontend/
├── src/
│   ├── app/                 # bootstrap, rutas y providers mínimos
│   ├── features/
│   │   ├── auth/
│   │   ├── ot/
│   │   ├── clientes/
│   │   ├── catalogos/
│   │   ├── sectores/
│   │   ├── usuarios/
│   │   └── auditoria/
│   ├── shared/
│   │   ├── components/
│   │   ├── lib/supabase/
│   │   ├── errors/
│   │   └── validation/
│   └── styles/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
└── public/

supabase/
├── config.toml
├── migrations/             # se generarán en implementación, no en Plan
├── seed.sql                # se generará en implementación
├── functions/
│   └── admin-users/
└── tests/
    └── database/
```

**Structure Decision**: un frontend SPA y una carpeta Supabase. Los módulos se agrupan por capacidad
del negocio; componentes compartidos existen solo cuando tienen reutilización real. No hay carpeta
`backend/` porque PostgreSQL/RLS/RPC y una Edge Function acotada cubren el MVP.

## Phase 0: Research

Completada en [research.md](./research.md). Se resolvieron versiones/gestor, Auth, sesión, RLS/RPC,
modelo físico, auditoría, concurrencia, paginación, frontend, pruebas, despliegue y continuidad. No
quedan incógnitas técnicas bloqueantes.

## Phase 1: Design and Contracts

- [data-model.md](./data-model.md): implementación física de las 16 entidades, constraints,
  relaciones, índices, estados y validaciones cruzadas.
- [contracts/interfaces.md](./contracts/interfaces.md): contratos de Auth, lecturas, RPC, errores y
  concurrencia sin código ejecutable.
- [quickstart.md](./quickstart.md): escenarios de validación end-to-end y comandos previstos.

### Post-design Constitution Check

**PASS**. El diseño mantiene 16 entidades, ubica reglas críticas en PostgreSQL, conserva separación
entre movimiento y auditoría, limita privilegios, ofrece pruebas verificables y no incorpora
arquitectura adicional sin necesidad. No existen violaciones que requieran Complexity Tracking.

## Resolved Technical Decisions

1. **Idempotencia de creación — RESUELTA**: la enmienda controlada de Spec 002 autoriza
   `orden_trabajo.idempotencia_creacion` como UUID técnico durable y único. La operación agregada
   reutiliza esa clave ante doble clic, timeout, pérdida de respuesta o reintento y retorna el
   resultado canónico sin duplicar la OT.
2. **Última permanencia al anular — RESUELTA**: la misma enmienda autoriza `anulado_en`, establecido
   atómicamente por servidor/base de datos junto con `ANULADO`. Ese momento cierra la última etapa
   productiva, sin movimiento ficticio ni `duracion_sector` persistida.

## Remaining Risks and Non-blocking Decisions

1. **Auth + perfil**: no comparten transacción; la Edge Function necesita compensación y reanudación.
2. **Operación de producción**: plan/coste de Supabase con PITR, SMTP, región y simulacro RTO deben
   confirmarse antes del go-live.
3. **Retención**: periodos de auditoría y diagnósticos siguen pendientes; no autorizan purga durante
   el MVP.
4. **Búsqueda**: índices de texto avanzados dependen de mediciones reales; los índices base y la
   paginación sí forman parte del MVP.

## Complexity Tracking

No hay violaciones constitucionales ni componentes cuya complejidad requiera excepción.
