# Quickstart Validation Guide — Spec 003

Este documento describe cómo validar la implementación futura. No instala dependencias, no modifica
Supabase y no sustituye Tasks.

## Prerequisites

- Windows 11, PowerShell, Git, Node.js 22.12+ LTS y npm.
- Supabase CLI compatible, Docker Desktop para el entorno local y proyecto Supabase de prueba.
- Navegadores modernos Chrome/Edge y acceso a Safari real para smoke de aceptación.
- Variables locales con URL/clave publicable de un entorno no productivo; nunca secret/service-role
  en `frontend/.env`.
- Dependencias fijadas y lockfile ya creados por la futura fase de implementación.

## Planned local validation sequence

Desde la raíz del repositorio, la implementación deberá ofrecer comandos equivalentes a:

```powershell
node --version
npm --prefix frontend ci
npx supabase start
npx supabase db reset
npx supabase test db
npm --prefix frontend run lint
npm --prefix frontend run test
npm --prefix frontend run build
npm --prefix frontend run test:e2e
```

Los nombres finales deben verificarse contra `--help` y los scripts reales antes de ejecutarlos. El
reset solo se permite contra el entorno local; nunca contra producción.

## Environment gates

1. Auth público tiene sign-up y acceso anónimo deshabilitados.
2. Redirect URLs de local/preview/production están separadas.
3. Frontend contiene únicamente URL y publishable key.
4. Secret key solo existe en la Edge Function administrativa.
5. RLS está habilitado y los grants son explícitos en toda tabla expuesta.
6. Seeds generan exactamente los códigos aprobados y pueden reejecutarse sin duplicar.
7. Un ADMINISTRADOR inicial de prueba existe mediante el procedimiento privilegiado documentado.

## Database contract scenarios

### Structural rules

- Aceptar una OT con 0, 1, 2 o 3 pisos consecutivos.
- Rechazar piso 2 sin 1, piso 3 sin 2, piso 4 y dos pisos con el mismo número.
- Rechazar dimensiones materiales no positivas o pares final/corte incompletos.
- Rechazar armado/formato no positivos y `formato < armado`; aceptar sin divisibilidad exacta.
- Rechazar material que requiere gramaje sin configuración Activa; no crear `gramaje_id` en piso.
- Rechazar acabado duplicado, posición ausente en los cuatro especiales y posición presente en un
  acabado no especial.
- Verificar un solo USUARIO Activo por sector sin borrar perfiles históricos.

### RLS and grants

Ejecutar casos positivos y negativos como anon, ADMINISTRADOR, USUARIO del sector y USUARIO ajeno:

- anon no lee ni escribe negocio;
- ADMINISTRADOR ve todas las OT y consulta auditoría;
- USUARIO ve OT de su sector y su recorrido completo autorizado;
- USUARIO no escribe maestros, OT estructural ni auditoría;
- auditoría y movimientos pasados no admiten UPDATE/DELETE;
- helpers/RPC privados no son invocables por Data API fuera de sus wrappers autorizados.

## End-to-end user-story scenarios

### US1 — Crear y preparar OT

Crear una OT con cliente Activo, código automático, PENDIENTE, pisos 1–2 diferentes y acabados
válidos. Confirmar que código/actor/timestamps no provienen del navegador y que CREATE queda
auditado. Repetir con cero pisos. Intentar cliente Inactivo y piso incompleto: deben fallar sin datos
parciales. Repetir exactamente una creación válida con la misma `idempotencia_creacion`: debe
devolver la misma OT canónica sin duplicar cabecera, pisos, acabados ni auditoría.

### US2 — Consultar sector

Como USUARIO PRENSA, abrir listado paginado y comprobar que no aparecen OT cuyo último movimiento
pertenece a otro sector. Buscar/filtrar, abrir detalle y confirmar etiquetas históricas inactivas.

### US3 — Seleccionar responsable y avanzar

Iniciar una OT en PRENSA como ADMINISTRADOR y avanzar directamente a PRODUCCION como USUARIO de
PRENSA. Confirmar estado EN_PROCESO, responsable de destino y un único movimiento por acción.
Rechazar responsable de otro sector, destino ALMACEN y movimiento desde usuario ajeno.

### US4 — Devolver y repetir ciclo

Recorrer PRENSA → PRE_ACABADO → PRODUCCION → PRENSA → PRODUCCION sin motivo. Confirmar movimientos
append-only, visitas separadas y duración de las etapas cerradas.

### US5 — Finalizar

Llegar a PRODUCCION y confirmar que continúa EN_PROCESO. Ejecutar finalizar como usuario autorizado;
verificar TERMINADO, `terminado_en`, cierre de última duración y rechazo de movimientos posteriores.

### US6 — Corrección, anulación y eliminación

- Editar libremente una PENDIENTE y verificar audit diff.
- Corregir EN_PROCESO y mantener historial.
- Corregir excepcionalmente TERMINADO/ANULADO sin cambiar estado ni crear movimiento.
- Anular PENDIENTE/EN_PROCESO sin motivo, verificar `anulado_en` servidor y rechazar movimiento
  posterior.
- Eliminar solo PENDIENTE sin movimientos; verificar cascada operativa y auditoría persistente.
- Rechazar eliminación con cualquier movimiento o estado terminal.

### US7 — Administración

Invitar cuenta por correo, asignar rol/sector y comprobar que nunca se expone una clave secreta.
Inactivar cliente/material/sector/responsable/perfil y confirmar que desaparece de selecciones nuevas
pero sigue visible en historia. Rechazar segundo USUARIO Activo para el mismo sector.

### US8 — Recorrido y tiempos

Ver origen, destino, responsable, actor, tipo y timestamp de todos los movimientos. Confirmar orden
por timestamp+ID y tiempos derivados. Para OT TERMINADO, cerrar la última permanencia con
`terminado_en`; para OT ANULADA, cerrarla con `anulado_en`. Ninguna duración se persiste.

### US9 — Auditoría

Consultar CREATE/UPDATE/DELETE de todas las entidades cubiertas; verificar actor, instante, atributo
y valores JSON anterior/nuevo. Comprobar que un movimiento se ve en recorrido y no se duplica como
evento solo por existir, aunque el cambio de estado asociado sí se audite.

## Retry and concurrency scenarios

- Lanzar dos movimientos sobre la misma OT con la misma precondición: exactamente uno confirma; el
  otro recibe conflicto y refresca.
- Competir movimiento contra finalización/anulación: el lock y estado final dejan un solo resultado
  válido, sin parcialidad.
- Enviar dos actualizaciones con el mismo `modificado_en`: la segunda no pisa la primera.
- Perder artificialmente la respuesta de una creación y repetir exactamente la solicitud con la
  misma `idempotencia_creacion`; debe recuperarse el resultado canónico sin una segunda OT. Las demás
  escrituras verifican estado/precondiciones y nunca se repiten a ciegas.
- Ejecutar 10 sesiones concurrentes con mezcla representativa de listado, detalle y movimientos; no
  deben aparecer duplicados, deadlocks persistentes ni violaciones de RLS.

## Performance and pagination evidence

- Generar datos sintéticos equivalentes a 19.000 OT, con múltiples movimientos y auditoría.
- Verificar cursores estables sin cargar todo ni usar OFFSET profundo.
- Ejecutar `EXPLAIN (ANALYZE, BUFFERS)` para último movimiento, listado por sector/filtros y
  auditoría; documentar entorno, plan y resultado.
- Las recomendaciones temporales de Spec 001 pueden medirse como referencia, pero no se reportan
  como requisitos aprobados salvo los objetivos explícitos de este Plan.

## Responsive, browser and accessibility evidence

- Playwright: Chromium, Edge channel y WebKit; perfiles de escritorio, Android, iPhone e iPad.
- Smoke manual: Chrome/Edge/Safari estables vigentes, registrando versión/dispositivo.
- Teclado completo, foco visible/no oculto, labels/errores asociados, reflow/zoom, contraste,
  targets táctiles y anuncios de estado.
- axe apoya la detección; la revisión manual sigue siendo obligatoria. El resultado expresa objetivo
  WCAG 2.2 AA, no certificación formal.

## Recovery and deployment evidence

Antes de producción:

1. desplegar Preview Vercel contra Supabase no productivo;
2. ejecutar suite y aprobación humana;
3. comprobar build estático y rewrite SPA;
4. validar SMTP e invitación/recuperación;
5. habilitar protección que asegure RPO ≤ 1 h;
6. ejecutar restauración cronometrada y comprobar datos, permisos y flujos en ≤ 2 h;
7. documentar rollback frontend, escalamiento y contingencia;
8. medir el SLI de disponibilidad durante el horario aprobado con objetivo 99,5 %.

Vercel rollback no revierte base de datos ni variables; cualquier cambio de esquema futuro debe usar
migraciones versionadas y estrategia compatible.

## Completion evidence

La implementación solo estará lista cuando cada requisito aplicable tenga prueba/inspección,
entorno, resultado y evidencia; todas las suites pasen; no existan secretos en el bundle/repositorio;
los advisors de seguridad/rendimiento no tengan hallazgos críticos; y la revisión humana acepte los
flujos principales.
