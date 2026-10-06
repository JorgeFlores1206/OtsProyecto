# Especificación: Spec 003 — Operación funcional del sistema de Órdenes de Trabajo

**Directorio**: `specs/003-operacion-sistema-ot`
**Creada**: 2026-10-06
**Estado**: BORRADOR PARA REVISIÓN HUMANA
**Tipo**: Especificación funcional del MVP
**Fuentes**: Constitution v1.0.0, Spec 000, Spec 001, Spec 002 APROBADA y reglas funcionales proporcionadas para Spec 003
**Contrato estructural**: Spec 002 — Diccionario de Datos, aprobada el 2026-10-06
**Input**: Definir la operación funcional del sistema desde la creación de una OT hasta su finalización o anulación, sin redefinir el modelo de datos.

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

---

### User Story 2 - Usuario visualiza las OT de su sector (Priority: P1)

Como USUARIO asignado a un sector, quiero iniciar sesión y consultar las OT que actualmente debe
procesar mi sector para concentrarme en el trabajo que me corresponde.

**Why this priority**: La consulta por sector es la entrada principal a la operación cotidiana.

**Independent Test**: Un USUARIO autenticado ve principalmente OT cuyo sector actual coincide con
su sector, puede buscar, filtrar, paginar y abrir el detalle necesario para trabajar.

**Acceptance Scenarios**:

1. **Given** un USUARIO activo de PRENSA, **When** abre el listado operativo, **Then** ve las OT cuyo
   sector actual es PRENSA y no obtiene control administrativo sobre las demás.
2. **Given** un listado con múltiples resultados, **When** busca, filtra o cambia de página, **Then**
   recibe un subconjunto navegable sin cargar todas las OT simultáneamente.
3. **Given** una OT visible para el USUARIO, **When** abre su detalle, **Then** puede consultar la
   información general, pisos, acabados, estado, sector y responsable actuales y recorrido.

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
3. **Given** una devolución sin motivo, **When** la obligatoriedad del motivo aún no ha sido
   aprobada, **Then** esta Spec no la rechaza únicamente por esa ausencia.

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

**Independent Test**: Un ADMINISTRADOR puede editar información permitida, anular o eliminar según
reglas y corregir el recorrido agregando un movimiento válido; los movimientos y eventos de
auditoría anteriores permanecen inmutables.

**Acceptance Scenarios**:

1. **Given** una OT con información corregible, **When** el ADMINISTRADOR la edita, **Then** se
   guardan los nuevos valores y la auditoría permite identificar actor, momento y cambios.
2. **Given** una OT `EN_PROCESO` ubicada en un sector incorrecto, **When** el ADMINISTRADOR corrige
   el recorrido, **Then** agrega un movimiento hacia un sector productivo válido y no modifica ni
   elimina el recorrido previo.
3. **Given** una OT que debe anularse, **When** el ADMINISTRADOR confirma la anulación aplicable,
   **Then** queda `ANULADO` y no admite movimientos productivos nuevos.
4. **Given** una OT eliminable, **When** el ADMINISTRADOR confirma la eliminación, **Then** se
   eliminan sus dependencias operativas conforme a Spec 002 y permanece su auditoría.

---

### User Story 7 - Administrador gestiona usuarios y datos maestros (Priority: P2)

Como ADMINISTRADOR, quiero crear y administrar cuentas, roles asignados, clientes, catálogos,
sectores y responsables para mantener disponibles las opciones vigentes de operación.

**Why this priority**: El flujo depende de identidades y datos maestros controlados.

**Independent Test**: El ADMINISTRADOR puede crear una cuenta sin auto-registro público, asignarle
uno de los dos roles aprobados y activar o inactivar datos maestros sin romper registros históricos.

**Acceptance Scenarios**:

1. **Given** una nueva persona usuaria, **When** el ADMINISTRADOR crea su cuenta y perfil, **Then**
   asigna `ADMINISTRADOR` o `USUARIO`; si es `USUARIO`, también asigna su sector.
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

**Independent Test**: A partir de los movimientos y la finalización se muestran origen, destino,
responsable, actor, momento, tipo y duración derivada de cada visita, incluidas visitas repetidas.

**Acceptance Scenarios**:

1. **Given** una OT con avances y devoluciones, **When** se consulta el recorrido, **Then** aparecen
   todos los movimientos en orden, sin colapsar visitas repetidas.
2. **Given** una OT en proceso, **When** se consulta su etapa actual, **Then** el tiempo mostrado se
   deriva desde su última entrada hasta el momento de consulta.
3. **Given** una OT terminada, **When** se consulta la última etapa, **Then** su duración termina en
   el momento de finalización y no sigue aumentando.

---

### User Story 9 - Administrador consulta la auditoría (Priority: P3)

Como ADMINISTRADOR, quiero consultar la auditoría de cambios para identificar quién creó, modificó o
eliminó información y qué valores cambiaron, sin confundirla con el recorrido productivo.

**Why this priority**: La auditoría respalda control, investigación y responsabilidad administrativa.

**Independent Test**: Un ADMINISTRADOR puede consultar eventos `CREATE`, `UPDATE` y `DELETE` con
actor, momento, atributo, valor anterior y valor nuevo, pero no puede modificarlos ni eliminarlos.

**Acceptance Scenarios**:

1. **Given** una edición auditable, **When** el ADMINISTRADOR consulta su evento, **Then** identifica
   actor, fecha/hora, atributo y valores anterior y nuevo.
2. **Given** una OT eliminada operacionalmente, **When** se consulta la auditoría, **Then** el evento
   y sus cambios continúan disponibles aunque el registro operativo ya no exista.
3. **Given** un movimiento productivo, **When** se consultan recorrido y auditoría, **Then** cada
   vista conserva su finalidad y ninguna reemplaza a la otra.

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
- Una OT puede repetir un ciclo completo o parcial; cada visita conserva su propio responsable y
  duración.
- Un USUARIO no puede mover una OT cuyo sector actual no coincide con el sector de su perfil.
- Un USUARIO no puede eliminar una OT ni usar funciones administrativas ocultas o directas.
- Una corrección de recorrido por ADMINISTRADOR agrega un movimiento válido; no altera movimientos
  históricos.
- ALMACÉN no puede elegirse como destino productivo aunque exista y esté activo como área.
- Un responsable de un sector distinto al destino no puede confirmarse para el movimiento.
- Un reintento de creación, edición, movimiento, devolución, finalización, anulación o eliminación
  no debe producir duplicados ni repetir efectos sin verificar el resultado previo.
- Si la sesión deja de ser válida durante una operación, no se confirma un resultado ambiguo y se
  orienta al usuario para recuperar el acceso de forma segura.

## Requirements *(mandatory)*

### Alcance y contrato funcional

- **FR-001**: El sistema DEBE operar sobre el contrato estructural aprobado en Spec 002 y NO DEBE
  crear entidades, atributos o relaciones alternativas desde esta especificación funcional.
- **FR-002**: El MVP DEBE cubrir acceso, roles, datos maestros, creación, consulta, edición
  autorizada, estados, sectores, responsables, movimientos, devoluciones, finalización, seguimiento,
  historial funcional, auditoría visible, búsqueda, filtros y paginación.
- **FR-003**: Los únicos roles iniciales DEBEN ser `ADMINISTRADOR` y `USUARIO`; `CLIENTE` y
  `VENDEDOR` NO DEBEN existir como roles.
- **FR-004**: Estado de OT, sector actual, responsable actual y actor autenticado DEBEN mantenerse
  como conceptos diferentes de acuerdo con Spec 002.

### Acceso, roles y permisos

- **FR-005**: Toda operación del sistema DEBE requerir una identidad autenticada y un perfil activo
  autorizado, salvo la presentación necesaria para iniciar el acceso.
- **FR-006**: El `ADMINISTRADOR` DEBE poder ver todas las OT; crear, editar, corregir, anular y
  eliminar OT; moverlas y corregir recorridos; administrar usuarios, asignaciones de rol, clientes,
  catálogos, sectores y responsables; y consultar recorrido y auditoría.
- **FR-007**: El `ADMINISTRADOR` NO DEBE poder modificar ni eliminar eventos o cambios históricos de
  auditoría desde la operación normal.
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
- **FR-014**: La identidad autenticada DEBE gestionarse mediante Supabase Auth, como tecnología
  aprobada en Spec 000, y vincularse al perfil definido por Spec 002, sin guardar contraseñas en
  datos del negocio.
- **FR-015**: Al crear o editar un perfil, el `ADMINISTRADOR` DEBE asignar uno de los dos roles
  aprobados y, para `USUARIO`, un sector activo, respetando la regla de Spec 002 de máximo un
  `USUARIO` operativo activo por sector en un momento determinado.
- **FR-016**: Un perfil inactivo NO DEBE iniciar nuevas operaciones y DEBE permanecer identificable
  en movimientos y auditorías históricas.
- **FR-017**: El método exacto de acceso, la recuperación de contraseña y la política detallada de
  sesiones NO quedan fijados por esta Spec y deberán respetar las restricciones de Specs 000 y 001.

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
- **FR-029**: El `ADMINISTRADOR` DEBE poder editar los datos autorizados de una OT respetando estado,
  integridad, referencias históricas y auditoría.
- **FR-030**: Toda edición auditable DEBE conservar actor, fecha/hora y valores relevantes anteriores
  y nuevos conforme al modelo aprobado.

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
  movimientos productivos nuevos para esos estados.
- **FR-049**: Solo el `ADMINISTRADOR` DEBE anular una OT; la regla inicial permite anular una OT
  `PENDIENTE` o `EN_PROCESO`. Cualquier excepción desde un estado terminal queda como candidato de
  Clarify.

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
- **FR-054**: El actor autorizado que confirma el movimiento DEBE seleccionar en esa misma operación
  un responsable activo del sector destino, de modo compatible con la obligatoriedad estructural de
  Spec 002.
- **FR-055**: El `USUARIO` solo DEBE mover una OT cuando su sector coincide con el sector actual de
  la OT; el `ADMINISTRADOR` puede moverla o corregir su recorrido dentro de las reglas de integridad.
- **FR-056**: Desde DISEÑO se DEBE permitir avanzar a PRENSA, PRE_ACABADO o PRODUCCIÓN cuando el
  trabajo lo requiera.
- **FR-057**: Desde PRENSA se DEBE permitir avanzar a PRE_ACABADO o PRODUCCIÓN y devolver a DISEÑO.
- **FR-058**: Desde PRE_ACABADO se DEBE permitir avanzar a PRODUCCIÓN y devolver a PRENSA o DISEÑO.
- **FR-059**: Desde PRODUCCIÓN se DEBE permitir finalizar y devolver a PRE_ACABADO, PRENSA o DISEÑO.
- **FR-060**: La matriz anterior DEBE funcionar como definición inicial administrable y NO DEBE
  convertirse en una ruta universal que obligue a pasar por todos los sectores.
- **FR-061**: Una devolución DEBE conservar el historial previo y permitir ciclos repetidos; esta
  Spec NO exige todavía un motivo de devolución.
- **FR-062**: La corrección de recorrido por un `ADMINISTRADOR` DEBE conservar los hechos previos y
  agregar el movimiento válido necesario para restablecer la ubicación actual; NO DEBE editar ni
  eliminar movimientos históricos.
- **FR-063**: Las acciones disponibles DEBEN expresar el destino o resultado funcional aplicable y
  NO limitarse conceptualmente a una única acción “Siguiente”; esta Spec no prescribe su diseño.

### Consulta, seguimiento e historial

- **FR-064**: El `ADMINISTRADOR` DEBE consultar todas las OT y el `USUARIO` DEBE consultar
  principalmente las OT de su sector actual.
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
  hasta el momento de finalización.
- **FR-072**: Las visitas repetidas a un mismo sector DEBEN mostrarse por separado y PUEDEN sumarse
  para presentar un total derivado, sin almacenar una duración duplicada.

### Eliminación y auditoría visible

- **FR-073**: Solo el `ADMINISTRADOR` DEBE eliminar una OT y la acción DEBE requerir confirmación
  explícita de su consecuencia.
- **FR-074**: La eliminación DEBE tratar las dependencias operativas según el contrato de Spec 002,
  generar la auditoría correspondiente y NO eliminar el historial de auditoría.
- **FR-075**: El `ADMINISTRADOR` DEBE poder consultar auditoría de operaciones `CREATE`, `UPDATE` y
  `DELETE` con actor, fecha/hora, atributo, valor anterior y valor nuevo.
- **FR-076**: Los eventos y cambios de auditoría DEBEN ser inmutables desde la operación normal.
- **FR-077**: `movimiento_ot` DEBE representar el historial funcional del recorrido y la auditoría
  DEBE representar cambios de control; una vista NO DEBE reemplazar ni reinterpretar a la otra.
- **FR-078**: Los reintentos de operaciones DEBEN verificar el resultado previo y NO DEBEN duplicar
  OT, pisos, acabados, movimientos, finalizaciones ni eventos de auditoría.

### Key Entities *(referenciadas desde Spec 002)*

Spec 003 no redefine entidades. Utiliza conceptualmente las 16 entidades lógicas de Spec 002:

- **Núcleo de OT**: `cliente`, `orden_trabajo`, `ot_detalle` y `ot_acabado` sostienen creación,
  consulta y edición autorizada. `cliente.estado` determina su disponibilidad para nuevas OT sin
  romper las referencias históricas.
- **Materiales y recursos**: `tipo_material`, `material`, `gramaje` y `maquina` proveen selecciones
  activas y preservan referencias históricas.
- **Catálogos**: `parametro` contiene tipo de trabajo, estado, colorimetría, impresión, muestrario y
  acabado mediante los grupos aprobados.
- **Acceso**: `rol` y `perfil_usuario` representan los dos roles y su vínculo con la identidad
  autenticada; no almacenan contraseñas.
- **Operación física**: `sector`, `responsable_sector` y `movimiento_ot` representan ubicación,
  responsabilidad física y recorrido productivo.
- **Control**: `auditoria_evento` y `auditoria_cambio` representan la historia inmutable de cambios,
  separada del recorrido productivo.

### Matriz funcional inicial de destinos

| Situación actual | Acciones normales permitidas | Acciones no permitidas |
|---|---|---|
| `PENDIENTE`, sin movimiento | `INICIO` hacia DISEÑO, PRENSA, PRE_ACABADO o PRODUCCIÓN por ADMINISTRADOR | Inicio hacia ALMACÉN |
| DISEÑO | Avanzar a PRENSA, PRE_ACABADO o PRODUCCIÓN | Devolución normal sin sector anterior |
| PRENSA | Avanzar a PRE_ACABADO o PRODUCCIÓN; devolver a DISEÑO | Avanzar hacia ALMACÉN |
| PRE_ACABADO | Avanzar a PRODUCCIÓN; devolver a PRENSA o DISEÑO | Avanzar hacia ALMACÉN |
| PRODUCCIÓN | Marcar terminado; devolver a PRE_ACABADO, PRENSA o DISEÑO | Finalización automática por llegada |
| `TERMINADO` | Consulta e historial | Avance o devolución normal |
| `ANULADO` | Consulta e historial | Inicio, avance, devolución o finalización |

### Candidatos documentados para Clarify

Estos puntos no se resuelven ni bloquean la creación de Spec 003. Deben revisarse antes de cualquier
Plan cuando afecten el comportamiento a implementar:

1. Determinar si el motivo de devolución será obligatorio, opcional o inexistente y cómo se
   validará sin cambiar silenciosamente el modelo aprobado.
2. Confirmar excepciones de la matriz de destinos y posibles reglas especiales por tipo de trabajo,
   manteniendo el flujo flexible.
3. Definir desde qué estados puede anularse una OT y si existe alguna excepción administrativa para
   estados terminales.
4. Definir método exacto de acceso, recuperación de contraseña y política detallada de sesiones.
5. Definir qué datos adicionales, si alguno, necesita `perfil_usuario`.
6. Definir en el futuro una fórmula empresarial de `total_pliegos`; hasta entonces continúa siendo
   un entero positivo registrado.
7. Delimitar cobertura adicional y retención de auditoría.
8. Evaluar si trabajos repetidos recomendarán rutas anteriores o si se permitirá copiar una ruta;
   esta Spec no automatiza esa posibilidad.
9. Precisar cualquier corrección histórica que exceda agregar un movimiento compensatorio, porque
   los movimientos existentes son inmutables.
10. Confirmar si la selección del responsable destino la realiza quien confirma el movimiento, como
    exige el flujo definido aquí, o si el USUARIO receptor debe seleccionarlo después de la llegada.
    La segunda alternativa requeriría revisar primero cómo representarla sin contradecir la
    obligatoriedad de `movimiento_ot.responsable_sector_id` en Spec 002.
11. Precisar las acciones referenciales de la eliminación operacional: Spec 002 exige conservar la
    auditoría, pero mantiene pendiente el tratamiento físico exacto de las demás dependencias. El
    resultado funcional de esta Spec es que la OT y sus dependencias operativas dejan de estar
    disponibles, mientras la auditoría permanece.

### Futuro y fuera del alcance del MVP actual

Existe una base de datos anterior con aproximadamente 19.000 OT históricas. Migrarla total o
parcialmente es una **posibilidad o requisito futuro a evaluar**, no una obligación aprobada. La
migración histórica no forma parte del alcance principal de Spec 003 y no bloquea Spec 002, Spec 003
ni el desarrollo del nuevo sistema. La referencia de volumen se conserva para búsqueda, paginación
y validaciones de capacidad.

También quedan fuera del alcance de esta Spec:

- SQL, tablas físicas, migraciones, triggers, índices, RLS o RPC concretos;
- modificaciones de Supabase o scripts contra la base anterior;
- componentes, CSS, pantallas finales, arquitectura física o código;
- Plan, Tasks, Analyze o Implement;
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
  aparece en orden con origen, destino, responsable, actor, momento y tipo.
- **SC-004**: Los tiempos de todas las visitas de una OT de prueba pueden reconstruirse únicamente
  con movimientos y finalización, sin una duración almacenada separadamente.
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
- **SC-010**: Para cada operación auditable de prueba, el ADMINISTRADOR puede consultar actor,
  fecha/hora, operación y cambios sin poder modificar ni eliminar la auditoría.
- **SC-011**: Una revisión documental encuentra cero redefiniciones de las 16 entidades de Spec 002
  y cero confusiones entre usuario autenticado, responsable físico, movimiento y auditoría.
- **SC-012**: Toda referencia a la migración de la base anterior la clasifica como futuro fuera del
  MVP y cero requisitos del desarrollo dependen de completarla.
- **SC-013**: La revisión encuentra cero SQL, migraciones, RLS o RPC concretos, modificaciones de
  Supabase, Plan, Tasks, Analyze, Implement o código.

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
