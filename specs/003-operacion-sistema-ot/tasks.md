# Tasks: Spec 003 — Operación funcional del sistema de Órdenes de Trabajo

**Input**: artefactos aprobados de `specs/003-operacion-sistema-ot/`  
**Prerequisites**: `spec.md`, `plan.md`, `research.md`, `data-model.md`, `contracts/interfaces.md`, `quickstart.md`, Constitution, Spec 000, Spec 001 y Spec 002 APROBADA  
**Tests**: obligatorios; en cada historia se escriben primero y deben fallar antes de implementar  
**Scope guard**: no incluye migración de las ~19.000 OT históricas, fórmula automática de `total_pliegos`, nuevos roles, reportes avanzados ni despliegue productivo

## Formato y trazabilidad

- Cada tarea sigue `- [ ] T### [P?] [US#?] descripción con ruta exacta`.
- `[P]` identifica trabajo sobre artefactos distintos sin dependencia directa.
- `[US#]` vincula la tarea con una de las nueve historias de `spec.md`.
- Las fases compartidas se trazan a secciones del Plan (`PL`), modelo (`DM`), contratos (`CT`), requisitos funcionales (`FR`) y criterios (`SC`) indicados en cada fase.
- Las pruebas de una historia preceden a su implementación y constituyen su evidencia independiente.

## Phase 1: Setup — base del proyecto

**Purpose**: preparar React/Vite/JavaScript, Supabase local y herramientas de calidad sin implementar reglas del dominio.  
**Traceability**: PL Technical Context/Project Structure; Research §§1–3, 14–16; Spec 000; Spec 001.

- [x] T001 Inicializar la SPA React + Vite en JavaScript con Node 22.12+ y npm; fijar scripts, dependencias de ejecución (`react`, `react-dom`, `react-router-dom`, `@supabase/supabase-js`) y dependencias de desarrollo requeridas por T002/T006/T007 (Vite, ESLint para React, Vitest, jsdom, Testing Library/user-event, Playwright y axe) en `frontend/package.json`, `frontend/package-lock.json`, `frontend/index.html`, `frontend/src/main.jsx` y `frontend/src/App.jsx` (PL Project Structure; Research §§1–2, 14–15)
- [x] T002 [P] Configurar ESLint y convenciones JavaScript/JSX sin TypeScript ni Redux en `frontend/eslint.config.js` y `frontend/.gitignore` (PL Simplicity; Constitution VII/XV)
- [x] T003 [P] Crear plantillas de variables públicas y locales seguras con `VITE_SUPABASE_URL` y `VITE_SUPABASE_PUBLISHABLE_KEY`, sin secretos, en `frontend/.env.example` y `.gitignore` (Research §3; CT General rules)
- [x] T004 Inicializar la configuración versionada de Supabase local, rutas de migraciones/seeds y política de desarrollo no productivo en `supabase/config.toml` y `supabase/.gitignore` (PL Local Development; Quickstart)
- [x] T005 [P] Crear la estructura por features y componentes compartidos mediante archivos índice mínimos en `frontend/src/features/auth/index.js`, `frontend/src/features/ot/index.js`, `frontend/src/features/clientes/index.js`, `frontend/src/features/catalogos/index.js`, `frontend/src/features/sectores/index.js`, `frontend/src/features/usuarios/index.js`, `frontend/src/features/auditoria/index.js` y `frontend/src/shared/index.js` (PL Project Structure; Research §2)
- [x] T006 Configurar Vitest, jsdom, Testing Library y user-event con comandos reproducibles en `frontend/vitest.config.js` y `frontend/tests/setup.js` (Research §14; Constitution XIV)
- [x] T007 [P] Configurar Playwright con proyectos Chromium, Edge y WebKit, perfiles desktop/Android/iPhone/iPad y axe en `frontend/playwright.config.js` y `frontend/tests/e2e/fixtures/a11y.js` (PL Responsive/Accessibility; Research §§14–15)
- [x] T008 [P] Preparar el arnés pgTAP/Supabase local y helpers de identidades/claims de prueba en `supabase/tests/database/000_test_helpers.sql` (PL Testing; CT Access matrix)
- [x] T009 Crear la navegación declarativa inicial, layout protegido y páginas placeholder sin lógica de negocio en `frontend/src/app/router.jsx`, `frontend/src/app/AppProviders.jsx` y `frontend/src/app/layouts/AppLayout.jsx` (PL Frontend Architecture; Research §2)

**Checkpoint**: herramientas, estructura y entorno local listos; no hay lógica de dominio implementada.

---

## Phase 2: Foundational — prerrequisitos bloqueantes

**Purpose**: sincronizar las decisiones técnicas autorizadas y construir la base de datos, seguridad, Auth y utilidades compartidas que bloquean todas las historias.  
**Traceability**: FR-001–023, FR-030, FR-043, FR-070, FR-075–078; DM 16 entities; CT General/Access matrix; Constitution I, V, VI, X, XVI.

> **CRITICAL**: ninguna historia comienza hasta completar esta fase y aprobar sus pruebas de esquema/RLS.

> **Orden TDD obligatorio de la fase**: después de T010–T011 se escriben T027–T028 y se comprueba
> que fallan por capacidades ausentes; luego se ejecutan T012–T026 y finalmente se repiten T027–T028
> hasta aprobar. La numeración estable conserva la trazabilidad y no define por sí sola el orden.

- [x] T010 Registrar como enmienda estructural controlada la clave técnica durable `idempotencia_creacion` de `orden_trabajo` y el instante `anulado_en`, con justificación, impacto, preservación de 16 entidades y aprobación de esta instrucción, en `specs/002-diccionario-datos/spec.md`, `specs/002-diccionario-datos/checklists/requirements.md` y `specs/003-operacion-sistema-ot/spec.md` (FR-001, FR-049, FR-071, FR-078; Constitution I/XVI)
- [x] T011 Sincronizar la representación, constraints, contratos y riesgos resueltos de `idempotencia_creacion` y `anulado_en` en `specs/003-operacion-sistema-ot/plan.md`, `specs/003-operacion-sistema-ot/data-model.md`, `specs/003-operacion-sistema-ot/contracts/interfaces.md`, `specs/003-operacion-sistema-ot/research.md` y `specs/003-operacion-sistema-ot/quickstart.md` antes de escribir la migración (CT crear_ot/anular_ot; DM State Transitions)
- [ ] T027 Escribir primero pgTAP para las 16 tablas, constraints, relaciones, seeds, auditoría base e imposibilidad de DML histórico, y comprobar el fallo inicial por esquema ausente, en `supabase/tests/database/010_schema_integrity.test.sql` (FR-001, FR-019–021, FR-031–043, FR-076; SC-003, SC-007, SC-010)
- [ ] T028 Escribir primero pgTAP negativo para RLS/grants de las 16 tablas usando anon, USUARIO de sector, otro sector, perfil inactivo y ADMINISTRADOR, y comprobar el fallo inicial por políticas ausentes, en `supabase/tests/database/020_rls_baseline.test.sql` (FR-005–012, FR-016; SC-005)
- [ ] T012 Crear esquemas privado/público, extensiones estrictamente necesarias, secuencia del correlativo y helpers de contexto autenticado con `search_path` seguro en `supabase/migrations/202610060001_base_security.sql` (PL Security; Research §§7, 9)
- [ ] T013 Crear `cliente`, `tipo_material`, `material`, `gramaje`, `maquina`, `parametro`, `rol`, `sector` y `responsable_sector` con PK, FK, UNIQUE, CHECK, NOT NULL, defaults y RESTRICT del contrato aprobado en `supabase/migrations/202610060002_master_entities.sql` (DM Entities 1, 4–8, 10, 12–13)
- [ ] T014 Crear `perfil_usuario`, `orden_trabajo`, `ot_detalle` y `ot_acabado`, incluyendo correlativo inmutable, metadatos autorizados, pares X/Y, pisos 0..3 y cascadas selectivas en `supabase/migrations/202610060003_ot_access_entities.sql` (DM Entities 2–3, 9, 11; FR-025, FR-031–042)
- [ ] T015 Crear `movimiento_ot`, `auditoria_evento` y `auditoria_cambio` con historial append-only, JSONB y referencias que preserven auditoría en `supabase/migrations/202610060004_history_entities.sql` (DM Entities 14–16; FR-052, FR-075–077)
- [ ] T016 Implementar triggers/constraints diferibles para consecutividad de pisos, grupo de parámetros, material–gramaje, acabado–posición, perfil–sector y timestamps inmutables en `supabase/migrations/202610060005_integrity_triggers.sql` (DM Cross-row Enforcement; FR-015, FR-031–041)
- [ ] T017 Crear índices iniciales de FK, correlativo, cursor `(fecha_ot,id)`, movimiento más reciente, maestros activos y auditoría según consultas reales en `supabase/migrations/202610060006_base_indexes.sql` (DM Read Models; PL Pagination)
- [ ] T018 Cargar seeds idempotentes únicamente para roles, estados, sectores/participación, colorimetría, impresión, muestrario, tipos de trabajo y acabados aprobados en `supabase/seed.sql`; crear y documentar en `supabase/scripts/bootstrap-local-admin.ps1` y `docs/admin-bootstrap.md` el procedimiento privilegiado, auditable y exclusivo de local/prueba para provisionar el primer ADMINISTRADOR sin auto-registro ni secretos versionados (DM Initial Data; FR-003, FR-013–016, FR-022, FR-035–036, FR-041, FR-043; SC-013)
- [ ] T019 Implementar el trigger genérico de auditoría transaccional para OT, pisos, acabados, clientes, catálogos, sectores, responsables, perfiles y rol, excluyendo secretos y movimiento como duplicado funcional, en `supabase/migrations/202610060007_audit_framework.sql` (FR-030, FR-075–077; Research §12)
- [ ] T020 Implementar helpers privados, grants mínimos y RLS para clientes/catálogos/materiales/sectores/responsables/perfiles, con lectura histórica e inmutabilidad de códigos usados, en `supabase/migrations/202610060008_master_profile_rls.sql` (FR-005–020; CT Access matrix)
- [ ] T021 Implementar RLS y grants para OT, pisos, acabados y movimiento con visibilidad ADMINISTRADOR/sector actual y DML crítico solo por RPC en `supabase/migrations/202610060009_ot_movement_rls.sql` (FR-006, FR-009–012, FR-055; CT Access matrix)
- [ ] T022 Implementar RLS/grants de solo lectura ADMINISTRADOR para auditoría y denegar UPDATE/DELETE operativos sobre auditoría y movimientos históricos en `supabase/migrations/202610060010_audit_history_rls.sql` (FR-007, FR-076–077)
- [ ] T023 [P] Implementar singleton Supabase con persistencia/renovación de sesión y variables públicas exclusivamente en `frontend/src/shared/lib/supabase/client.js` (FR-014, FR-017; Research §§3–4)
- [ ] T024 Implementar `AuthProvider`, carga de perfil/rol/sector activo, logout y guards por autenticación/rol en `frontend/src/features/auth/AuthProvider.jsx`, `frontend/src/features/auth/authService.js` y `frontend/src/app/guards/ProtectedRoute.jsx` (FR-005, FR-008, FR-016–017)
- [ ] T025 [P] Implementar taxonomía central de errores, correlation ID, redacción de datos sensibles y feedback accesible en `frontend/src/shared/errors/errorMap.js`, `frontend/src/shared/errors/operationContext.js` y `frontend/src/shared/components/OperationFeedback.jsx` (PL Observability; CT Error contract)
- [ ] T026 [P] Crear tokens verde pino/blanco/neutros, reset semántico, foco visible y layout mobile-first compartido en `frontend/src/styles/tokens.css`, `frontend/src/styles/global.css` y `frontend/src/app/layouts/AppLayout.css` (Constitution III/IX; WCAG 2.2 AA objective)

**Checkpoint**: 16 entidades, seeds, auditoría base, Auth y RLS verificables están listos; secretos no llegan al navegador.

---

## Phase 3: User Story 1 — Administrador crea y prepara una OT (Priority: P1) 🎯

**Goal**: crear atómicamente una OT `PENDIENTE` con correlativo, 0..3 pisos y acabados válidos sin duplicarla ante reintentos.  
**Independent Test**: un ADMINISTRADOR crea OT con 0, 1, 2 y 3 pisos; se rechazan huecos/valores inválidos y repetir la misma clave devuelve la misma OT.  
**Traceability**: US1; FR-024–042, FR-078; SC-006–007; DM OT aggregate; CT `crear_ot`.

### Tests for User Story 1 — escribir primero y comprobar fallo

- [ ] T029 [P] [US1] Escribir pgTAP de `crear_ot` para autorización, correlativo, cliente/tipo Activos, agregado 0..3, constraints de pisos/acabados y reintento durable sin duplicados en `supabase/tests/database/100_create_ot_rpc.test.sql`
- [ ] T030 [P] [US1] Escribir unit tests de validadores y reducer para cabecera, enteros, pares X/Y, material–gramaje, armado/formato, pisos consecutivos y acabados en `frontend/tests/unit/otForm.test.js`
- [ ] T031 [P] [US1] Escribir pruebas Testing Library del formulario dinámico, errores/foco y confirmación única en `frontend/tests/integration/us1-create-ot-form.test.jsx`
- [ ] T032 [P] [US1] Escribir E2E de creación con cero y tres pisos, rechazo de piso incompleto y simulación de respuesta perdida/reintento en `frontend/tests/e2e/us1-create-ot.spec.js`

### Implementation for User Story 1

- [ ] T033 [US1] Implementar RPC transaccional `crear_ot` con actor derivado, locks necesarios, correlativo, estado PENDIENTE, agregado completo, auditoría y `idempotencia_creacion` UUID reusable en `supabase/migrations/202610060011_create_ot_rpc.sql`
- [ ] T034 [P] [US1] Implementar validadores/mapeadores puros del agregado OT sin fórmula de `total_pliegos` en `frontend/src/features/ot/validation/otValidators.js` y `frontend/src/features/ot/api/otMappers.js`
- [ ] T035 [US1] Implementar reducer del borrador y generación/reutilización de la clave de idempotencia hasta recibir resultado canónico en `frontend/src/features/ot/hooks/useOtForm.js`
- [ ] T036 [P] [US1] Implementar editor de cabecera y selectores de maestros Activos, preservando etiquetas históricas solo en lectura, en `frontend/src/features/ot/components/OtHeaderFields.jsx`
- [ ] T037 [P] [US1] Implementar editor dinámico de pisos 0..3 que solo agrega/quita desde el extremo y valida campos condicionales en `frontend/src/features/ot/components/FloorEditor.jsx`
- [ ] T038 [P] [US1] Implementar selector múltiple de acabados sin duplicados y posición solo para códigos especiales en `frontend/src/features/ot/components/FinishesEditor.jsx`
- [ ] T039 [US1] Implementar adapter de catálogos y servicio de creación RPC con manejo de resultado ambiguo en `frontend/src/features/ot/api/otCatalogService.js` y `frontend/src/features/ot/api/otWriteService.js`
- [ ] T040 [US1] Integrar formulario, resumen, errores accesibles y navegación al resultado canónico en `frontend/src/features/ot/pages/CreateOtPage.jsx` y `frontend/src/app/router.jsx`

**Checkpoint**: US1 es funcional y comprobable de forma independiente; el mismo intento no crea dos OT.

---

## Phase 4: User Story 2 — Usuario visualiza las OT de su sector (Priority: P1)

**Goal**: autenticar por correo/contraseña y consultar detalle/listado paginado según rol y sector.  
**Independent Test**: un USUARIO de PRENSA solo lista OT actualmente en PRENSA, busca/filtra con cursor y recupera contraseña por correo sin auto-registro.  
**Traceability**: US2; FR-005, FR-008–017, FR-064–070; SC-001, SC-005, SC-009, SC-014; CT Auth/OT list/detail.

### Tests for User Story 2 — escribir primero y comprobar fallo

- [ ] T041 [P] [US2] Escribir pgTAP de vista `vista_ot_situacion_actual`, RLS por último movimiento y consulta paginada keyset sin fuga entre sectores en `supabase/tests/database/110_ot_list_rls.test.sql`
- [ ] T042 [P] [US2] Escribir unit tests de cursores, filtros, límites de página y mapeo seguro de resultados en `frontend/tests/unit/otListQuery.test.js`
- [ ] T043 [P] [US2] Escribir pruebas Testing Library de login, recuperación uniforme, guards, listado y apertura de detalle en `frontend/tests/integration/us2-auth-list-detail.test.jsx`
- [ ] T044 [P] [US2] Escribir E2E de login Admin/Usuario, renovación/logout, listado de sector, filtros y recuperación por correo simulada en `frontend/tests/e2e/us2-sector-list.spec.js`

### Implementation for User Story 2

- [ ] T045 [US2] Crear vistas `security_invoker` de situación actual y detalle legible, más función de lectura paginada con cursor `(fecha_ot,id)` y filtros acotados en `supabase/migrations/202610060012_ot_read_models.sql`
- [ ] T046 [P] [US2] Implementar páginas de login, solicitud y restablecimiento por sesión recovery sin auto-registro en `frontend/src/features/auth/pages/LoginPage.jsx`, `frontend/src/features/auth/pages/ForgotPasswordPage.jsx` y `frontend/src/features/auth/pages/ResetPasswordPage.jsx`
- [ ] T047 [US2] Implementar servicio de listado/detalle y serialización de cursor/filtros en `frontend/src/features/ot/api/otReadService.js`
- [ ] T048 [P] [US2] Implementar buscador, filtros por código/cliente/nombre/fecha/estado/sector/responsable y paginación gradual en `frontend/src/features/ot/components/OtFilters.jsx` y `frontend/src/features/ot/components/OtList.jsx`
- [ ] T049 [P] [US2] Implementar detalle de cabecera/pisos/acabados/situación con maestros inactivos históricos visibles en `frontend/src/features/ot/pages/OtDetailPage.jsx`
- [ ] T050 [US2] Integrar rutas y vista inicial por rol, mostrando todas las OT al ADMINISTRADOR y solo el sector actual al USUARIO, en `frontend/src/features/ot/pages/OtListPage.jsx` y `frontend/src/app/router.jsx`

**Checkpoint**: US2 es funcional y la Data API, no solo la UI, limita el sector del USUARIO.

---

## Phase 5: User Story 3 — Usuario selecciona responsable y envía una OT (Priority: P1)

**Goal**: registrar INICIO/AVANCE atómico con destino y responsable válidos, sin dobles movimientos.  
**Independent Test**: se inicia una OT en cualquier sector productivo o se avanza/salta según matriz; actor, origen, tipo y estado son derivados y un reintento stale no duplica.  
**Traceability**: US3; FR-044–045, FR-050–060, FR-063, FR-078; SC-002–003, SC-005; CT `mover_ot`.

### Tests for User Story 3 — escribir primero y comprobar fallo

- [ ] T051 [P] [US3] Escribir pgTAP de `mover_ot` para INICIO/AVANCE, matriz por códigos/orden, ALMACEN, responsable/sector Activos, actor de otro sector, locks, `expected_last_movement_id` y doble envío en `supabase/tests/database/120_move_ot_rpc.test.sql`
- [ ] T052 [P] [US3] Escribir unit tests de acciones/destinos derivados y traducción de conflictos funcionales en `frontend/tests/unit/otMovementActions.test.js`
- [ ] T053 [P] [US3] Escribir pruebas Testing Library del diálogo destino/responsable, bloqueo mientras envía y refresh ante conflicto en `frontend/tests/integration/us3-move-ot.test.jsx`
- [ ] T054 [P] [US3] Escribir E2E de INICIO variable, salto PRENSA→PRODUCCION y dos contextos enviando simultáneamente en `frontend/tests/e2e/us3-move-ot.spec.js`

### Implementation for User Story 3

- [ ] T055 [US3] Implementar núcleo privado y RPC pública mínima `mover_ot` con lock de OT, actor desde `auth.uid()`, matriz por códigos/orden, validaciones y actualización PENDIENTE→EN_PROCESO atómica en `supabase/migrations/202610060013_move_ot_rpc.sql`
- [ ] T056 [US3] Endurecer EXECUTE/grants y pruebas de `SECURITY DEFINER` con `search_path=''`, permisos mínimos y parámetros no autoritativos en `supabase/migrations/202610060014_rpc_security.sql`
- [ ] T057 [P] [US3] Implementar servicio de destinos/responsables Activos y `mover_ot` con expected-last en `frontend/src/features/ot/api/otMovementService.js`
- [ ] T058 [P] [US3] Implementar diálogo accesible de envío con acciones nombradas por destino y selección obligatoria de responsable en `frontend/src/features/ot/components/MoveOtDialog.jsx`
- [ ] T059 [US3] Integrar acciones INICIO/AVANCE por permisos/estado/sector en `frontend/src/features/ot/components/OtActions.jsx`
- [ ] T060 [US3] Añadir feedback controlado de conflicto, relectura canónica y prevención visual de doble clic sin sustituir la idempotencia del servidor en `frontend/src/features/ot/hooks/useOtMovement.js`

**Checkpoint**: US3 es funcional; una operación válida produce exactamente un movimiento.

---

## Phase 6: User Story 4 — Usuario devuelve una OT y conserva el ciclo (Priority: P1)

**Goal**: devolver a sectores anteriores y preservar cada visita/ciclo sin registrar motivo.  
**Independent Test**: PRODUCCION→PRENSA→PRE_ACABADO→PRODUCCION crea visitas separadas, no altera movimientos y no solicita motivo.  
**Traceability**: US4; FR-051–061, FR-069, FR-072, FR-078; SC-002–003; CT `mover_ot`.

### Tests for User Story 4 — escribir primero y comprobar fallo

- [ ] T061 [P] [US4] Ampliar pgTAP con DEVOLUCION, ciclos repetidos, inmovilidad histórica y ausencia de campo/motivo en `supabase/tests/database/121_return_cycles.test.sql`
- [ ] T062 [P] [US4] Escribir pruebas Testing Library para acciones “Devolver a…”, sin motivo, responsable destino y ciclo renderizado completo en `frontend/tests/integration/us4-return-ot.test.jsx`
- [ ] T063 [P] [US4] Escribir E2E PRODUCCION→PRENSA→PRE_ACABADO→PRODUCCION y verificar filas históricas independientes en `frontend/tests/e2e/us4-return-cycle.spec.js`

### Implementation for User Story 4

- [ ] T064 [US4] Completar derivación AVANCE/DEVOLUCION y matriz de regreso por código/orden, manteniendo la corrección administrativa explícita, en `supabase/migrations/202610060013_move_ot_rpc.sql`
- [ ] T065 [P] [US4] Extender el modelo de acciones del cliente para destinos de devolución sin campo de motivo en `frontend/src/features/ot/api/otMovementService.js`
- [ ] T066 [US4] Integrar devoluciones y refresco append-only del recorrido en `frontend/src/features/ot/components/OtActions.jsx` y `frontend/src/features/ot/pages/OtDetailPage.jsx`

**Checkpoint**: US4 es funcional; ciclos y devoluciones no destruyen historia.

---

## Phase 7: User Story 5 — Usuario marca una OT como terminada (Priority: P1)

**Goal**: finalizar manualmente solo desde PRODUCCION y cerrar la última etapa sin nuevo movimiento.  
**Independent Test**: llegar a PRODUCCION mantiene EN_PROCESO; la acción autorizada fija TERMINADO/`terminado_en`, es idempotente y bloquea movimientos posteriores.  
**Traceability**: US5; FR-046–048, FR-059, FR-071, FR-078; SC-002, SC-004, SC-008; CT `finalizar_ot`.

### Tests for User Story 5 — escribir primero y comprobar fallo

- [ ] T067 [P] [US5] Escribir pgTAP de `finalizar_ot` para rol/sector/estado, expected-last, reintento idempotente, `terminado_en` servidor y bloqueo de movimientos posteriores en `supabase/tests/database/130_finish_ot_rpc.test.sql`
- [ ] T068 [P] [US5] Escribir pruebas Testing Library de visibilidad, confirmación, carga, éxito y conflictos de “Marcar como terminado” en `frontend/tests/integration/us5-finish-ot.test.jsx`
- [ ] T069 [P] [US5] Escribir E2E llegada a PRODUCCION sin autofinalizar, finalización manual y rechazo de nuevo movimiento en `frontend/tests/e2e/us5-finish-ot.spec.js`

### Implementation for User Story 5

- [ ] T070 [US5] Implementar RPC `finalizar_ot` con lock, permisos, estado/sector, expected-last, idempotencia por resultado canónico, auditoría y timestamp servidor en `supabase/migrations/202610060015_finish_ot_rpc.sql`
- [ ] T071 [P] [US5] Implementar servicio y hook de finalización con refresh canónico en `frontend/src/features/ot/api/otLifecycleService.js` y `frontend/src/features/ot/hooks/useOtLifecycle.js`
- [ ] T072 [US5] Integrar acción y confirmación accesible de finalización según permisos en `frontend/src/features/ot/components/OtActions.jsx`

**Checkpoint**: US5 completa el recorrido principal del MVP desde creación hasta TERMINADO.

---

## Phase 8: User Story 6 — Administrador consulta y corrige una OT (Priority: P2)

**Goal**: editar/corregir, anular o eliminar únicamente según estado, con auditoría e integridad.  
**Independent Test**: las políticas PENDIENTE/EN_PROCESO/TERMINADO/ANULADO se cumplen; anular cierra tiempo en `anulado_en`; eliminar solo borra una PENDIENTE sin movimientos y conserva auditoría.  
**Traceability**: US6; FR-006, FR-029–030, FR-048–049, FR-062, FR-071, FR-073–078; SC-010, SC-015–016; CT `actualizar_ot`, `anular_ot`, `eliminar_ot`.

### Tests for User Story 6 — escribir primero y comprobar fallo

- [ ] T073 [P] [US6] Escribir pgTAP de actualizar/anular/eliminar para políticas por estado, optimistic `modificado_en`, corrección excepcional, cascadas/RESTRICT, auditoría sobreviviente y reintentos en `supabase/tests/database/140_admin_ot_lifecycle.test.sql`
- [ ] T074 [P] [US6] Escribir pgTAP específico del cierre temporal ANULADO con `anulado_en` inmutable ante correcciones posteriores y sin movimiento ficticio en `supabase/tests/database/141_annulled_timing.test.sql`
- [ ] T075 [P] [US6] Escribir pruebas Testing Library de edición por estado, confirmaciones, conflictos, corrección de recorrido y eliminación restringida en `frontend/tests/integration/us6-admin-correct-ot.test.jsx`
- [ ] T076 [P] [US6] Escribir E2E de editar PENDIENTE, corregir EN_PROCESO/terminal, anular y eliminar permitido/rechazado en `frontend/tests/e2e/us6-admin-correct-ot.spec.js`

### Implementation for User Story 6

- [ ] T077 [US6] Implementar RPC `actualizar_ot` con lock, expected `modificado_en`, reemplazo agregado validado, política por estado y auditoría completa en `supabase/migrations/202610060016_update_ot_rpc.sql`
- [ ] T078 [US6] Implementar RPC `anular_ot` idempotente que fija ANULADO/`anulado_en`, no crea movimiento y conserva cierre ante correcciones posteriores en `supabase/migrations/202610060017_annul_delete_ot_rpc.sql`
- [ ] T079 [US6] Implementar RPC `eliminar_ot` idempotente solo para PENDIENTE sin movimientos, auditando antes de cascadas operativas y sin FK/cascada a auditoría, en `supabase/migrations/202610060017_annul_delete_ot_rpc.sql`
- [ ] T080 [P] [US6] Implementar servicios de actualización/anulación/eliminación con tokens esperados y errores funcionales en `frontend/src/features/ot/api/otAdminService.js`
- [ ] T081 [P] [US6] Implementar página de edición reutilizando el formulario y solicitando confirmación excepcional en estados terminales en `frontend/src/features/ot/pages/EditOtPage.jsx`
- [ ] T082 [US6] Integrar anulación, eliminación, edición y corrección de recorrido solo para ADMINISTRADOR en `frontend/src/features/ot/components/OtAdminActions.jsx` y `frontend/src/features/ot/pages/OtDetailPage.jsx`

**Checkpoint**: US6 es funcional; ninguna política de estado depende solo de botones ocultos.

---

## Phase 9: User Story 7 — Administrador gestiona usuarios y datos maestros (Priority: P2)

**Goal**: administrar cuentas, perfiles, clientes, catálogos, materiales, sectores y responsables sin romper historia.  
**Independent Test**: ADMINISTRADOR invita/asigna/inactiva usuarios y mantiene maestros; USUARIO/Data API no puede hacerlo; inactivos desaparecen de nuevas selecciones pero siguen en históricos.  
**Traceability**: US7; FR-003, FR-006–007, FR-013–023; SC-001, SC-005–006; CT `admin-users`, material config, sector reorder.

### Tests for User Story 7 — escribir primero y comprobar fallo

- [ ] T083 [P] [US7] Escribir pgTAP de CRUD administrativo permitido, inactivación histórica, material–gramaje, reordenamiento, máximo un USUARIO activo por sector y pruebas negativas Data API en `supabase/tests/database/150_master_profile_admin.test.sql`
- [ ] T084 [P] [US7] Escribir tests de Edge Function para JWT, rol activo, validación, invite/reanudación/compensación y ausencia de secretos en respuestas en `supabase/functions/admin-users/index.test.js`
- [ ] T085 [P] [US7] Escribir pruebas Testing Library de clientes, catálogos, sectores, responsables y perfiles con controles Activo/Inactivo en `frontend/tests/integration/us7-admin-masters-users.test.jsx`
- [ ] T086 [P] [US7] Escribir E2E de gestión Admin y rechazo directo/UI al USUARIO, incluyendo cliente inactivo histórico y recuperación del invitado, en `frontend/tests/e2e/us7-admin-management.spec.js`

### Implementation for User Story 7

- [ ] T087 [US7] Implementar RPC `guardar_material_configuracion` con transacción y regla `requiere_gramaje` sin `gramaje_id` en piso en `supabase/migrations/202610060018_master_admin_rpcs.sql`
- [ ] T088 [US7] Implementar RPC `reordenar_sectores` serializada, orden único positivo y ALMACEN fuera del flujo en `supabase/migrations/202610060018_master_admin_rpcs.sql`
- [ ] T089 [US7] Implementar Edge Function `admin-users` para invitar, enlazar perfil, asignar rol/sector, activar/inactivar y reanudar fallos parciales con secretos solo servidor en `supabase/functions/admin-users/index.js`
- [ ] T090 [P] [US7] Implementar servicios administrativos para clientes y catálogos con CREATE/UPDATE/Activo-Inactivo, sin DELETE normal, en `frontend/src/features/clientes/api/clientService.js` y `frontend/src/features/catalogos/api/catalogService.js`
- [ ] T091 [P] [US7] Implementar servicios de materiales/gramajes, sectores/reordenamiento y responsables por sector en `frontend/src/features/catalogos/api/materialService.js` y `frontend/src/features/sectores/api/sectorService.js`
- [ ] T092 [P] [US7] Implementar servicio cliente de la Edge Function y gestión de perfiles/roles/sector en `frontend/src/features/usuarios/api/userAdminService.js`
- [ ] T093 [P] [US7] Implementar páginas administrativas de clientes y catálogos con formularios accesibles y estado histórico en `frontend/src/features/clientes/pages/ClientsPage.jsx` y `frontend/src/features/catalogos/pages/CatalogsPage.jsx`
- [ ] T094 [P] [US7] Implementar páginas de sectores/responsables con orden y participación en flujo visibles en `frontend/src/features/sectores/pages/SectorsPage.jsx` y `frontend/src/features/sectores/pages/ResponsiblesPage.jsx`
- [ ] T095 [US7] Implementar página de usuarios/perfiles, guards ADMINISTRADOR y rutas administrativas en `frontend/src/features/usuarios/pages/UsersPage.jsx` y `frontend/src/app/router.jsx`

**Checkpoint**: US7 es funcional; inactivar preserva todas las referencias históricas y no hay auto-registro.

---

## Phase 10: User Story 8 — Usuario o Administrador consulta el recorrido (Priority: P2)

**Goal**: mostrar recorrido append-only, situación actual y tiempos derivados por visita, incluidos cierres terminales.  
**Independent Test**: una OT con ciclo repetido presenta cada entrada/salida/responsable/actor/tipo y calcula tiempos con siguiente movimiento, ahora, `terminado_en` o `anulado_en`.  
**Traceability**: US8; FR-068–072; SC-003–004; DM Read Models; CT OT detail and route.

### Tests for User Story 8 — escribir primero y comprobar fallo

- [ ] T096 [P] [US8] Escribir pgTAP de `vista_recorrido_ot` para orden total, `lead`, visitas repetidas y cierres actual/TERMINADO/ANULADO sin persistir duración en `supabase/tests/database/160_route_times.test.sql`
- [ ] T097 [P] [US8] Escribir pruebas Testing Library del timeline con origen/destino/responsable/actor/tipo, visitas repetidas y tiempos accesibles en `frontend/tests/integration/us8-route-history.test.jsx`
- [ ] T098 [P] [US8] Escribir E2E de consulta de recorrido por USUARIO autorizado y ADMINISTRADOR, incluyendo ciclo y tiempos terminales en `frontend/tests/e2e/us8-route-history.spec.js`

### Implementation for User Story 8

- [ ] T099 [US8] Crear vista `security_invoker` de recorrido con tiempos derivados y cierre por siguiente movimiento, `now()`, `terminado_en` o `anulado_en` en `supabase/migrations/202610060019_route_time_view.sql`
- [ ] T100 [P] [US8] Extender servicio de detalle para recorrido paginado/ordenado y etiquetas históricas en `frontend/src/features/ot/api/otHistoryService.js`
- [ ] T101 [P] [US8] Implementar timeline responsive y resumen de tiempo derivado por sector sin mezclar auditoría en `frontend/src/features/ot/components/OtRouteTimeline.jsx`
- [ ] T102 [US8] Integrar recorrido y situación actual en detalle respetando RLS del OT visible en `frontend/src/features/ot/pages/OtDetailPage.jsx`

**Checkpoint**: US8 es funcional; sector/responsable y tiempos se derivan de hechos, no de columnas duplicadas.

---

## Phase 11: User Story 9 — Administrador consulta la auditoría (Priority: P3)

**Goal**: consultar eventos CREATE/UPDATE/DELETE y cambios JSONB inmutables, separados del recorrido.  
**Independent Test**: ADMINISTRADOR filtra un evento y ve actor/instante/atributo/antes/después incluso después de borrar la OT; USUARIO y DML normal son rechazados.  
**Traceability**: US9; FR-007, FR-030, FR-074–077; SC-010; CT Audit list/detail.

### Tests for User Story 9 — escribir primero y comprobar fallo

- [ ] T103 [P] [US9] Escribir pgTAP de cobertura CREATE/UPDATE/DELETE, JSONB, supervivencia tras DELETE, inmutabilidad y SELECT solo ADMINISTRADOR en `supabase/tests/database/170_audit_visibility.test.sql`
- [ ] T104 [P] [US9] Escribir pruebas Testing Library de listado/filtros/detalle, render seguro de JSONB y separación visual del recorrido en `frontend/tests/integration/us9-audit.test.jsx`
- [ ] T105 [P] [US9] Escribir E2E de auditoría de OT/maestros/perfiles, persistencia tras borrar OT y rechazo al USUARIO en `frontend/tests/e2e/us9-audit.spec.js`

### Implementation for User Story 9

- [ ] T106 [US9] Crear función/vista de lectura `security_invoker` y índices finales para auditoría paginada por entidad, clave, operación, actor y tiempo en `supabase/migrations/202610060020_audit_read_model.sql`
- [ ] T107 [P] [US9] Implementar servicio paginado y mapeo de eventos/cambios JSONB en `frontend/src/features/auditoria/api/auditService.js`
- [ ] T108 [US9] Implementar páginas ADMINISTRADOR de listado y detalle de auditoría con filtros y rutas protegidas en `frontend/src/features/auditoria/pages/AuditPage.jsx`, `frontend/src/features/auditoria/pages/AuditDetailPage.jsx` y `frontend/src/app/router.jsx`

**Checkpoint**: las nueve historias son funcionales y comprobables; movimiento y auditoría conservan finalidades distintas.

---

## Phase 12: Polish, validación integral y preparación de despliegue

**Purpose**: verificar el MVP completo, rendimiento, responsive, accesibilidad, seguridad, documentación y gates no bloqueantes de producción.  
**Traceability**: SC-001–016; PL Testing/Deployment/Observability/Continuity; Quickstart Completion evidence; Constitution III, V, IX, XIV.

- [ ] T109 [P] Crear suite E2E integral que encadene las nueve historias sin sustituir sus pruebas independientes en `frontend/tests/e2e/mvp-end-to-end.spec.js` (SC-001–003)
- [ ] T110 [P] Añadir axe en login, formulario OT, listado/detalle, movimiento, administración y auditoría, con aserciones WCAG 2.2 AA automatizables, en `frontend/tests/e2e/accessibility-critical-flows.spec.js` (PL Accessibility)
- [ ] T111 Ejecutar y documentar revisión manual de teclado, foco visible/no oculto, contraste, labels, errores, zoom/reflow y targets táctiles en `specs/003-operacion-sistema-ot/evidence/accessibility-check.md` (Constitution III/IX; WCAG objective)
- [ ] T112 [P] Validar responsive y smoke en Chrome/Edge/Safari vigentes sobre desktop/laptop, Android, iPhone/iPad, registrando versiones y resultados en `specs/003-operacion-sistema-ot/evidence/browser-responsive-matrix.md` (PL Responsive)
- [ ] T113 Generar dataset sintético no histórico de 19.000 OT para entorno local/pruebas y documentar que no es migración de la base anterior en `supabase/tests/fixtures/performance_seed.sql` (PL Capacity; Spec future scope)
- [ ] T114 Medir `EXPLAIN (ANALYZE, BUFFERS)` de último movimiento, listado keyset/filtros y auditoría; ajustar solo índices con evidencia en una migración nueva y registrar resultados en `supabase/migrations/202610060021_measured_indexes.sql` y `specs/003-operacion-sistema-ot/evidence/query-plans.md` (PL Pagination/Performance)
- [ ] T115 [P] Ejecutar pruebas de 10 sesiones concurrentes para movimiento, doble envío, expected-last y optimistic `modificado_en`, registrando ausencia de corrupción/deadlocks persistentes en `frontend/tests/e2e/concurrency-smoke.spec.js` y `specs/003-operacion-sistema-ot/evidence/concurrency.md` (PL Concurrency)
- [ ] T116 [P] Verificar build, variables Vite, source maps, bundle y repositorio para asegurar que no contienen contraseñas, tokens, `sb_secret_*` ni `service_role`, documentando resultado en `specs/003-operacion-sistema-ot/evidence/secrets-build-check.md` (Constitution V; Research §3)
- [ ] T117 Configurar GitHub Actions para lint, build, unit/component, pgTAP y E2E smoke sin credenciales productivas en `.github/workflows/ci.yml` (PL Testing/Deployment)
- [ ] T118 Configurar Vercel para SPA/rewrite y documentar Development/Preview/Production con Preview apuntando solo a Supabase no productivo en `vercel.json` y `docs/deployment.md` (PL Deployment)
- [ ] T119 Documentar instalación y ejecución PowerShell, Supabase local, migraciones, seeds, primer ADMINISTRADOR, frontend y todas las suites en `README.md` y actualizar comandos verificados en `specs/003-operacion-sistema-ot/quickstart.md` (Quickstart)
- [ ] T120 Documentar logging seguro, correlation IDs, fuentes Supabase/Vercel, mensajes funcionales y runbook básico de incidentes sin datos sensibles en `docs/observability-and-errors.md` (PL Observability)
- [ ] T121 Registrar gates no bloqueantes previos a producción —SMTP, retención de auditoría/logs, plan PITR/RPO≤1h, simulacro RTO≤2h, región/coste, SLI 99.5%, medición RLS y búsqueda textual— en `docs/production-readiness.md` sin activarlos ni desplegar (PL Continuity; Research §§16–17)
- [ ] T122 Ejecutar la matriz final de build, suites, RLS negativo, permisos, auditoría, concurrencia, responsive y accesibilidad; enlazar evidencias y registrar aprobación humana pendiente en `specs/003-operacion-sistema-ot/evidence/mvp-validation.md` (SC-001–016; Quickstart Completion evidence)

**Checkpoint final**: MVP implementado y validado en local/entorno seguro; producción continúa bloqueada por revisión humana y gates T121. No se ha migrado la base histórica ni desplegado automáticamente.

---

## Dependencies & Execution Order

### Phase dependencies

1. **Phase 1 — Setup**: inicia inmediatamente.
2. **Phase 2 — Foundational**: depende de Phase 1; T010→T011→T027/T028 (fallo esperado) precede T012–T026 y T027/T028 se repiten al cierre hasta aprobar. Bloquea todas las historias.
3. **US1–US9**: dependen de Phase 2. El orden recomendado respeta el recorrido del MVP: US1 → US2 → US3 → US4 → US5 → US6 → US7 → US8 → US9.
4. **Phase 12**: depende de todas las historias seleccionadas; T113 precede T114, T117 precede la validación CI de T122 y T121 no bloquea desarrollo pero sí producción.

### User story dependency graph

```text
Setup → Foundational
               ├─→ US1 Crear OT ─→ US3 Movimiento ─→ US4 Devolución ─→ US5 Finalización
               │                         └──────────────→ US6 Corrección/ciclo de vida
               ├─→ US2 Consulta ───────────────────────→ US8 Recorrido/tiempos
               ├─→ US7 Administración de maestros/usuarios
               └─→ US9 Auditoría (usa eventos generados por las demás historias)

US1..US9 → Validación integral → Preparación (no despliegue) de producción
```

- **US1**: independiente tras Foundation usando seeds aprobados.
- **US2**: independiente tras Foundation con fixtures de OT/movimientos; no requiere la UI de US1.
- **US3**: requiere una OT existente (fixture o US1) y responsable existente (fixture o US7).
- **US4**: reutiliza el contrato de US3 y añade DEVOLUCION/ciclos.
- **US5**: requiere la situación EN_PROCESO en PRODUCCION generable por fixture/US3.
- **US6**: reutiliza el agregado de US1 y movimiento de US3 para probar todas las políticas.
- **US7**: independiente tras Foundation; sus maestros mejoran la operación real de US1/US3.
- **US8**: requiere movimientos generables por fixtures/US3/US4 y timestamps terminales de US5/US6.
- **US9**: el lector es independiente, pero su aceptación integral usa eventos de US1/US6/US7.

### Within each user story

1. Escribir pruebas y comprobar que fallan por la capacidad ausente.
2. Implementar migración/RPC/vista y seguridad servidor.
3. Implementar servicios/validadores frontend.
4. Implementar UI e integración.
5. Ejecutar pgTAP + unit/component + E2E de la historia y detenerse en su checkpoint.

## Parallel Opportunities

- En Setup, T002/T003/T005/T007/T008 pueden ejecutarse en paralelo después de T001 cuando no toquen el mismo archivo.
- En Foundation, T027/T028 se escriben en paralelo antes de las migraciones; tras comprobar su fallo esperado, T023/T025/T026 pueden avanzar en paralelo donde no compartan archivos y las suites se repiten al cierre.
- Las tareas de pruebas `[P]` de cada historia pueden escribirse en paralelo antes de implementar.
- Tras Foundation, US1, US2 y US7 pueden desarrollarse en paralelo; US3 puede usar fixtures sin esperar la UI de US7.
- US8 y US9 pueden implementar sus lectores en paralelo cuando existan los hechos/vistas base.
- En validación final, T109/T110/T112/T115/T116 avanzan en paralelo; T122 espera sus evidencias.

## Parallel examples

### US1

```text
T029 pgTAP crear_ot
T030 unit tests formulario
T031 component tests formulario
T032 E2E creación/idempotencia
```

### US3

```text
T051 pgTAP movimiento/concurrencia
T052 unit tests acciones
T053 component tests diálogo
T054 E2E inicio/salto/doble envío
```

### US7

```text
T083 pgTAP maestros/perfiles
T084 tests Edge Function
T085 component tests administración
T086 E2E permisos administrativos
```

## Implementation Strategy

### MVP principal por incrementos

1. Completar Setup + Foundational y demostrar esquema/RLS.
2. Entregar US1 para producir OT válidas.
3. Entregar US2 para acceso y consulta sectorial.
4. Entregar US3 + US4 + US5 para el ciclo productivo completo.
5. Entregar US6 + US7 para control administrativo.
6. Entregar US8 + US9 para seguimiento y control visible.
7. Ejecutar Phase 12 y obtener revisión humana antes de cualquier producción.

### Definition of done por tarea/historia

- La tarea modifica solo los artefactos nombrados o actualiza explícitamente su referencia.
- Las reglas críticas se validan en PostgreSQL/RPC/RLS y se complementan en frontend.
- Las pruebas negativas demuestran que Data API/RPC no permiten evadir permisos.
- Los reintentos críticos retornan resultado canónico o conflicto controlado, nunca un duplicado.
- No aparecen nuevas entidades de negocio, roles, catálogos ni reglas no aprobadas.
- No se usan IDs numéricos como reglas funcionales y no se exponen secretos.

## Notes

- La clave `idempotencia_creacion` y `anulado_en` son metadatos técnicos autorizados y formalizados mediante la enmienda controlada del 2026-10-06; T010–T011 están satisfechas documentalmente, sin ejecutar implementación.
- La migración histórica permanece futura: el dataset T113 es sintético y solo valida capacidad.
- `total_pliegos` continúa como entero positivo registrado; ninguna tarea calcula una fórmula.
- T121 recopila decisiones/gates de producción, pero no bloquea el desarrollo local del MVP.
- No se ejecuta despliegue como parte de este archivo; se preparan y validan artefactos.
