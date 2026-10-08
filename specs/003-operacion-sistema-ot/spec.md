# Especificación: Spec 003 — Operación funcional del sistema de Órdenes de Trabajo

**Directorio**: `specs/003-operacion-sistema-ot`
**Creada**: 2026-10-06
**Estado**: ENMENDADA (2026-10-08) — pendiente de aprobación y de replanificación
**Tipo**: Especificación funcional del MVP
**Fuentes**: Constitution v1.1.0, Spec 000 v1.1.0, Spec 001, Spec 002 con Enmienda 3 y reglas funcionales proporcionadas para Spec 003
**Contrato estructural**: Spec 002 — Diccionario de Datos, aprobada el 2026-10-06 con enmiendas
controladas del 2026-10-06 y Enmienda 3 del 2026-10-08
**Input**: Definir la operación funcional del sistema desde la creación de una OT hasta su finalización o anulación, sin redefinir el modelo de datos.

## Clarifications

### Session 2026-10-06

- Q: ¿La devolución de una OT debe registrar motivo? → A: No se registra motivo de devolución en el MVP.
- Q: ¿Quién selecciona al responsable del sector destino? → A: La persona autorizada que confirma
  el movimiento selecciona un responsable Activo del sector destino antes de confirmarlo.
- Q: ¿Cómo acceden y recuperan el acceso las personas usuarias? → A: Mediante correo y contraseña,
  con recuperación de contraseña por correo; las cuentas son creadas por ADMINISTRADOR y no existe
  auto-registro público.
- Q: ¿Qué información cubre la auditoría visible? → A: ~~Operaciones `CREATE`, `UPDATE` y `DELETE`
  sobre OT, pisos, acabados, clientes, catálogos, sectores, responsables, perfiles y asignaciones de
  rol.~~ **Reemplazada por la Enmienda funcional del 2026-10-08**: no hay auditoría visible; solo
  trazabilidad de creación y última modificación.
- Q: ¿Qué edición, anulación y eliminación se permite según el estado de la OT? → A: `PENDIENTE`
  admite edición administrativa y anulación (la eliminación física fue retirada por la Enmienda
  funcional del 2026-10-08); `EN_PROCESO` admite
  correcciones trazadas y anulación, pero no eliminación; `TERMINADO` y `ANULADO` admiten consulta
  y correcciones administrativas excepcionales trazadas, sin eliminación ni movimientos. Una OT
  terminada no vuelve automáticamente a `EN_PROCESO` y la anulación no exige motivo en el MVP.

### Session 2026-10-08

- Q: ¿Cómo obtiene su primera contraseña una persona cuya cuenta acaba de crear el ADMINISTRADOR?
  → A: Recibe en su correo un enlace de invitación de un solo uso y con caducidad para definir su
  contraseña; si caduca, el ADMINISTRADOR puede reenviarlo.
- Q: ¿Qué debe pasar cuando alguien falla varias veces seguidas la contraseña de una misma cuenta?
  → A: Tras 5 intentos fallidos consecutivos la cuenta se bloquea 15 minutos y luego se desbloquea
  sola; durante el bloqueo se puede recuperar la contraseña por correo; el mensaje de error es
  siempre el mismo.
- Q: ¿Qué requisitos mínimos debe cumplir una contraseña? → A: Mínimo 8 caracteres, sin más reglas.
- Q: ¿Puede el ADMINISTRADOR revertir una anulación hecha por error? → A: Sí. La OT vuelve al estado
  que tenía antes (`PENDIENTE` si no tiene movimientos, `EN_PROCESO` si los tiene), se borra
  `anulado_en` y se actualiza la trazabilidad.

## Enmienda técnica controlada — 2026-10-06

La enmienda posterior a aprobación de Spec 002 formaliza dos metadatos de `orden_trabajo` sin
cambiar el comportamiento empresarial clarificado:

- `idempotencia_creacion`: clave técnica durable, única y no visible que identifica una operación
  de creación agregada. La misma solicitud repetida con la misma clave devuelve el resultado ya
  procesado y no crea otra OT.
- `anulado_en`: momento confiable establecido por servidor/base de datos al cambiar atómicamente a
  `ANULADO`; cierra la última permanencia productiva sin persistir `duracion_sector`.

`terminado_en` ya estaba aprobado y continúa cerrando la última permanencia cuando la OT pasa
atómicamente a `TERMINADO`. Esta enmienda no reabre las decisiones funcionales de Clarify.

## Enmienda funcional — 2026-10-08

Alinea esta Spec con la Constitution v1.1.0, la Spec 000 v1.1.0 y la Enmienda 3 de Spec 002:

- **Auditoría**: se retira la consulta de auditoría (User Story 9) y el historial de valores
  anteriores y nuevos. Cada registro editable conserva quién lo creó, cuándo, quién lo modificó por
  última vez y cuándo. `movimiento_ot` sigue siendo el historial funcional del recorrido.
- **Eliminación**: ninguna OT se elimina físicamente. Una OT que no debe trabajarse se anula.
- **Autenticación**: el acceso lo gestiona el backend del sistema (Spec 000 v1.1.0) en lugar de
  Supabase Auth. Correo y contraseña, cuentas creadas por ADMINISTRADOR y recuperación por correo se
  mantienen sin cambios funcionales.
- **Requisitos afectados**: FR-002, FR-006, FR-007, FR-014, FR-016, FR-029, FR-030, FR-073 a
  FR-077; SC-010, SC-011, SC-015, SC-016; User Stories 6 y 9.
- **Consecuencia**: `plan.md`, `research.md`, `data-model.md`, `contracts/`, `quickstart.md` y
  `tasks.md` quedan obsoletos y deben regenerarse con `/speckit-plan` y `/speckit-tasks`.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Administrador crea y prepara una OT (Priority: P1)

Como ADMINISTRADOR, quiero registrar una Orden de Trabajo con sus datos generales, pisos y acabados
para dejarla disponible con información válida antes de iniciar su recorrido productivo.

**Why this priority**: Sin una OT válida no existe trabajo que consultar, mover o terminar.

**Independent Test**: Un ADMINISTRADOR puede crear una OT sin introducir el correlativo, con cero a
tres pisos válidos y con estado inicial `PENDIENTE`, sin iniciar todavía el flujo productivo.

**Acceptance Scenarios**:

1. **Given** un ADMINISTRADOR autenticado y datos válidos, **When** crea una OT, **Then** el sistema
   exige un cliente Activo, asigna un código automático único, conserva la fecha seleccionada y
   establece `PENDIENTE`.
2. **Given** una OT que todavía no requiere detalle de producción, **When** se crea sin pisos,
   **Then** la OT es válida y puede completarse posteriormente por un ADMINISTRADOR.
3. **Given** una OT con varios pisos, **When** se confirma, **Then** solo se admiten 1; 1–2; o 1–2–3
   y cada piso cumple las reglas de material, dimensiones, montaje, impresión, máquina y muestrario
   aprobadas en Spec 002.
4. **Given** una OT con acabados, **When** se confirma, **Then** no se repite ningún acabado y los
   acabados especiales incluyen una posición válida.
5. **Given** una creación cuya respuesta se perdió o fue reenviada, **When** se repite exactamente la
   misma solicitud con su clave de idempotencia estable, **Then** el sistema devuelve un resultado
   coherente de la operación ya procesada y no crea una segunda OT.

---

### User Story 2 - Usuario visualiza las OT de su sector (Priority: P1)

Como USUARIO asignado a un sector, quiero iniciar sesión y consultar las OT que actualmente debe
procesar mi sector para concentrarme en el trabajo que me corresponde.

**Why this priority**: La consulta por sector es la entrada principal a la operación cotidiana.

**Independent Test**: Un USUARIO autenticado ve exclusivamente OT cuyo sector actual coincide con
su sector, puede buscar, filtrar, paginar y abrir el detalle necesario para trabajar.

**Acceptance Scenarios**:

1. **Given** un USUARIO activo de PRENSA, **When** abre el listado operativo, **Then** ve las OT cuyo
   sector actual es PRENSA y no obtiene control administrativo sobre las demás.
2. **Given** un listado con múltiples resultados, **When** busca, filtra o cambia de página, **Then**
   recibe un subconjunto navegable sin cargar todas las OT simultáneamente.
3. **Given** una OT visible para el USUARIO, **When** abre su detalle, **Then** puede consultar la
   información general, pisos, acabados, estado, sector y responsable actuales y recorrido.
4. **Given** una cuenta activa creada por ADMINISTRADOR, **When** la persona introduce correo y
   contraseña válidos, **Then** accede conforme al rol y sector de su perfil.
5. **Given** una persona que olvidó su contraseña, **When** solicita recuperarla, **Then** el sistema
   ofrece recuperación por correo sin habilitar auto-registro público.

---

### User Story 3 - Usuario selecciona responsable y envía una OT (Priority: P1)

Como USUARIO del sector actual, quiero enviar una OT a un destino permitido y seleccionar un
responsable activo del destino para que el siguiente sector reciba el trabajo con trazabilidad.

**Why this priority**: El movimiento entre sectores materializa el flujo productivo principal.

**Independent Test**: Una OT `PENDIENTE` puede iniciar en cualquier sector productivo permitido y
una OT `EN_PROCESO` puede avanzar, incluso saltando sectores, mediante un nuevo movimiento que no
sobrescribe el historial.

**Acceptance Scenarios**:

1. **Given** una OT `PENDIENTE`, **When** un ADMINISTRADOR registra su primer ingreso a un sector
   productivo y elige un responsable activo de ese destino, **Then** se agrega un `INICIO` y el
   estado cambia a `EN_PROCESO`.
2. **Given** una OT en PRENSA, **When** el USUARIO autorizado la envía directamente a PRODUCCIÓN con
   un responsable activo de PRODUCCIÓN, **Then** se agrega un `AVANCE` y la OT permanece
   `EN_PROCESO`.
3. **Given** un destino o responsable inválido, **When** se intenta confirmar el envío, **Then** no
   se registra el movimiento y se explica la corrección necesaria.
4. **Given** un destino permitido, **When** la persona autorizada aún no seleccionó un responsable
   Activo perteneciente al destino, **Then** el movimiento permanece sin confirmar.

---

### User Story 4 - Usuario devuelve una OT y conserva el ciclo (Priority: P1)

Como USUARIO del sector actual, quiero devolver una OT a un sector anterior cuando exista un error o
sea necesario repetir trabajo para corregir la producción sin perder el recorrido ya realizado.

**Why this priority**: Las devoluciones y repeticiones son parte del proceso real y deben conservar
responsabilidades y tiempos.

**Independent Test**: Una OT puede recorrer PRENSA → PRE_ACABADO → PRODUCCIÓN → PRENSA y repetir el
ciclo; cada transición queda como una fila histórica independiente.

**Acceptance Scenarios**:

1. **Given** una OT en PRODUCCIÓN, **When** se devuelve a PRENSA con un responsable válido, **Then**
   se agrega una `DEVOLUCION` sin editar ni eliminar movimientos anteriores.
2. **Given** una OT devuelta que vuelve a avanzar, **When** completa nuevamente parte del recorrido,
   **Then** cada visita aparece por separado y sus tiempos pueden reconstruirse.
3. **Given** una devolución válida sin motivo, **When** el usuario la confirma, **Then** el sistema
   registra el movimiento sin exigir ni almacenar un motivo en el MVP.

---

### User Story 5 - Usuario marca una OT como terminada (Priority: P1)

Como USUARIO autorizado de PRODUCCIÓN, quiero marcar manualmente una OT como terminada cuando el
trabajo realmente haya concluido para cerrar su ciclo sin confundir llegada con finalización.

**Why this priority**: La finalización explícita protege la diferencia entre ubicación y estado.

**Independent Test**: Una OT en PRODUCCIÓN permanece `EN_PROCESO` hasta ejecutar la acción de
finalización; entonces queda `TERMINADO` y se cierra el tiempo de su última etapa.

**Acceptance Scenarios**:

1. **Given** una OT `EN_PROCESO` cuyo sector actual es PRODUCCIÓN, **When** el USUARIO de ese sector
   la marca como terminada, **Then** cambia a `TERMINADO` y se conserva el momento de finalización.
2. **Given** una OT que llega a PRODUCCIÓN, **When** no se ejecuta la acción de finalización,
   **Then** permanece `EN_PROCESO`.
3. **Given** una OT `TERMINADO`, **When** se intenta un nuevo avance o devolución normal, **Then** la
   operación se rechaza.

---

### User Story 6 - Administrador consulta y corrige una OT (Priority: P2)

Como ADMINISTRADOR, quiero consultar todas las OT, corregir sus datos autorizados y resolver una
ubicación operativa errónea para mantener información útil sin reescribir la historia.

**Why this priority**: Las excepciones reales requieren control administrativo y trazabilidad.

**Independent Test**: Un ADMINISTRADOR puede aplicar la edición o anulación permitida por el estado
de la OT y corregir el recorrido agregando un movimiento válido; toda corrección actualiza la
trazabilidad de última modificación y el recorrido anterior permanece inmutable.

**Acceptance Scenarios**:

1. **Given** una OT `PENDIENTE`, **When** el ADMINISTRADOR edita sus datos dentro de las reglas de
   integridad, **Then** se guardan los nuevos valores y la OT registra quién la modificó por última
   vez y cuándo.
2. **Given** una OT `EN_PROCESO` ubicada en un sector incorrecto, **When** el ADMINISTRADOR corrige
   el recorrido, **Then** agrega un movimiento hacia un sector productivo válido y no modifica ni
   elimina el recorrido previo.
3. **Given** una OT `PENDIENTE` o `EN_PROCESO`, **When** el ADMINISTRADOR confirma su anulación sin
   indicar un motivo, **Then** queda `ANULADO`, registra `anulado_en`, cierra la permanencia
   productiva abierta cuando existe y no admite movimientos productivos nuevos.
4. **Given** una OT `PENDIENTE` sin movimientos productivos que ya no debe trabajarse, **When** el
   ADMINISTRADOR la retira, **Then** queda `ANULADO` con `anulado_en` y conserva su código, pisos y
   acabados.
5. **Given** una OT `TERMINADO` o `ANULADO` con un error administrativo real, **When** el
   ADMINISTRADOR realiza una corrección excepcional, **Then** los valores cambian y se actualiza la
   trazabilidad de última modificación, sin generar movimientos ni cambiar el estado terminal.
6. **Given** cualquier OT, **When** se intenta eliminarla físicamente por cualquier vía, **Then** el
   sistema no ofrece esa operación y la rechaza, cualquiera sea su estado.
7. **Given** una OT anulada por error, **When** el ADMINISTRADOR confirma revertir la anulación,
   **Then** vuelve a `PENDIENTE` o `EN_PROCESO` según tenga o no movimientos, `anulado_en` queda sin
   valor y su recorrido no cambia.

---

### User Story 7 - Administrador gestiona usuarios y datos maestros (Priority: P2)

Como ADMINISTRADOR, quiero crear y administrar cuentas, roles asignados, clientes, catálogos,
sectores y responsables para mantener disponibles las opciones vigentes de operación.

**Why this priority**: El flujo depende de identidades y datos maestros controlados.

**Independent Test**: El ADMINISTRADOR puede crear una cuenta sin auto-registro público, asignarle
uno de los dos roles aprobados y activar o inactivar datos maestros sin romper registros históricos.

**Acceptance Scenarios**:

1. **Given** una nueva persona usuaria, **When** el ADMINISTRADOR crea su cuenta y perfil, **Then**
   asigna `ADMINISTRADOR` o `USUARIO`; si es `USUARIO`, también asigna su sector; y la persona recibe
   por correo un enlace de invitación para definir su contraseña.
5. **Given** una invitación caducada o no recibida, **When** el ADMINISTRADOR la reenvía, **Then** se
   emite un enlace nuevo y el anterior deja de ser válido.
2. **Given** un cliente, catálogo o responsable activo, **When** se inactiva, **Then** deja de
   aparecer en selecciones nuevas y permanece identificable en registros históricos.
3. **Given** un sector con historial, **When** se inactiva o cambia su nombre visible, **Then** sus
   movimientos anteriores siguen siendo consultables y no se convierten en destinos nuevos.
4. **Given** una persona sin cuenta del sistema, **When** se registra como responsable de sector,
   **Then** puede ser seleccionada en movimientos sin convertirse en USUARIO.

---

### User Story 8 - Usuario o Administrador consulta el recorrido (Priority: P2)

Como persona autorizada para consultar una OT, quiero ver su recorrido completo y los tiempos por
sector para conocer dónde estuvo, quién intervino y cuánto duró cada visita.

**Why this priority**: El seguimiento convierte los movimientos en información operativa útil.

**Independent Test**: A partir de los movimientos y de los momentos terminales se muestran origen,
destino, responsable, actor, momento, tipo y duración derivada de cada visita, incluidas visitas
repetidas.

**Acceptance Scenarios**:

1. **Given** una OT con avances y devoluciones, **When** se consulta el recorrido, **Then** aparecen
   todos los movimientos en orden, sin colapsar visitas repetidas.
2. **Given** una OT en proceso, **When** se consulta su etapa actual, **Then** el tiempo mostrado se
   deriva desde su última entrada hasta el momento de consulta.
3. **Given** una OT terminada, **When** se consulta la última etapa, **Then** su duración termina en
   el momento de finalización y no sigue aumentando.
4. **Given** una OT anulada después de iniciar su recorrido, **When** se consulta la última etapa,
   **Then** su duración termina en `anulado_en` y no sigue aumentando.

---

### User Story 9 - RETIRADA (Enmienda funcional 2026-10-08)

La consulta de auditoría de cambios fue retirada del MVP. La numeración se conserva para no alterar
la trazabilidad de las historias 1 a 8.

### Edge Cases

- Una OT puede crearse sin pisos y permanecer válida; no se crea un piso vacío implícito.
- Si se incluye un piso, todos sus datos obligatorios deben completarse antes de confirmar; el
  sistema conserva los demás valores al señalar un campo incompleto.
- No se puede crear el piso 2 sin el 1 ni el piso 3 sin los pisos 1 y 2.
- Un cliente Inactivo no puede seleccionarse al crear una OT nueva.
- Una OT histórica continúa mostrando correctamente a su cliente aunque este haya sido inactivado.
- Inactivar un cliente con OT existentes no elimina ni rompe las relaciones históricas.
- Un material inactivo permanece visible en una OT histórica, pero no puede elegirse para un piso
  nuevo o reemplazado.
- Un sector inactivo permanece visible en el recorrido histórico, pero no es un destino nuevo.
- Un responsable inactivo permanece visible en movimientos anteriores, pero no puede asignarse en
  un movimiento nuevo.
- Una OT `ANULADO` no puede avanzar, devolverse, terminarse ni generar otro movimiento productivo.
- Una OT `TERMINADO` no puede avanzar ni devolverse por el flujo normal.
- Un avance puede saltar uno o más sectores permitidos sin crear movimientos ficticios intermedios.
- Una devolución agrega historia y nunca sobrescribe el avance que la antecedió.
- Una devolución válida puede confirmarse sin motivo; el MVP no solicita ni almacena ese dato.
- Una OT puede repetir un ciclo completo o parcial; cada visita conserva su propio responsable y
  duración.
- Un USUARIO no puede mover una OT cuyo sector actual no coincide con el sector de su perfil.
- Un USUARIO no puede eliminar una OT ni usar funciones administrativas ocultas o directas.
- Un movimiento no se confirma hasta que quien lo ejecuta selecciona un responsable Activo del
  sector destino; la llegada no queda pendiente de una asignación posterior por el receptor.
- Una corrección de recorrido por ADMINISTRADOR agrega un movimiento válido; no altera movimientos
  históricos.
- ALMACÉN no puede elegirse como destino productivo aunque exista y esté activo como área.
- Un responsable de un sector distinto al destino no puede confirmarse para el movimiento.
- Ninguna OT puede eliminarse físicamente, cualquiera sea su estado o la existencia de movimientos;
  se retira mediante anulación.
- Una corrección administrativa excepcional sobre una OT `TERMINADO` o `ANULADO` conserva su
  estado terminal, no genera un movimiento productivo y actualiza su trazabilidad de última
  modificación.
- La anulación válida de una OT `PENDIENTE` o `EN_PROCESO` puede confirmarse sin indicar motivo.
- Al anular una OT que tiene una etapa productiva abierta, `anulado_en` cierra esa permanencia; su
  duración no continúa creciendo y no se almacena una columna `duracion_sector`.
- Un reintento de creación con la misma `idempotencia_creacion` no debe crear otra OT; edición,
  movimiento, devolución, finalización o anulación tampoco deben repetir efectos sin
  verificar estado, locks y precondiciones aprobadas.
- Un enlace de invitación caducado, ya usado o reemplazado por un reenvío no permite definir la
  contraseña; la persona debe solicitar un nuevo envío al ADMINISTRADOR.
- Un sexto intento con la contraseña correcta dentro de los 15 minutos de bloqueo se rechaza con el
  mismo mensaje genérico; no revela que la cuenta está bloqueada.
- Una contraseña de menos de 8 caracteres se rechaza al aceptar una invitación o completar una
  recuperación, explicando el mínimo requerido y sin consumir el enlace.
- Al revertir la anulación de una OT `EN_PROCESO`, la permanencia de su etapa actual vuelve a
  derivarse desde su última entrada hasta el momento de consulta, incluyendo el tiempo que estuvo
  anulada.
- Una OT `TERMINADO` no admite reversión de anulación ni reapertura por esta vía.
- Si la sesión deja de ser válida durante una operación, no se confirma un resultado ambiguo y se
  orienta al usuario para recuperar el acceso de forma segura.

## Requirements *(mandatory)*

### Alcance y contrato funcional

- **FR-001**: El sistema DEBE operar sobre el contrato estructural aprobado en Spec 002 y NO DEBE
  crear entidades, atributos o relaciones alternativas desde esta especificación funcional.
- **FR-002**: El MVP DEBE cubrir acceso, roles, datos maestros, creación, consulta, edición
  autorizada, estados, sectores, responsables, movimientos, devoluciones, finalización, seguimiento,
  historial funcional, trazabilidad de creación y última modificación, búsqueda, filtros y
  paginación.
- **FR-003**: Los únicos roles iniciales DEBEN ser `ADMINISTRADOR` y `USUARIO`; `CLIENTE` y
  `VENDEDOR` NO DEBEN existir como roles.
- **FR-004**: Estado de OT, sector actual, responsable actual y actor autenticado DEBEN mantenerse
  como conceptos diferentes de acuerdo con Spec 002.

### Acceso, roles y permisos

- **FR-005**: Toda operación de negocio DEBE requerir una identidad autenticada y un perfil activo
  autorizado. Las únicas operaciones sin sesión permitidas son presentar el acceso, autenticar por
  correo/contraseña, aceptar una invitación definiendo la contraseña y solicitar o completar la
  recuperación de contraseña; ninguna de ellas habilita
  auto-registro ni acceso a datos del negocio.
- **FR-006**: El `ADMINISTRADOR` DEBE poder ver todas las OT; crear, editar, corregir y anular OT;
  moverlas y corregir recorridos; administrar usuarios, asignaciones de rol, clientes, catálogos,
  sectores y responsables; y consultar recorrido y trazabilidad.
- **FR-007**: Ningún rol DEBE poder establecer ni alterar manualmente los atributos de trazabilidad
  (creado por/en, modificado por/en); los asigna exclusivamente el backend.
- **FR-008**: Cada `USUARIO` DEBE pertenecer a un sector operativo.
- **FR-009**: La vista operativa y la búsqueda del `USUARIO` DEBEN limitarse en el MVP a las OT cuyo
  sector actual coincide con el sector de su perfil; al abrir una de ellas, DEBE poder consultar su
  información completa y el recorrido histórico por otros sectores necesario para trabajar.
- **FR-010**: El `USUARIO` DEBE poder seleccionar responsables válidos, avanzar o devolver una OT
  desde su sector actual, consultar el recorrido y finalizarla cuando corresponda.
- **FR-011**: El `USUARIO` NO DEBE eliminar OT, administrar usuarios, roles, clientes, catálogos,
  sectores o responsables, ni modificar libremente la información estructural de una OT.
- **FR-012**: Ocultar una acción NO DEBE considerarse suficiente para autorizarla; toda operación
  protegida DEBE validar el rol, el sector y el estado aplicables.

### Autenticación y cuentas

- **FR-013**: La creación y administración de cuentas DEBE corresponder únicamente al
  `ADMINISTRADOR`; no se aprueba auto-registro público.
- **FR-013a**: Al crear una cuenta, el sistema DEBE enviar al correo de la persona un enlace de
  invitación de un solo uso y con caducidad para que defina su contraseña. El ADMINISTRADOR NO DEBE
  definir ni conocer contraseñas ajenas. Una cuenta sin invitación aceptada NO DEBE poder iniciar
  sesión. El ADMINISTRADOR DEBE poder reenviar la invitación, lo que invalida el enlace anterior.
- **FR-014**: La identidad autenticada DEBE gestionarse en el backend del sistema conforme a Spec 000
  v1.1.0, usando la cuenta de `perfil_usuario` definida por Spec 002; la contraseña solo se almacena
  como hash y las sesiones, invitaciones y recuperaciones usan `token_usuario`.
- **FR-015**: Al crear o editar un perfil, el `ADMINISTRADOR` DEBE asignar uno de los dos roles
  aprobados y, para `USUARIO`, un sector activo, respetando la regla de Spec 002 de máximo un
  `USUARIO` operativo activo por sector en un momento determinado.
- **FR-016**: Un perfil inactivo NO DEBE iniciar nuevas operaciones y DEBE permanecer identificable
  en movimientos históricos y como actor de trazabilidad.
- **FR-017**: El acceso DEBE realizarse mediante correo y contraseña y la recuperación de contraseña
  DEBE ofrecerse por correo. La sesión DEBE respetar la continuidad y terminación funcionales de
  Spec 001; sus tiempos y configuración técnica corresponden a Plan.
- **FR-017a**: Tras 5 intentos fallidos consecutivos de inicio de sesión sobre una misma cuenta, el
  sistema DEBE bloquear su inicio de sesión durante 15 minutos y desbloquearla automáticamente al
  vencer ese plazo. Un acceso exitoso reinicia el conteo. Durante el bloqueo DEBE seguir disponible
  la recuperación de contraseña por correo, y completarla desbloquea la cuenta. El mensaje ante
  credenciales incorrectas, cuenta bloqueada o correo inexistente DEBE ser idéntico.
- **FR-017b**: Al definir o restablecer una contraseña, el sistema DEBE exigir un mínimo de 8
  caracteres y NO DEBE imponer otras reglas de composición ni caducidad periódica.

### Administración de datos maestros

- **FR-018**: Solo el `ADMINISTRADOR` DEBE administrar clientes, tipos de material, materiales,
  gramajes, máquinas, tipos de trabajo, colorimetrías, impresiones, muestrarios, acabados, sectores y
  responsables. Administrar clientes incluye crear, consultar, editar, activar e inactivar; la
  eliminación física de clientes no es una operación normal aprobada.
- **FR-019**: Los registros maestros con estado Activo/Inactivo DEBEN excluir los valores inactivos
  de nuevas selecciones y conservarlos visibles con su significado en registros históricos.
- **FR-020**: Los registros maestros usados históricamente NO DEBEN eliminarse de forma que se
  pierda la trazabilidad; deben inactivarse cuando así lo exige Spec 002.
- **FR-021**: Un responsable DEBE ser una persona física perteneciente a un sector y NO DEBE
  requerir cuenta del sistema.
- **FR-022**: Los sectores productivos iniciales DEBEN ser DISEÑO, PRENSA, PRE_ACABADO y PRODUCCIÓN;
  ALMACÉN DEBE existir como área que prepara material, pero NO como destino productivo de OT.
- **FR-023**: El `ADMINISTRADOR` DEBE poder crear, editar, activar, inactivar y ordenar sectores sin
  convertir el orden general en una ruta universal obligatoria.

### Creación y edición de OT

- **FR-024**: Solo el `ADMINISTRADOR` DEBE crear una OT.
- **FR-025**: El código de OT DEBE asignarse automáticamente, ser único y NO DEBE ser introducido
  manualmente.
- **FR-026**: La fecha de OT DEBE ser obligatoria y permitir selección manual.
- **FR-027**: La cantidad DEBE ser un entero mayor que cero; `cantidad_paginas` DEBE ser opcional y
  permanecer sin valor cuando no aplica.
- **FR-028**: La creación DEBE exigir un cliente Activo, un tipo de trabajo activo y un nombre de
  trabajo; la OT nueva DEBE iniciar en `PENDIENTE`. Un cliente que se inactive posteriormente DEBE
  continuar visible en las OT históricas y su inactivación NO DEBE bloquear su consulta.
- **FR-029**: El `ADMINISTRADOR` DEBE poder editar libremente una OT `PENDIENTE` dentro de las reglas
  de integridad; en `EN_PROCESO` DEBE limitarse a correcciones trazadas; y en `TERMINADO` o
  `ANULADO` solo DEBE realizar correcciones administrativas excepcionales por errores reales,
  siempre trazadas y sin cambiar automáticamente el estado terminal.
- **FR-030**: Toda creación o edición DEBE registrar quién la realizó y cuándo en los atributos de
  trazabilidad del registro; el MVP NO conserva valores anteriores.

### Pisos, producción y acabados

- **FR-031**: Una OT DEBE admitir cero, uno, dos o tres pisos; cuando existan, DEBEN ser consecutivos
  desde el piso 1.
- **FR-032**: Una OT sin pisos DEBE poder existir inicialmente sin incumplir la especificación.
- **FR-033**: Cada piso existente DEBE cumplir las reglas aprobadas en Spec 002 para material,
  dimensiones X/Y, armado, formato, total de pliegos, colorimetría, cara de color, impresión,
  máquina, muestrario, dimensiones finales y de corte y cara de acabado.
- **FR-034**: Cada piso DEBE tener exactamente un material, una máquina, una colorimetría, una
  impresión y un muestrario; el muestrario es obligatorio.
- **FR-035**: Los valores de colorimetría iniciales DEBEN ser `FULL_COLOR`, `PANTONE` y
  `FULL_MAS_PANTONE`; `cara_color` DEBE admitir `ANVERSO`, `REVERSO` o `AMBAS`.
- **FR-036**: Los valores de impresión iniciales DEBEN ser `TIRO_Y_VOLTEO`, `TIRA_Y_RETIRA` y
  `CAMBIO_DE_PINZA`; pisos distintos PUEDEN utilizar impresiones y máquinas distintas.
- **FR-037**: Materiales distintos PUEDEN utilizarse en pisos distintos y DEBE mantenerse la
  relación conceptual `tipo_material` → `material` → `gramaje` cuando corresponda, sin duplicar un
  gramaje en el piso.
- **FR-038**: `armado` y `formato` DEBEN ser enteros introducidos por el usuario, mayores que cero y
  cumplir `formato >= armado`; NO se exige divisibilidad exacta.
- **FR-039**: `total_pliegos` DEBE registrarse como entero positivo mientras no exista una fórmula
  empresarial aprobada; esta Spec NO automatiza su cálculo.
- **FR-040**: Una OT DEBE admitir cero o más acabados sin repetir el mismo acabado.
- **FR-041**: `PERFORADO`, `ENGOMADO`, `ANILLADO` y `ENGRAMPADO` DEBEN exigir `IZQUIERDA` o `ARRIBA`
  como posición global de la OT; para los demás acabados la posición no aplica.
- **FR-042**: `cara_acabado` DEBE continuar tratándose por piso conforme a Spec 002 y NO DEBE crear
  una relación acabado–piso diferente.

### Estados y ciclo de vida

- **FR-043**: Los estados iniciales DEBEN ser `PENDIENTE`, `EN_PROCESO`, `TERMINADO` y `ANULADO`.
- **FR-044**: Una OT creada DEBE iniciar `PENDIENTE`; su primer movimiento `INICIO` DEBE cambiarla a
  `EN_PROCESO`.
- **FR-045**: Los movimientos `AVANCE` y `DEVOLUCION` DEBEN conservar `EN_PROCESO`.
- **FR-046**: La llegada a PRODUCCIÓN NO DEBE finalizar automáticamente una OT.
- **FR-047**: La finalización DEBE ser una acción explícita aplicable a una OT `EN_PROCESO` cuyo
  sector actual sea PRODUCCIÓN; puede ejecutarla el `USUARIO` de ese sector o un `ADMINISTRADOR`,
  debe establecer `TERMINADO` y conservar el momento de cierre.
- **FR-048**: El flujo normal NO DEBE retroceder una OT desde `TERMINADO` o `ANULADO` ni generar
  movimientos productivos nuevos para esos estados. La única excepción es la reversión de anulación
  de FR-049a.
- **FR-049**: Solo el `ADMINISTRADOR` DEBE anular una OT `PENDIENTE` o `EN_PROCESO`; el MVP NO DEBE
  exigir motivo de anulación. Una OT `TERMINADO` o `ANULADO` NO DEBE anularse nuevamente; la reversión de
  una anulación se rige exclusivamente por FR-049a. El cambio a `ANULADO` y el registro servidor de `anulado_en` DEBEN ser
  atómicos; ese momento cierra la última permanencia productiva cuando existe.
- **FR-049a**: Solo el `ADMINISTRADOR` DEBE poder revertir la anulación de una OT `ANULADO`, previa
  confirmación explícita. La OT DEBE volver a `PENDIENTE` si no tiene movimientos productivos o a
  `EN_PROCESO` si los tiene; `anulado_en` DEBE quedar sin valor en la misma operación atómica y la
  trazabilidad de última modificación DEBE actualizarse. La reversión NO DEBE crear, editar ni
  eliminar movimientos.
### Sectores, responsables y movimientos

- **FR-050**: Una OT DEBE poder iniciar en DISEÑO, PRENSA, PRE_ACABADO o PRODUCCIÓN, según el trabajo,
  sin exigir el paso previo por DISEÑO.
- **FR-051**: El primer ingreso al flujo DEBE registrarse como `INICIO`; un envío posterior a un
  sector de orden mayor DEBE registrarse como `AVANCE`; un regreso a uno anterior DEBE registrarse
  como `DEVOLUCION`.
- **FR-052**: Cada movimiento DEBE agregar un hecho nuevo con origen, destino, responsable del
  destino, actor autenticado, fecha/hora y tipo; NO DEBE sobrescribir movimientos anteriores.
- **FR-053**: Para confirmar un movimiento, el destino DEBE estar activo, participar en el flujo y
  ser diferente del origen; el responsable DEBE estar activo y pertenecer al destino.
- **FR-054**: El actor autorizado que confirma el movimiento DEBE seleccionar antes de confirmarlo,
  en esa misma operación, un responsable Activo del sector destino; no existe una llegada sin
  responsable pendiente de asignación posterior por el sector receptor.
- **FR-055**: El `USUARIO` solo DEBE mover una OT cuando su sector coincide con el sector actual de
  la OT; el `ADMINISTRADOR` puede moverla o corregir su recorrido dentro de las reglas de integridad.
- **FR-056**: Desde DISEÑO se DEBE permitir avanzar a PRENSA, PRE_ACABADO o PRODUCCIÓN cuando el
  trabajo lo requiera.
- **FR-057**: Desde PRENSA se DEBE permitir avanzar a PRE_ACABADO o PRODUCCIÓN y devolver a DISEÑO.
- **FR-058**: Desde PRE_ACABADO se DEBE permitir avanzar a PRODUCCIÓN y devolver a PRENSA o DISEÑO.
- **FR-059**: Desde PRODUCCIÓN se DEBE permitir finalizar y devolver a PRE_ACABADO, PRENSA o DISEÑO.
- **FR-060**: La matriz anterior DEBE funcionar como definición inicial administrable y NO DEBE
  convertirse en una ruta universal que obligue a pasar por todos los sectores.
- **FR-061**: Una devolución DEBE conservar el historial previo y permitir ciclos repetidos; el MVP
  NO DEBE solicitar ni almacenar un motivo de devolución.
- **FR-062**: La corrección de recorrido por un `ADMINISTRADOR` DEBE conservar los hechos previos y
  agregar el movimiento válido necesario para restablecer la ubicación actual; NO DEBE editar ni
  eliminar movimientos históricos.
- **FR-063**: Las acciones disponibles DEBEN expresar el destino o resultado funcional aplicable y
  NO limitarse conceptualmente a una única acción “Siguiente”; esta Spec no prescribe su diseño.

### Consulta, seguimiento e historial

- **FR-064**: El `ADMINISTRADOR` DEBE consultar todas las OT y el `USUARIO` DEBE consultar
  exclusivamente las OT de su sector actual; ninguna búsqueda, filtro, paginación o acceso directo
  al detalle DEBE revelar una OT de otro sector.
- **FR-065**: Los listados DEBEN soportar búsqueda por código, cliente o nombre de trabajo, filtros
  por estado, sector, responsable y fecha, paginación y apertura de detalle.
- **FR-066**: El listado DEBE permitir reconocer como mínimo código OT, cliente, nombre del trabajo,
  fecha, estado, sector actual y responsable actual, sin fijar un diseño visual.
- **FR-067**: El sistema NO DEBE cargar todas las OT simultáneamente; debe presentar resultados
  paginados o graduales conforme a Spec 001.
- **FR-068**: El detalle DEBE permitir consultar datos generales, pisos, acabados, estado, sector y
  responsable actuales, recorrido y acciones autorizadas.
- **FR-069**: El recorrido DEBE mostrar sector de origen, sector de destino, responsable físico,
  usuario que realizó el movimiento, fecha/hora y tipo de cada movimiento.
- **FR-070**: El sector y responsable actuales DEBEN derivarse del último movimiento y NO DEBEN
  confundirse con el estado de la OT.
- **FR-071**: El tiempo de cada visita a un sector DEBE derivarse desde su entrada hasta el siguiente
  movimiento; para la visita actual, hasta el momento de consulta; para la última etapa terminada,
  hasta `terminado_en`; y para la última etapa anulada, hasta `anulado_en`.
- **FR-072**: Las visitas repetidas a un mismo sector DEBEN mostrarse por separado y PUEDEN sumarse
  para presentar un total derivado, sin almacenar una duración duplicada.

### Retiro de OT y trazabilidad

- **FR-073**: Ninguna OT DEBE eliminarse físicamente, por ningún rol ni vía. Para retirar una OT
  `PENDIENTE` o `EN_PROCESO`, el `ADMINISTRADOR` DEBE anularla conforme a FR-049, previa
  confirmación explícita.
- **FR-074**: Una OT anulada DEBE conservar su código, cabecera, pisos, acabados y movimientos; su
  código correlativo NO DEBE reutilizarse.
- **FR-075**: El `ADMINISTRADOR` DEBE poder consultar, en el detalle de OT, clientes, catálogos,
  sectores, responsables y perfiles, quién creó el registro, cuándo, quién lo modificó por última vez
  y cuándo.
- **FR-076**: *(Retirado por la Enmienda funcional 2026-10-08: no existe auditoría inmutable de
  eventos.)*
- **FR-077**: `movimiento_ot` DEBE ser el único historial funcional del recorrido; los atributos de
  trazabilidad NO DEBEN interpretarse como recorrido ni reemplazarlo.
- **FR-078**: La creación agregada DEBE usar una `idempotencia_creacion` técnica, durable, estable y
  única para esa operación; repetir exactamente la misma solicitud con la misma clave DEBE devolver
  un resultado coherente ya procesado y NO DEBE duplicar OT, pisos ni acabados. Los movimientos,
  finalizaciones, anulaciones y demás escrituras DEBEN impedir efectos repetidos mediante sus
  estados esperados, locks y precondiciones técnicas, sin depender únicamente de la interfaz.

### Key Entities *(referenciadas desde Spec 002)*

Spec 003 no redefine entidades. Utiliza conceptualmente las 15 entidades lógicas de Spec 002:

- **Núcleo de OT**: `cliente`, `orden_trabajo`, `ot_detalle` y `ot_acabado` sostienen creación,
  consulta y edición autorizada. `cliente.estado` determina su disponibilidad para nuevas OT sin
  romper las referencias históricas.
- **Materiales y recursos**: `tipo_material`, `material`, `gramaje` y `maquina` proveen selecciones
  activas y preservan referencias históricas.
- **Catálogos**: `parametro` contiene tipo de trabajo, estado, colorimetría, impresión, muestrario y
  acabado mediante los grupos aprobados.
- **Acceso**: `rol`, `perfil_usuario` y `token_usuario` representan los dos roles, la cuenta de
  acceso con contraseña en hash y las sesiones, invitaciones y recuperaciones.
- **Operación física**: `sector`, `responsable_sector` y `movimiento_ot` representan ubicación,
  responsabilidad física y recorrido productivo.
- **Trazabilidad**: cada entidad editable conserva creado por/en y modificado por/en; no existe una
  entidad de auditoría.

### Matriz funcional inicial de destinos

| Situación actual | Acciones normales permitidas | Acciones no permitidas |
|---|---|---|
| `PENDIENTE`, sin movimiento | Editar; anular con confirmación; `INICIO` hacia DISEÑO, PRENSA, PRE_ACABADO o PRODUCCIÓN por ADMINISTRADOR | Eliminación física; inicio hacia ALMACÉN |
| DISEÑO | Avanzar a PRENSA, PRE_ACABADO o PRODUCCIÓN | Devolución normal sin sector anterior |
| PRENSA | Avanzar a PRE_ACABADO o PRODUCCIÓN; devolver a DISEÑO | Avanzar hacia ALMACÉN |
| PRE_ACABADO | Avanzar a PRODUCCIÓN; devolver a PRENSA o DISEÑO | Avanzar hacia ALMACÉN |
| PRODUCCIÓN | Marcar terminado; devolver a PRE_ACABADO, PRENSA o DISEÑO | Finalización automática por llegada |
| `TERMINADO` | Consulta e historial; corrección administrativa excepcional y trazada | Eliminación; avance, devolución o reapertura automática |
| `ANULADO` | Consulta e historial; corrección administrativa excepcional y trazada; revertir anulación por ADMINISTRADOR | Eliminación; inicio, avance, devolución o finalización |

Las OT `EN_PROCESO` admiten correcciones administrativas trazadas y anulación. Ninguna OT admite
eliminación física. Las correcciones excepcionales en estados terminales no modifican movimientos históricos ni
cambian automáticamente el estado.

### Clasificación posterior a Clarify

No quedan decisiones funcionales bloqueantes para planificar el MVP. Los asuntos restantes se
clasifican así para evitar convertir decisiones técnicas o mejoras futuras en ambigüedades del
alcance actual.

**Puede resolverse en Plan**:

- mecanismos de autorización, protección de operaciones y aplicación técnica de permisos;
- tiempos, renovación, revocación y configuración técnica de las sesiones, respetando Spec 001;
- detalles de implementación de locks, precondiciones e idempotencia, respetando los metadatos y
  contratos ya aprobados;
- estrategia técnica de búsqueda, filtros, paginación y capacidad;
- interacción y diseño visual de formularios, acciones, listados y recorridos.

**Puede dejarse para futuro**:

- excepciones adicionales de destinos o reglas especiales por tipo de trabajo; mientras no se
  aprueben, rige la matriz funcional inicial;
- atributos adicionales de `perfil_usuario`; el MVP usa los aprobados en Spec 002;
- fórmula automática de `total_pliegos`; durante el MVP continúa como entero positivo registrado;
- recomendación o copia de rutas para trabajos repetidos;
- correcciones históricas del recorrido que excedan agregar un movimiento compensatorio; los
  movimientos existentes permanecen inmutables;
- incorporación de un historial completo de cambios, si una necesidad real lo justifica
  (Constitution X).

### Futuro y fuera del alcance funcional del MVP actual

Existe una base de datos anterior con aproximadamente 19.000 OT históricas. Migrarla total o
parcialmente es una **posibilidad o requisito futuro a evaluar**, no una obligación aprobada. La
migración histórica no forma parte del alcance principal de Spec 003 y no bloquea Spec 002, Spec 003
ni el desarrollo del nuevo sistema. La referencia de volumen se conserva para búsqueda, paginación
y validaciones de capacidad.

También quedan fuera del alcance funcional del MVP:

- scripts o modificaciones contra la base anterior y la migración de sus datos históricos;
- auto-registro público y nuevos roles;
- reportes o estadísticas avanzadas;
- cálculo automático definitivo de `total_pliegos`;
- copia automática de rutas de trabajos anteriores;
- diseño visual definitivo de acciones, listados, formularios o historial.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de las capacidades de `ADMINISTRADOR` y `USUARIO` descritas en esta Spec puede
  asociarse con al menos un escenario de aceptación o requisito funcional verificable.
- **SC-002**: Una prueba funcional completa puede llevar una OT desde creación `PENDIENTE`, pasando
  por `INICIO`, avances o devoluciones flexibles, hasta `TERMINADO`, sin confundir estado y sector.
- **SC-003**: El 100 % de los movimientos de una OT de prueba, incluidos saltos y ciclos repetidos,
  aparece en orden con origen, destino, responsable, actor, momento y tipo; ninguno puede
  confirmarse sin que el actor seleccione antes un responsable Activo del destino.
- **SC-004**: Los tiempos de todas las visitas de una OT de prueba pueden reconstruirse únicamente
  con movimientos, `terminado_en` o `anulado_en`, sin una duración almacenada separadamente.
- **SC-005**: Ningún USUARIO de prueba puede eliminar OT, administrar datos maestros o mover una OT
  cuyo sector actual no coincide con el suyo.
- **SC-006**: El 100 % de los valores maestros inactivos probados, incluidos los clientes, desaparece
  de nuevas selecciones y permanece reconocible en registros históricos sin romper sus relaciones.
- **SC-007**: Una OT puede crearse con 0, 1, 2 o 3 pisos válidos y se rechazan todos los conjuntos no
  consecutivos o pisos incompletos.
- **SC-008**: Una OT llegada a PRODUCCIÓN permanece `EN_PROCESO` hasta una finalización explícita; el
  100 % de los intentos normales de mover OT `TERMINADO` o `ANULADO` es rechazado.
- **SC-009**: El listado nunca requiere cargar el conjunto completo y permite encontrar una OT por
  búsqueda o filtros y abrir su detalle desde resultados paginados.
- **SC-010**: Para el 100 % de las creaciones y ediciones de prueba sobre OT, pisos, clientes,
  catálogos, sectores, responsables y perfiles, el ADMINISTRADOR puede ver quién creó y quién
  modificó por última vez el registro y cuándo, y ningún cliente de la API puede alterar esos datos.
- **SC-011**: Una revisión documental encuentra cero redefiniciones de las 15 entidades de Spec 002
  y cero confusiones entre usuario autenticado, responsable físico, movimiento y trazabilidad.
- **SC-012**: Toda referencia a la migración de la base anterior la clasifica como futuro fuera del
  MVP y cero requisitos del desarrollo dependen de completarla.
- **SC-013**: Un entorno local o de prueba nuevo puede provisionar exactamente un primer
  `ADMINISTRADOR` mediante el procedimiento privilegiado documentado, sin habilitar auto-registro,
  exponer secretos al frontend ni dejar una ruta pública de bootstrap activa.
- **SC-014**: Una prueba de acceso válida usa correo y contraseña, una prueba de alta completa el
  flujo de invitación por correo hasta el primer acceso, una prueba de recuperación ofrece el flujo
  por correo y ningún recorrido permite auto-registro público.
- **SC-015**: El 100 % de los intentos de eliminar físicamente una OT es rechazado, cualquiera sea su
  estado; una OT retirada queda `ANULADO` y sigue siendo consultable con su código.
- **SC-016**: El 100 % de las correcciones administrativas excepcionales probadas sobre OT
  `TERMINADO` o `ANULADO` actualiza su trazabilidad de última modificación, conserva el estado terminal y no genera movimientos
  productivos; anular una OT válida no exige motivo en el MVP, registra `anulado_en` y cierra su
  última permanencia productiva.
- **SC-017**: En una prueba con 5 contraseñas incorrectas consecutivas, el sexto intento (incluso
  con la contraseña correcta) se rechaza durante 15 minutos, la cuenta vuelve a aceptar acceso al
  vencer el plazo o tras una recuperación completada, y los mensajes de error no permiten distinguir
  cuenta bloqueada, contraseña incorrecta ni correo inexistente.
- **SC-018**: El 100 % de las reversiones de anulación probadas devuelve la OT a `PENDIENTE` (sin
  movimientos) o `EN_PROCESO` (con movimientos), deja `anulado_en` sin valor, conserva intacto el
  recorrido y solo puede ejecutarla un ADMINISTRADOR.

## Assumptions

- Spec 002, aprobada el 2026-10-06, es la fuente de verdad estructural para todas las entidades,
  atributos, relaciones, cardinalidades y dominios mencionados.
- El sistema requiere conexión para autenticar, consultar y confirmar operaciones; no se aprueba
  operación offline.
- El ADMINISTRADOR realiza el primer `INICIO` de una OT `PENDIENTE`; después, el USUARIO del sector
  actual opera avances y devoluciones normales y el ADMINISTRADOR conserva capacidad excepcional.
- Quien confirma un movimiento selecciona un responsable activo del destino en la misma operación,
  porque Spec 002 exige que cada movimiento ya identifique ese responsable.
- Las correcciones administrativas del recorrido son movimientos nuevos que preservan la historia;
  no son ediciones de movimientos existentes.
- Una OT con cero pisos es válida; cualquier piso que sí se incluya debe estar completo.
- Las máquinas actuales se usan en el contexto de PRENSA, pero esta Spec no añade una relación
  estructural máquina–sector que Spec 002 no haya aprobado.
- Las aproximadamente 19.000 OT pertenecen a una base anterior; sirven como referencia de volumen y
  no implican que deban migrarse.
