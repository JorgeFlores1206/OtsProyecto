# Especificación: Spec 002 — Diccionario de Datos

**Directorio**: `specs/002-diccionario-datos`
**Creada**: 2026-10-02
**Actualizada**: 2026-10-08
**Estado**: APROBADA — Enmienda 3 (2026-10-08) pendiente de aprobación
**Fecha de aprobación**: 2026-10-06
**Fuentes**: Constitution v1.1.0, Spec 000 v1.1.0, Spec 001 y decisiones proporcionadas para Spec 002

## Enmiendas posteriores a aprobación

### Enmienda 1 — Estado Activo/Inactivo de cliente

- **Fecha de enmienda**: 2026-10-06.
- **Cambio**: incorporación de `cliente.estado` y normalización de los atributos de `cliente` a
  `id`, `nombre`, `telefono`, `correo` y `estado`; se retiran `codigo`, `nombre_comercial` y `nit`.
- **Motivo**: corregir la inconsistencia detectada entre Spec 002 y Spec 003 respecto al uso de
  clientes Activos/Inactivos.
- **Impacto**: no modifica entidades, relaciones ni cardinalidades; formaliza la política
  Activo/Inactivo ya aprobada. Spec 002 mantiene su estado `APROBADA`.

### Enmienda 2 — Metadatos técnicos de creación y anulación

- **Fecha de enmienda**: 2026-10-06.
- **Cambio**: incorporación de `orden_trabajo.idempotencia_creacion` como identificador técnico
  durable y único de la operación de creación agregada, y de `orden_trabajo.anulado_en` como momento
  efectivo de anulación. Se ratifica `terminado_en` como momento efectivo de finalización.
- **Motivo**: formalizar la protección servidor/base de datos ante reintentos de creación y cerrar
  temporalmente la última etapa productiva de una OT anulada.
- **Impacto**: no agrega entidades, no altera relaciones ni cardinalidades y no modifica la
  semántica empresarial de la OT. Amplía `orden_trabajo` únicamente con metadatos técnicos y de
  trazabilidad; Spec 002 conserva el estado `APROBADA`.

### Enmienda 3 — Trazabilidad mínima, autenticación propia y anulación en lugar de borrado

- **Fecha de enmienda**: 2026-10-08.
- **Cambio**:
  1. Se retiran `auditoria_evento` y `auditoria_cambio`. La trazabilidad queda en el mínimo del
     principio X: creado por, creado en, modificado por y modificado en, en cada entidad editable.
  2. Se extienden esos atributos de trazabilidad a los maestros editables, que antes dependían de la
     auditoría completa.
  3. `perfil_usuario` deja de enlazar una identidad de Supabase Auth: incorpora `correo`, `nombre`,
     `contrasena_hash`, `intentos_fallidos` y `bloqueado_hasta`, y se retira `auth_usuario_id`. Se
     agrega la entidad `token_usuario` para sesiones, invitaciones y recuperación de contraseña.
  4. Una OT ya no se elimina físicamente: la única forma de retirarla es la anulación.
- **Motivo**: Constitution v1.1.0 (XVIII, backend separado) y Spec 000 v1.1.0 (autenticación
  gestionada por el backend; trazabilidad mínima sin historial de cambios). La anulación evita que
  una OT desaparezca sin rastro y que su código correlativo quede sin explicación.
- **Impacto**: el modelo pasa de 16 a **15 entidades** (−2 de auditoría, +1 `token_usuario`). Sin
  historial de cambios no se conservan valores anteriores ni quién modificó antes de la última
  modificación. Exige enmendar la Spec 003 (US6, US9, FR-006, FR-014, FR-030, FR-073–FR-077, SC-010,
  SC-013, SC-015) y replanificarla.
- **Aprobación**: pendiente de revisión humana (Constitution I y XVI).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Comprender el contrato estructural (Priority: P1)

Como responsable del proyecto, quiero conocer las entidades, atributos, claves, nulabilidad y
relaciones del modelo sin consultar código para aprobar su estructura antes de implementarla.

**Independent Test**: Cada una de las 15 entidades candidatas indica por qué existe, sus datos,
relaciones y reglas; las decisiones pendientes distinguen expresamente lo funcional de lo
estructural.

**Acceptance Scenarios**:

1. **Given** una entidad del modelo, **When** se consulta el diccionario, **Then** se identifican su
   finalidad, clave primaria, atributos, tipos lógicos, obligatoriedad, relaciones y conservación
   histórica.
2. **Given** una decisión aún no resuelta, **When** se revisa su clasificación, **Then** se puede
   determinar si pertenece a una futura Spec funcional o a una decisión física posterior y si
   bloquea la aprobación estructural.
3. **Given** el inventario del modelo, **When** se cuentan sus entidades, **Then** se obtienen 15
   entidades lógicas, incluidas `tipo_material`, `sector`, `responsable_sector`, `movimiento_ot` y
   `token_usuario`.

---

### User Story 2 - Proteger la estructura de OT, pisos, materiales y acabados (Priority: P1)

Como responsable de producción, quiero que el modelo preserve las reglas aprobadas de una OT y sus
pisos para evitar datos ambiguos o contradictorios.

**Independent Test**: Una OT admite de cero a tres pisos; cuando existen son consecutivos desde el
1; cada piso conserva montaje, dimensiones, material, máquina y muestrario; los acabados son
opcionales y no se repiten.

**Acceptance Scenarios**:

1. **Given** una OT sin pisos todavía, **When** se revisa su estructura, **Then** es válida con cero
   `ot_detalle`.
2. **Given** una OT con pisos, **When** se revisan sus números, **Then** solo se admiten los conjuntos
   1; 1–2; o 1–2–3.
3. **Given** un `ot_detalle`, **When** se revisa su montaje, **Then** `armado` representa diseños
   distintos, `formato` representa posiciones totales, ambos son enteros positivos y
   `formato >= armado`.
4. **Given** un tamaño de material, final o de corte, **When** se revisa su representación,
   **Then** utiliza componentes X/Y numéricos en centímetros y nunca una cadena combinada.
5. **Given** un acabado `PERFORADO`, `ENGOMADO`, `ANILLADO` o `ENGRAMPADO`, **When** se registra,
   **Then** su posición obligatoria es `IZQUIERDA` o `ARRIBA`.

---

### User Story 3 - Reconstruir el recorrido productivo real (Priority: P1)

Como responsable de operaciones, quiero reconstruir cada recorrido real de una OT, incluidos saltos
y devoluciones, para saber dónde estuvo, quién fue responsable y cuánto tiempo permaneció en cada
sector.

**Independent Test**: Ordenando los `movimiento_ot` de una OT se reconstruyen sus sectores de
origen y destino, responsables físicos, actores del sistema, tipos de movimiento y momentos sin
depender de una ruta fija.

**Acceptance Scenarios**:

1. **Given** una OT nueva, **When** ingresa por primera vez al flujo, **Then** se registra un
   `INICIO` con origen null y cualquier destino activo que participe en el flujo.
2. **Given** una OT en PRENSA, **When** se envía directamente a PRODUCCIÓN, **Then** se registra un
   `AVANCE` válido aunque se haya saltado PRE_ACABADO.
3. **Given** una OT en PRODUCCIÓN que requiere repetir trabajo en PRENSA, **When** se devuelve,
   **Then** se agrega una `DEVOLUCION` sin sobrescribir movimientos anteriores.
4. **Given** una OT con varios movimientos, **When** se consulta su situación actual, **Then** el
   sector y responsable actuales se derivan del último movimiento y no de columnas duplicadas en
   `orden_trabajo`.
5. **Given** dos movimientos consecutivos, **When** se calcula la permanencia en el primer destino,
   **Then** se obtiene la diferencia entre sus marcas de tiempo sin una columna `duracion`.

---

### User Story 4 - Separar operación, responsabilidad física y trazabilidad (Priority: P2)

Como responsable del negocio, quiero distinguir al usuario autenticado de la persona que realiza el
trabajo físico y saber quién creó y modificó por última vez cada registro para conservar
responsabilidades claras.

**Independent Test**: Cada movimiento identifica un `perfil_usuario` como actor y un
`responsable_sector` como responsable físico; `movimiento_ot` conserva el recorrido del negocio y
cada entidad editable conserva sus atributos de creación y última modificación.

**Acceptance Scenarios**:

1. **Given** un usuario operativo de PRENSA, **When** recibe una OT, **Then** puede seleccionar como
   responsable a una persona activa de PRENSA que no necesita credenciales.
2. **Given** un cambio de usuario operativo del sector, **When** se consulta un movimiento anterior,
   **Then** el perfil que lo realizó permanece identificado.
3. **Given** un registro editable modificado, **When** se consulta, **Then** identifica quién lo creó,
   cuándo, quién lo modificó por última vez y cuándo.
4. **Given** una OT que ya no debe trabajarse, **When** el ADMINISTRADOR la retira, **Then** queda
   `ANULADO` con su momento de anulación y continúa existiendo con su código.

### Edge Cases

- Una OT puede tener cero pisos; si tiene pisos, no existe piso 2 sin piso 1 ni piso 3 sin pisos 1 y
  2.
- `cantidad_paginas`, tamaño final y tamaño de corte son opcionales; cada par X/Y, cuando existe,
  debe estar completo y ser positivo.
- `armado` y `formato` no admiten cero, negativos ni texto; `formato` puede no ser divisible entre
  `armado`, pero nunca ser menor.
- Un cliente, parámetro, sector, responsable o perfil inactivo permanece visible en el historial,
  pero no se ofrece para nuevas operaciones que requieran un elemento activo.
- Una OT puede iniciar en DISEÑO, PRENSA, PRE_ACABADO o PRODUCCIÓN; DISEÑO no es obligatorio.
- Un avance puede saltar sectores y una devolución puede regresar más de un sector.
- Una OT puede repetir parte del ciclo; cada repetición agrega movimientos y no sobrescribe los
  anteriores.
- ALMACÉN existe como sector, pero no puede ser destino del recorrido productivo.
- Llegar a PRODUCCIÓN no termina automáticamente la OT.
- Una OT ANULADA no admite avances, devoluciones ni nuevos movimientos productivos.
- La inactivación o edición posterior de un sector, responsable o perfil no rompe las referencias
  de movimientos ya registrados.
- Un reintento no debe duplicar pisos, acabados ni movimientos.
- Una OT nunca se elimina físicamente; aunque no tenga movimientos, se retira mediante anulación.
- Un enlace de invitación o recuperación caducado, usado o revocado no permite establecer una
  contraseña.

## Requirements *(mandatory)*

### Requisitos del modelo maestro

- **DR-001**: `orden_trabajo` DEBE ser la entidad central del modelo de negocio.
- **DR-002**: Una OT DEBE admitir entre cero y tres `ot_detalle`; cuando exista al menos uno, sus
  números DEBEN ser consecutivos desde 1.
- **DR-003**: (`orden_trabajo_id`, `numero_piso`) DEBE identificar de forma única un piso dentro de
  una OT.
- **DR-004**: `codigo_ot` DEBE ser correlativo, automático, estable y único.
- **DR-005**: `cantidad` DEBE ser un entero positivo y `cantidad_paginas` DEBE ser opcional y, cuando
  exista, un entero positivo.
- **DR-006**: `tipo_material` DEBE permanecer separado de `material` y DEBE declarar mediante
  `requiere_gramaje` si sus materiales requieren gramajes asociados.
- **DR-007**: `gramaje` DEBE pertenecer a `material`; `ot_detalle` NO DEBE contener `gramaje_id`.
- **DR-008**: Cada piso DEBE tener un único material, una única máquina y un muestrario obligatorio.
- **DR-009**: `armado` y `formato` DEBEN ser enteros positivos separados; `formato` DEBE ser mayor o
  igual que `armado` y no se exige divisibilidad entre ambos.
- **DR-010**: Las dimensiones de material, tamaño final y tamaño de corte DEBEN usar componentes X/Y
  numéricos en centímetros; los tamaños final y de corte son pares opcionales.
- **DR-011**: Una OT PUEDE tener cero o más acabados y NO DEBE repetir un acabado.
- **DR-012**: `PERFORADO`, `ENGOMADO`, `ANILLADO` y `ENGRAMPADO` DEBEN requerir posición
  `IZQUIERDA` o `ARRIBA`; para los demás acabados la posición no aplica salvo decisión funcional
  posterior.
- **DR-013**: Los códigos funcionales estables, y no los IDs internos, DEBEN gobernar las reglas de
  catálogos y dominios.
- **DR-014**: Todos los nombres maestros DEBEN usar minúsculas y `snake_case`.

### Requisitos de sectores y recorrido

- **DR-015**: `sector` DEBE distinguir con `participa_flujo` las áreas que forman parte del recorrido
  productivo de las que solo existen como áreas empresariales.
- **DR-016**: Los sectores que participan en el flujo DEBEN tener un `orden_flujo` entero positivo y
  no repetido; los que no participan DEBEN tenerlo null y no pueden ser destinos productivos
  normales.
- **DR-017**: El orden lógico inicial DEBE ser DISENO 1, PRENSA 2, PRE_ACABADO 3 y PRODUCCION 4;
  ALMACEN DEBE existir con `participa_flujo = false` y `orden_flujo = null`.
- **DR-018**: Una OT DEBE poder iniciar en cualquier sector activo con `participa_flujo = true`; no
  se exige comenzar en DISEÑO.
- **DR-019**: El modelo NO DEBE imponer el paso por todos los sectores ni una ruta rígida por tipo de
  trabajo.
- **DR-020**: `movimiento_ot` DEBE registrar cada ingreso, avance o devolución como una fila histórica
  independiente y no sobrescribible.
- **DR-021**: El primer movimiento DEBE ser `INICIO`, con origen null; los siguientes DEBEN enlazar
  el destino anterior como origen y clasificarse como `AVANCE` o `DEVOLUCION`.
- **DR-022**: Un `AVANCE` PUEDE saltar sectores posteriores y una `DEVOLUCION` PUEDE regresar a
  cualquier sector anterior permitido; ambos destinos deben participar en el flujo.
- **DR-023**: `movimiento_ot.responsable_sector_id` DEBE identificar a una persona del sector destino
  y `realizado_por_perfil_id` DEBE identificar al usuario autenticado que realizó la operación.
- **DR-024**: El actor de un movimiento o de la trazabilidad NUNCA DEBE recibirse como identidad libre
  proporcionada por el navegador.
- **DR-025**: El sector actual y el responsable actual DEBEN derivarse del último movimiento de la OT;
  no se aprueban `orden_trabajo.sector_actual_id` ni `orden_trabajo.responsable_actual_id`.
- **DR-026**: La permanencia en un sector DEBE derivarse de los momentos de entrada y salida; no se
  aprueba una columna persistida `duracion_sector`.
- **DR-027**: El modelo DEBE poder operar y validarse con un volumen de referencia comparable a
  aproximadamente 19.000 OT y múltiples movimientos por OT, con futura paginación, consultas
  eficientes e índices físicos a definir fuera de esta Spec. Este volumen no obliga a migrar los
  registros de la base anterior.

### Requisitos de usuarios, estados y conservación histórica

- **DR-028**: `perfil_usuario` DEBE representar la cuenta de acceso de una persona usuaria con un
  `correo` único y su contraseña almacenada exclusivamente como `contrasena_hash`; nunca en texto
  plano.
- **DR-029**: Un perfil con rol `USUARIO` DEBE pertenecer a un sector; un perfil
  `ADMINISTRADOR` PUEDE tener `sector_id` null y no queda restringido a un solo sector operativo.
- **DR-030**: Un sector PUEDE conservar distintos perfiles históricamente, pero solo un `USUARIO`
  operativo activo por sector en un momento determinado; esta es una regla lógica, no un mecanismo
  físico aprobado en esta Spec.
- **DR-031**: `responsable_sector` DEBE representar personas físicas sin credenciales ni cuenta de
  acceso.
- **DR-032**: Solo un responsable del sector destino PUEDE quedar como responsable actual de la OT y
  los responsables anteriores DEBEN permanecer en el historial de movimientos.
- **DR-033**: Una OT nueva DEBE iniciar en `PENDIENTE`; su primer `INICIO` productivo la cambia a
  `EN_PROCESO`; los movimientos posteriores no cambian ese estado por sí solos.
- **DR-034**: La llegada a PRODUCCIÓN NO DEBE cambiar automáticamente la OT a `TERMINADO`; la
  finalización es una acción manual y trazable.
- **DR-035**: Una OT `ANULADA` NO DEBE generar nuevos movimientos productivos.
- **DR-036**: `movimiento_ot` DEBE conservar los hechos funcionales del recorrido. El modelo NO
  incluye historial de cambios con valores anteriores y nuevos; la trazabilidad se limita a los
  atributos de creación y última modificación (DR-043).
- **DR-037**: Una OT NO DEBE eliminarse físicamente. La única forma de retirarla es la anulación
  (`ANULADO` con `anulado_en`), que conserva el registro, su código y sus dependencias.
- **DR-038**: Los sectores, responsables y perfiles usados históricamente DEBEN inactivarse en lugar
  de borrarse cuando su eliminación rompería el historial.
- **DR-039**: Cabecera, pisos, acabados y movimientos de una OT DEBEN preservar una unidad lógica
  consistente.
- **DR-040**: El modelo DEBE conservar la hora de finalización para cerrar el tiempo del último
  sector, sin crear una entidad independiente solo para finalizar.
- **DR-041**: La creación agregada de una OT DEBE quedar asociada a una clave técnica durable y
  única `idempotencia_creacion`. Repetir la misma solicitud con la misma clave DEBE reconocer el
  resultado ya procesado y NO DEBE crear otra OT. La clave no es el código de OT, no es un dato
  empresarial y no se muestra como información funcional.
- **DR-042**: Una transición a `ANULADO` DEBE registrar `anulado_en` atómicamente con el cambio de
  estado, usando el momento confiable de la operación servidor/base de datos. El navegador NO DEBE
  proporcionar como confiables el actor ni ese timestamp.
- **DR-043**: Toda entidad editable DEBE incluir `creado_por_perfil_id`, `creado_en`,
  `modificado_por_perfil_id` y `modificado_en`, asignados por el backend a partir de la identidad
  autenticada y del momento confiable de la operación. Se exceptúan `movimiento_ot` (inmutable, con
  su propio actor y momento), `ot_acabado` (solo creación) y `token_usuario`.
- **DR-044**: Un `perfil_usuario` creado por invitación PUEDE tener `contrasena_hash` null hasta que
  la persona establezca su contraseña; mientras sea null no puede iniciar sesión.
- **DR-045**: Los tokens de sesión, invitación y recuperación DEBEN almacenarse únicamente como hash,
  tener caducidad y poder revocarse; los de invitación y recuperación son de un solo uso.
- **DR-046**: `perfil_usuario.intentos_fallidos` DEBE ser un entero mayor o igual que cero que cuenta
  los inicios de sesión fallidos consecutivos, y `bloqueado_hasta` DEBE indicar hasta cuándo la cuenta
  no puede iniciar sesión (null si no está bloqueada). Ambos los gestiona exclusivamente el backend y
  NO forman parte de la trazabilidad de modificación. Las reglas funcionales (umbral, duración y
  desbloqueo) pertenecen a Spec 003 (FR-017a).

## COMPARACIÓN CON EL MODELO EXISTENTE

No existen en el repositorio esquemas SQL, migraciones ni exportaciones de una base física para
comparar. Esta versión consolida las decisiones documentales aprobadas para Spec 002 y corrige las
inconsistencias de la versión anterior del propio diccionario. No modifica ninguna base de datos ni
prescribe una implementación física.

## Convenciones, clasificación e inventario

- Las claves locales usan conceptualmente `integer`; las entidades de historial de alto crecimiento
  usan `bigint`; `idempotencia_creacion` usa `uuid`.
- Los tipos lógicos empleados son `text`, `integer`, `smallint`, `numeric`, `date`, `timestamptz` y
  `boolean`. No constituyen SQL ni fijan una implementación física.
- Las dimensiones numéricas se expresan en centímetros.
- “Generado” y “automático” describen un default lógico; su mecanismo se define posteriormente.
- El modelo candidato contiene **15 entidades lógicas**.

| Categoría | Entidades |
|---|---|
| Negocio | `cliente`, `orden_trabajo`, `ot_detalle` |
| Materiales y recursos | `tipo_material`, `material`, `gramaje`, `maquina` |
| Catálogos y operación | `parametro`, `sector`, `responsable_sector` |
| Relación multivaluada | `ot_acabado` |
| Seguridad | `rol`, `perfil_usuario`, `token_usuario` |
| Flujo productivo | `movimiento_ot` |

Inventario completo: `cliente`, `orden_trabajo`, `ot_detalle`, `tipo_material`, `material`,
`gramaje`, `maquina`, `parametro`, `ot_acabado`, `rol`, `perfil_usuario`, `sector`,
`responsable_sector`, `movimiento_ot` y `token_usuario`.

## MAPA DE RELACIONES

```text
cliente 1 ── N orden_trabajo 1 ── 0..3 ot_detalle
orden_trabajo 1 ── N ot_acabado N ── 1 parametro[ACABADO]
orden_trabajo 1 ── N movimiento_ot

tipo_material 1 ── N material 1 ── N gramaje
material 1 ── N ot_detalle; maquina 1 ── N ot_detalle
parametro[TIPO_TRABAJO|ESTADO_OT] 1 ── N orden_trabajo
parametro[COLORIMETRIA|IMPRESION|MUESTRARIO] 1 ── N ot_detalle

sector 1 ── N responsable_sector
sector 1 ── N perfil_usuario (histórico; máximo un USUARIO operativo activo por sector)
sector 1 ── N movimiento_ot como origen
sector 1 ── N movimiento_ot como destino
responsable_sector 1 ── N movimiento_ot
perfil_usuario 1 ── N movimiento_ot como actor

rol 1 ── N perfil_usuario
perfil_usuario 1 ── N token_usuario
perfil_usuario 1 ── N registros editables como creador o último modificador
```

La participación como origen admite null únicamente en el primer `INICIO`; por eso un sector puede
originar cero o muchos movimientos, pero cada movimiento posterior al primero tiene exactamente un
origen.

## MAPA GENERAL DEL FLUJO

```text
orden_trabajo
      │
      ▼
movimiento_ot (una fila por cada hecho del recorrido)
      │
      ├── sector origen
      ├── sector destino
      ├── responsable físico del destino
      ├── perfil autenticado que realiza el movimiento
      ├── tipo: INICIO | AVANCE | DEVOLUCION
      └── momento
      │
      ▼
historial completo e inmutable
      │
      ▼
sector actual derivado
responsable actual derivado
tiempos por sector derivados
```

El mapa representa un historial de hechos, no una secuencia obligatoria ni una plantilla fija por
tipo de trabajo.

## DICCIONARIO DE DATOS MAESTRO

En las tablas siguientes, `—` significa que no existe FK. Las reglas son lógicas y no generan SQL.

### Atributos de trazabilidad comunes

Las entidades `cliente`, `orden_trabajo`, `ot_detalle`, `tipo_material`, `material`, `gramaje`,
`maquina`, `parametro`, `rol`, `perfil_usuario`, `sector` y `responsable_sector` incluyen, además de
los atributos listados en su tabla, los siguientes (DR-043):

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `creado_por_perfil_id` | integer | Sí/null | FK `perfil_usuario`; null solo en datos iniciales y en el primer ADMINISTRADOR |
| `creado_en` | timestamptz | No/generado | Momento confiable de creación |
| `modificado_por_perfil_id` | integer | Sí/null | FK `perfil_usuario`; null mientras no haya modificaciones |
| `modificado_en` | timestamptz | Sí/null | Momento confiable de la última modificación |

Solo se conserva la última modificación; no existe historial de valores anteriores. En
`orden_trabajo`, `creado_por_perfil_id` es obligatorio porque toda OT la crea un ADMINISTRADOR.

### `cliente`

Finalidad: representar al cliente solicitante. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `nombre` | text | No/— | Nombre del cliente |
| `telefono`, `correo` | text | Sí/null | Datos de contacto opcionales |
| `estado` | boolean | No/true | `true` = Activo; `false` = Inactivo |

Relación 1:N con `orden_trabajo`; la incorporación de `estado` no modifica esta cardinalidad. Un
cliente Activo puede utilizarse para crear nuevas OT. Un cliente Inactivo deja de aparecer como
opción normal para nuevas OT, pero continúa existiendo y visible en las OT históricas que lo
referencian. Un cliente con historial no se elimina físicamente: se inactiva para preservar la
relación con sus OT. El `ADMINISTRADOR` es quien crea, consulta, edita, activa e inactiva clientes.

Activo/Inactivo es una propiedad simple de `cliente`: no se crea una entidad `estado_cliente` y el
valor no se duplica en `orden_trabajo`. `cliente` no contiene NIT ni un código empresarial adicional.

### `orden_trabajo`

Finalidad: representar un trabajo de producción. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `codigo_ot` | text | No/automático | Único, correlativo y estable |
| `cliente_id` | integer | No/— | FK `cliente` |
| `fecha_ot` | date | No/— | — |
| `cantidad` | integer | No/— | Mayor que cero |
| `tipo_trabajo_parametro_id` | integer | No/— | FK `parametro[TIPO_TRABAJO]` |
| `cantidad_paginas` | integer | Sí/null | Mayor que cero cuando existe |
| `nombre_trabajo` | text | No/— | — |
| `estado_ot_parametro_id` | integer | No/`PENDIENTE` | FK `parametro[ESTADO_OT]` |
| `idempotencia_creacion` | uuid | No/clave estable de la operación | Único; metadato técnico no visible y distinto de `codigo_ot` |
| `terminado_en` | timestamptz | Sí/null | Momento de finalización manual; solo aplica a `TERMINADO` |
| `anulado_en` | timestamptz | Sí/null | Momento efectivo de anulación; obligatorio cuando el estado es `ANULADO` |
| `creado_por_perfil_id` | integer | No/— | FK `perfil_usuario` |
| `modificado_por_perfil_id` | integer | Sí/null | FK `perfil_usuario` |
| `creado_en` | timestamptz | No/generado | Trazabilidad básica |
| `modificado_en` | timestamptz | Sí/null | Trazabilidad básica |

Relaciones: N:1 con cliente; 1:0..3 con detalles; 1:N con acabados y movimientos. `cantidad_pisos` es derivada y no se persiste. Tampoco se agregan
`sector_actual_id` ni `responsable_actual_id`: ambos valores provienen del último movimiento.

Una OT no se elimina físicamente (DR-037). El `ADMINISTRADOR` la retira mediante anulación, que
conserva el registro, su código correlativo, sus pisos, acabados y movimientos.

#### Estado y finalización de la OT

- Al crear la OT: `PENDIENTE`.
- Al registrar su primer `INICIO`: `EN_PROCESO`.
- Durante avances y devoluciones: permanece `EN_PROCESO`.
- Al ejecutar la acción manual de finalización: `TERMINADO` y `terminado_en` conserva el momento.
- Al anular: `ANULADO` y `anulado_en` conserva atómicamente el momento efectivo; no se permiten
  nuevos movimientos productivos.
- Mientras la OT no esté `TERMINADO`, `terminado_en` es null; mientras no esté `ANULADO`,
  `anulado_en` normalmente es null. Los timestamps los establece la operación segura, no el
  navegador.
- Llegar a PRODUCCIÓN no implica finalizar. El estado y el sector actual son conceptos distintos.

La autorización técnica y las transiciones excepcionales se definirán funcionalmente; esta Spec
solo establece los estados y su regla general.

### `ot_detalle`

Finalidad: representar un piso de producción de una OT. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `orden_trabajo_id` | integer | No/— | FK `orden_trabajo` |
| `numero_piso` | smallint | No/— | 1–3; único junto con `orden_trabajo_id` |
| `material_id` | integer | No/— | FK `material`; no existe `gramaje_id` en esta entidad |
| `tamano_material_x`, `tamano_material_y` | numeric | No/— | Ambos mayores que cero; centímetros; admiten decimales |
| `armado` | integer | No/— | Mayor que cero; diseños distintos del montaje |
| `formato` | integer | No/— | Mayor que cero; posiciones totales; `formato >= armado` |
| `total_pliegos` | integer | No/— | Mayor que cero; registrado, no calculado automáticamente |
| `colorimetria_parametro_id` | integer | No/— | FK `parametro[COLORIMETRIA]` |
| `cara_color` | text | No/— | `ANVERSO`, `REVERSO` o `AMBAS` |
| `impresion_parametro_id` | integer | No/— | FK `parametro[IMPRESION]` |
| `maquina_id` | integer | No/— | FK `maquina`; una máquina por piso |
| `muestrario_parametro_id` | integer | No/— | FK `parametro[MUESTRARIO]`; obligatorio por piso |
| `tamano_final_x`, `tamano_final_y` | numeric | Sí/null | Par opcional; juntos o ambos null; > 0; centímetros |
| `tamano_corte_x`, `tamano_corte_y` | numeric | Sí/null | Par opcional; juntos o ambos null; > 0; centímetros |
| `cara_acabado` | text | Condicional/null | Dominio de caras cuando corresponda al acabado |
| `creado_por_perfil_id`, `modificado_por_perfil_id` | integer | Según evento | FK `perfil_usuario` |
| `creado_en`, `modificado_en` | timestamptz | Según evento | Trazabilidad básica |

Una OT puede tener cero pisos. Cuando tiene uno o más, el conjunto permitido es 1; 1–2; o 1–2–3.
`tamano_material_z` no forma parte del modelo. No se crea una relación acabado–piso.

#### Relación entre `armado` y `formato`

- `armado` es la cantidad de diseños distintos que participan en el montaje de un pliego.
- `formato` es la cantidad total de posiciones del trabajo distribuidas dentro del pliego.
- Los diseños pueden distribuirse o repetirse hasta completar las posiciones.
- Son enteros obligatorios distintos; no se combinan en textos como `"10(40)"`.
- La única relación numérica aprobada es `formato >= armado`; no existe regla de divisibilidad.

```text
10 diseños distintos
        ↓
     armado = 10
        ↓
distribuidos o repetidos
        ↓
40 posiciones totales
        ↓
     formato = 40
```

`total_pliegos` continúa siendo un entero positivo registrado. No se infiere una fórmula universal
a partir de `cantidad`, `armado` y `formato`.

#### Dimensiones de material, tamaño final y tamaño de corte

El modelo mantiene seis componentes atómicos en centímetros:

- `tamano_material_x` y `tamano_material_y`, obligatorios;
- `tamano_final_x` y `tamano_final_y`, opcionales como par completo;
- `tamano_corte_x` y `tamano_corte_y`, opcionales como par completo.

Todos son numéricos, positivos y aptos para decimales. No se almacenan cadenas como `"15x10"` o
`"31.7x22.6"`; la unidad aprobada es centímetros y no requiere una columna repetida por dimensión.

### `tipo_material`, `material`, `gramaje` y `maquina`

| Entidad | Finalidad y PK | Atributos lógicos | Reglas |
|---|---|---|---|
| `tipo_material` | Clasificar materiales; `id integer` | `codigo text` único, `nombre text`, `requiere_gramaje boolean`, `estado boolean=true` | Entidad separada de `material`; el código es estable; inactivar si fue usada. |
| `material` | Representar un insumo específico; `id integer` | `tipo_material_id integer` FK, `codigo text` único, `descripcion text`, `estado boolean=true` | N:1 con `tipo_material`; 1:N con `gramaje` y `ot_detalle`; inactivar si fue usado. |
| `gramaje` | Representar un gramaje permitido del material; `id integer` | `material_id integer` FK, `valor numeric`, `estado boolean=true` | Pertenece al material; el par (`material_id`, `valor`) no se repite; `valor > 0`; no guardar “gr” en el valor. |
| `maquina` | Representar un recurso real; `id integer` | `nombre text` único, `estado boolean=true` | Una máquina puede aparecer en muchos pisos; un piso referencia una sola; inactivar si fue usada. |

Cuando `tipo_material.requiere_gramaje = true`, los materiales de ese tipo deben disponer de su
configuración de gramajes. El piso referencia el material y no duplica `gramaje_id`; esta Spec no
reabre esa decisión aprobada.

### `parametro`

Finalidad: representar catálogos simples gobernados por códigos funcionales. PK: `id integer`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `grupo_codigo` | text | No/— | Parte de unicidad compuesta |
| `valor_codigo` | text | No/— | Parte de unicidad compuesta; código estable |
| `descripcion` | text | No/— | Nombre visible |
| `estado` | boolean | No/true | Activo/Inactivo |

Grupos: `TIPO_TRABAJO`, `COLORIMETRIA`, `IMPRESION`, `MUESTRARIO`, `ACABADO` y `ESTADO_OT`.
Cada FK debe corresponder al grupo esperado. Los valores usados se inactivan, no se reciclan ni se
eliminan destruyendo historia.

### `ot_acabado`

Finalidad: representar la relación multivaluada y opcional OT–acabado. PK compuesta:
(`orden_trabajo_id`, `acabado_parametro_id`).

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `orden_trabajo_id` | integer | No/— | FK `orden_trabajo`; parte de PK |
| `acabado_parametro_id` | integer | No/— | FK `parametro[ACABADO]`; parte de PK |
| `posicion` | text | Condicional/null | `IZQUIERDA` o `ARRIBA` cuando es obligatoria |
| `creado_por_perfil_id` | integer | No/— | FK `perfil_usuario` |
| `creado_en` | timestamptz | No/generado | Momento de asignación |

Una OT puede tener cero o más acabados sin repetirlos. `PERFORADO`, `ENGOMADO`, `ANILLADO` y
`ENGRAMPADO` requieren posición. Quitar un acabado elimina la relación; la modificación queda
reflejada en `orden_trabajo.modificado_por_perfil_id` y `modificado_en`.

### `rol` y `perfil_usuario`

| Entidad | PK y atributos lógicos | Reglas |
|---|---|---|
| `rol` | `id integer`; `codigo text` único; `nombre text`; `estado boolean=true` | Códigos iniciales `ADMINISTRADOR` y `USUARIO`; inactivar si fue asignado. |
| `perfil_usuario` | `id integer`; `correo text` único; `nombre text`; `contrasena_hash text` nullable; `intentos_fallidos integer=0`; `bloqueado_hasta timestamptz` nullable; `rol_id integer` FK; `sector_id integer` FK nullable; `estado boolean=true` | Es la cuenta de acceso; la contraseña solo existe como hash (DR-028, DR-044); el bloqueo por intentos fallidos se rige por DR-046; se conserva e inactiva si aparece en movimientos o como actor de trazabilidad. |

Para `USUARIO`, `sector_id` es obligatorio y debe apuntar a su sector operativo. Para
`ADMINISTRADOR`, puede ser null y no limita su alcance a un único sector. Inicialmente existe un solo
usuario operativo activo por sector. Un sector puede acumular varios perfiles históricos, pero no
más de un `USUARIO` operativo activo simultáneo; el mecanismo para garantizarlo no se define aquí.

Cambiar el usuario operativo no reescribe actores anteriores: cada movimiento conserva el perfil
autenticado que lo realizó. La identidad del actor se obtiene del contexto autenticado, nunca
de un valor libre del navegador.

### `sector`

Finalidad: representar las áreas operativas de Rosa Betania e identificar cuáles participan en el
recorrido de las OT. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `codigo` | text | No/— | Único, estable y usado por reglas funcionales |
| `nombre` | text | No/— | Nombre visible |
| `orden_flujo` | integer | Condicional/null | Positivo y no repetido entre sectores del flujo; null si no participa |
| `participa_flujo` | boolean | No/false | Determina si puede ser destino productivo |
| `estado` | boolean | No/true | Activo/Inactivo |

Catálogo inicial:

| Código | Nombre | Orden lógico | Participa en flujo |
|---|---|---:|---|
| `DISENO` | DISEÑO | 1 | Sí |
| `PRENSA` | PRENSA | 2 | Sí |
| `PRE_ACABADO` | PRE ACABADO | 3 | Sí |
| `PRODUCCION` | PRODUCCIÓN | 4 | Sí |
| `ALMACEN` | ALMACÉN | null | No |

El orden describe el flujo general, no una secuencia obligatoria. El `ADMINISTRADOR` puede crear,
editar, activar, inactivar y reordenar sectores. Un sector que aparezca en responsables, perfiles o
movimientos históricos no se borra físicamente: se inactiva. Los cambios posteriores no eliminan ni
desvinculan movimientos existentes.

PRE_ACABADO puede realizar, como contexto empresarial, trabajos como barnizado o plastificado.
PRODUCCIÓN realiza acabados o finalización productiva. Estas actividades internas no son entidades
ni subprocesos en esta Spec.

### `responsable_sector`

Finalidad: representar a las personas físicas que trabajan en un sector y pueden quedar
responsables de una OT sin necesitar una cuenta del sistema. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `sector_id` | integer | No/— | FK `sector` |
| `nombre` | text | No/— | No se asume unicidad global |
| `estado` | boolean | No/true | Activo/Inactivo |

Relación N:1 con `sector` y 1:N con `movimiento_ot`. No contiene credenciales, no tiene cuenta de
acceso y no equivale a `perfil_usuario`. Un responsable inactivo no puede elegirse en nuevas
asignaciones, pero permanece visible en movimientos históricos. Su `sector_id` no se reasigna cuando
ya tiene historia; se inactiva y se crea el registro apropiado si cambia su pertenencia operativa.

### `movimiento_ot`

Finalidad: registrar cada cambio real de una OT dentro del flujo productivo y permitir reconstruir
recorrido, responsables, actores y tiempos. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | bigint | No/generado | PK; crecimiento histórico elevado |
| `orden_trabajo_id` | integer | No/— | FK `orden_trabajo` |
| `sector_origen_id` | integer | Solo primer inicio/null | FK `sector`; null únicamente en el primer `INICIO` |
| `sector_destino_id` | integer | No/— | FK `sector`; activo y `participa_flujo = true` al mover |
| `responsable_sector_id` | integer | No/— | FK `responsable_sector`; debe pertenecer al destino |
| `realizado_por_perfil_id` | integer | No/— | FK `perfil_usuario`; actor autenticado |
| `tipo_movimiento` | text | No/— | `INICIO`, `AVANCE` o `DEVOLUCION` |
| `ocurrido_en` | timestamptz | No/generado | Momento del hecho |

Reglas del historial:

- `INICIO` es el primer y único movimiento con origen null. Su destino puede ser cualquier sector
  activo participante del flujo.
- En cada movimiento posterior, el origen coincide con el destino del movimiento cronológicamente
  anterior de la misma OT.
- `AVANCE` representa un destino posterior según el orden lógico vigente al registrar el hecho. No
  tiene que ser el sector inmediatamente siguiente.
- `DEVOLUCION` representa el regreso a un sector anterior para repetir trabajo. No tiene que ser el
  sector inmediatamente anterior.
- Origen y destino son distintos. La matriz exacta de destinos permitidos se define funcionalmente.
- El responsable debe pertenecer al sector destino y estar activo al ser seleccionado.
- Cada fila es histórica. No se sobrescribe para reflejar otro movimiento; los ciclos repetidos
  agregan filas nuevas.
- La secuencia se ordena por `ocurrido_en` y, ante coincidencia temporal, por `id`, conservando un
  orden total por OT.
- Los cambios futuros de nombre, orden o estado de un sector no modifican el tipo ni las referencias
  del movimiento ya registrado.
- Una OT `ANULADA` no admite `INICIO`, `AVANCE` ni `DEVOLUCION` nuevos.

Ejemplo conceptual:

```text
OT 19350

08:10  INICIO       NULL → DISEÑO          Responsable: Juan
09:15  AVANCE       DISEÑO → PRENSA        Responsable: Pedro
11:40  AVANCE       PRENSA → PRODUCCIÓN    Responsable: María
13:20  DEVOLUCION   PRODUCCIÓN → PRENSA    Responsable: Carlos
15:10  AVANCE       PRENSA → PRODUCCIÓN    Responsable: María
```

El ejemplo demuestra que pueden saltarse sectores y repetirse partes del ciclo. No prescribe una
ruta para todas las OT.

#### Sector y responsable actuales

El sector actual es `sector_destino_id` del último movimiento de la OT. El responsable actual es
`responsable_sector_id` de ese mismo movimiento. Antes del primer movimiento ambos son inexistentes.
No se duplican en `orden_trabajo`.

Si un Plan posterior demostrara una necesidad de rendimiento para mantener referencias directas,
debería justificar y controlar esa denormalización. Esta Spec no la aprueba.

#### Tiempo por sector

La entrada a un sector es `ocurrido_en` del movimiento que llevó la OT allí. La salida es
`ocurrido_en` del siguiente movimiento. La duración de esa permanencia es la diferencia entre ambas
marcas.

Para el sector actual de una OT en proceso, el tiempo transcurrido es la hora actual menos la entrada
del último movimiento. Cuando se marca `TERMINADO`, `terminado_en` cierra el intervalo del último
sector; cuando se anula, `anulado_en` cierra ese intervalo. Si una OT visita varias veces el mismo
sector, cada permanencia se calcula por separado y el total del sector puede obtenerse sumando sus
intervalos. La duración continúa siendo derivada y `duracion_sector` no se almacena.

### `token_usuario`

Finalidad: representar las credenciales temporales de una cuenta: sesiones renovables, invitaciones
y recuperaciones de contraseña. PK: `id`.

| Atributo | Tipo lógico | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | bigint | No/generado | PK; crecimiento elevado |
| `perfil_usuario_id` | integer | No/— | FK `perfil_usuario` |
| `tipo` | text | No/— | `SESION`, `INVITACION` o `RECUPERACION` |
| `token_hash` | text | No/— | Único; el valor original nunca se almacena |
| `creado_en` | timestamptz | No/generado | Momento de emisión |
| `expira_en` | timestamptz | No/— | Posterior a `creado_en` |
| `usado_en` | timestamptz | Sí/null | Solo `INVITACION` y `RECUPERACION`; una vez establecido, el token no vuelve a aceptarse |
| `revocado_en` | timestamptz | Sí/null | Revocación explícita, rotación de sesión o inactivación del perfil |

Un token es válido solo si no está caducado, usado ni revocado. Al renovar una sesión, el token
anterior se revoca y se emite uno nuevo. Inactivar un perfil revoca sus tokens vigentes. Los tokens
caducados pueden depurarse sin pérdida de información de negocio.

## CATÁLOGOS Y DOMINIOS

- `ESTADO_OT`: `PENDIENTE`, `EN_PROCESO`, `TERMINADO`, `ANULADO`.
- `TIPO_MOVIMIENTO`: `INICIO`, `AVANCE`, `DEVOLUCION` como códigos conceptuales estables de
  `movimiento_ot`; no se crea otra entidad para ellos.
- `COLORIMETRIA`: Full color, Pantone, Full + Pantone.
- `IMPRESION`: Tiro y volteo, Tira y retira, Cambio de pinza.
- `MUESTRARIO`: aprobación en máquina, prueba de color, muestra física, muestra digital, impresión
  de escritorio; uno es obligatorio por piso.
- `ACABADO`: incluye `PERFORADO`, `ENGOMADO`, `ANILLADO`, `ENGRAMPADO`; el catálogo puede ampliarse
  administrativamente sin cambiar la relación multivaluada.
- `cara_color`/`cara_acabado`: `ANVERSO`, `REVERSO`, `AMBAS`.
- `posicion`: `IZQUIERDA`, `ARRIBA` para los acabados que la requieren.
- `SECTOR`: códigos iniciales `DISENO`, `PRENSA`, `PRE_ACABADO`, `PRODUCCION`, `ALMACEN`.
- `TIPO_TOKEN`: `SESION`, `INVITACION`, `RECUPERACION` como códigos conceptuales estables de
  `token_usuario`; no se crea otra entidad para ellos.

## REGLAS DEL RECORRIDO Y PERMISOS FUTUROS

### Flujo flexible

El orden general es DISEÑO → PRENSA → PRE ACABADO → PRODUCCIÓN, pero no todos los sectores son
obligatorios. Son recorridos estructuralmente válidos, sujetos a la futura matriz funcional:

```text
DISEÑO → PRENSA → PRE_ACABADO → PRODUCCIÓN
PRENSA → PRE_ACABADO → PRODUCCIÓN
PRENSA → PRODUCCIÓN
PRODUCCIÓN
DISEÑO → PRENSA → PRE_ACABADO → PRODUCCIÓN → PRENSA → PRE_ACABADO → PRODUCCIÓN
```

No se crea una plantilla fija por tipo de trabajo. El destino se selecciona entre sectores
permitidos; no se presupone un único botón “Siguiente”. Los textos, botones y comportamiento visual
quedan fuera de esta Spec.

### Visibilidad y permisos como reglas funcionales posteriores

- `USUARIO`: pertenece a un sector; ve principalmente OT cuyo sector actual coincide con el suyo;
  selecciona responsables; puede enviar o devolver a destinos permitidos y marcar `TERMINADO`
  cuando corresponda; no elimina OT ni administra sectores o catálogos.
- `ADMINISTRADOR`: ve todas las OT; puede moverlas, corregir recorridos conservando historia,
  administrar sectores y responsables y anular OT según las reglas aprobadas; no elimina OT.

Esta sección documenta el alcance empresarial. No implementa filtros, endpoints ni autorizaciones.
La matriz exacta de destinos y el detalle de permisos pertenecen a la futura Spec funcional.

### ALMACÉN

ALMACÉN prepara material y existe en el catálogo empresarial, pero no forma parte del recorrido
productivo de las OT. Tiene `participa_flujo = false`, `orden_flujo = null` y no aparece como destino
normal de `movimiento_ot`. Esta Spec no modela movimientos OT → ALMACÉN.

## NORMALIZACIÓN DE NOMBRES Y 3FN

`ORDEN_TRABAJO` → `orden_trabajo`; `OT_DETALLE` → `ot_detalle`; `MÁQUINA` → `maquina`;
`Armado` → `armado`; `AUDITORIA/HISTORIAL` → atributos de trazabilidad por entidad (Enmienda 3).

- Los pisos son filas, no columnas repetidas; los acabados multivaluados usan `ot_acabado`.
- `tipo_material` y `material` son conceptos distintos; los gramajes pertenecen al material.
- `ot_detalle` no duplica `gramaje_id`.
- `cantidad_pisos` no se almacena porque se cuenta desde `ot_detalle`.
- `armado` y `formato` son enteros atómicos separados; se descarta `"10(40)"`.
- Las seis dimensiones X/Y son numéricas y atómicas; se descartan tamaños combinados en texto.
- Cada hecho del recorrido es una fila de `movimiento_ot`; no se guardan rutas como
  `"DISEÑO > PRENSA > PRODUCCIÓN"`.
- No existen columnas `sector_1`, `sector_2`, `responsable_1`, `responsable_2` ni equivalentes.
- `sector_actual`, `responsable_actual` y `duracion_sector` son datos derivados del historial y no se
  duplican en `orden_trabajo`.
- La trazabilidad de creación y última modificación depende de cada registro y se almacena en él;
  no requiere una entidad separada.
- Los tokens se separan de `perfil_usuario` por su relación 1:N y su ciclo de vida propio.

El modelo se mantiene en 3FN conceptual. Cualquier desnormalización futura exige una justificación
de rendimiento y controles explícitos para evitar dos fuentes de verdad.

## CRECIMIENTO Y CONSULTA

Existe una base de datos anterior con aproximadamente 19.000 OT históricas. La migración total o
parcial de esa información **no está confirmada** y queda como posibilidad o requisito futuro a
evaluar; no bloquea Spec 002, Spec 003 ni el desarrollo del nuevo sistema. La referencia se conserva
como contexto para validar capacidad y crecimiento, porque cada OT nueva también puede producir
múltiples movimientos. Por ello `movimiento_ot` y `token_usuario` son entidades de crecimiento
elevado. La futura solución debe contemplar paginación, índices apropiados
y consultas eficientes por OT, sector y momento, pero esta Spec no define índices físicos,
consultas, umbrales técnicos ni una migración histórica.

## DECISIONES PENDIENTES

La revisión final identifica **cero decisiones estructurales bloqueantes**. Las decisiones siguientes
no cambian las 15 entidades, sus atributos fundamentales ni sus relaciones aprobadas.

### DECISIONES FUNCIONALES PARA SPEC 003

| ID | Decisión funcional pendiente | Clasificación |
|---|---|---|
| DF-001 | Definir la matriz exacta de destinos permitidos desde cada sector. | **NO BLOQUEA SPEC 002** |
| DF-002 | Definir las acciones disponibles y sus reglas; los botones o su presentación visual se diseñarán después. | **NO BLOQUEA SPEC 002** |
| DF-003 | Definir si una devolución exige motivo y cómo se valida. | **NO BLOQUEA SPEC 002** |
| DF-004 | Definir permisos técnicos en el backend para movimientos, visibilidad y administración. | **NO BLOQUEA SPEC 002** |
| DF-005 | Definir el comportamiento visual del recorrido, selección de destino y responsable. | **NO BLOQUEA SPEC 002** |
| DF-006 | Definir si algún tipo de trabajo recomienda o restringe una ruta específica sin convertir el modelo en una secuencia rígida. | **NO BLOQUEA SPEC 002** |

Estas decisiones quedan clasificadas para su definición funcional en Spec 003 y no alteran el
contrato estructural aprobado por esta Spec.

### Otras decisiones posteriores no estructurales

| ID | Decisión pendiente | Clasificación |
|---|---|---|
| DP-002 | Definir, si se automatiza, la fórmula empresarial de `total_pliegos`; hasta entonces es un entero registrado. | **NO BLOQUEA SPEC 002** |
| DP-009 | Definir la duración de cada tipo de token y la política de depuración de tokens caducados. | **NO BLOQUEA SPEC 002** |
| DP-006 | Definir índices físicos, estrategia de paginación y optimización a partir de volúmenes medidos. | **NO BLOQUEA SPEC 002** |
| DP-008 | Evaluar si corresponde migrar total o parcialmente la base anterior con aproximadamente 19.000 OT; no existe obligación de migrarla. | **NO BLOQUEA SPEC 002, SPEC 003 NI EL DESARROLLO** |

La anterior `DP-007` quedó **RESUELTA** mediante la enmienda del 2026-10-06: `anulado_en` cierra el
último intervalo productivo de una OT anulada sin persistir una duración. `DP-003`, `DP-004` y
`DP-005` quedaron **RETIRADAS** por la Enmienda 3: no existe eliminación física de OT ni auditoría
completa.

## OBSERVACIONES Y CORRECCIONES DEL MODELO

| ID | Estado | Elementos | Decisión consolidada |
|---|---|---|---|
| OBS-001 | RESUELTA | entidades | Se incorporan `tipo_material`, `sector`, `responsable_sector` y `movimiento_ot`; tras la Enmienda 3 el total es 15. |
| OBS-002 | RESUELTA | pisos | Una OT admite 0..3 pisos; cuando existen son consecutivos desde 1. |
| OBS-003 | RESUELTA | cantidad | `cantidad` es `integer` positivo; `cantidad_paginas` es opcional. |
| OBS-004 | RESUELTA | material/gramaje | `tipo_material` es independiente, `gramaje` pertenece a `material` y se elimina `gramaje_id` de `ot_detalle`. |
| OBS-005 | RESUELTA | máquina/muestrario | El nombre de máquina es único; hay una máquina y un muestrario obligatorio por piso. |
| OBS-006 | RESUELTA | dimensiones | Material, final y corte usan pares X/Y numéricos en centímetros; final y corte son opcionales. |
| OBS-007 | RESUELTA | acabados | Son estructuralmente opcionales; cuatro códigos requieren `IZQUIERDA` o `ARRIBA`. |
| OBS-008 | RESUELTA | estados/sector | Estado de OT y sector actual quedan separados; PRODUCCIÓN no finaliza automáticamente. |
| OBS-009 | RESUELTA | recorrido | El historial relacional admite inicio variable, saltos, devoluciones y ciclos sin rutas rígidas. |
| OBS-010 | RESUELTA | valores actuales/tiempos | Sector, responsable y duración son derivados de movimientos; no se duplican. |
| OBS-011 | RESUELTA | usuario/responsable | `perfil_usuario` es actor autenticado; `responsable_sector` es persona física sin credenciales. |
| OBS-012 | RESUELTA | ALMACÉN | Se conserva como sector empresarial fuera del flujo productivo. |
| OBS-013 | REEMPLAZADA | auditoría | Por la Enmienda 3 se retira la auditoría completa; queda la trazabilidad mínima por registro y `movimiento_ot` como historial funcional. |
| OBS-014 | RESUELTA | idempotencia/anulación | `idempotencia_creacion` evita duplicados de creación y `anulado_en` cierra la última permanencia anulada; ambas son propiedades técnicas de `orden_trabajo`. |
| OBS-015 | RESUELTA | autenticación | La cuenta de acceso reside en `perfil_usuario` con contraseña en hash; `token_usuario` gestiona sesiones, invitaciones y recuperación. |
| OBS-016 | RESUELTA | retiro de OT | Una OT no se elimina físicamente; se anula. |

## Trazabilidad de reglas críticas

| Regla | Modelo | Fuente |
|---|---|---|
| Código OT correlativo y automático | `orden_trabajo.codigo_ot` | Decisión aprobada Spec 002 |
| Creación idempotente sin duplicar OT | `orden_trabajo.idempotencia_creacion` único y no visible | Enmienda aprobada del 2026-10-06 |
| Cliente Activo/Inactivo sin perder historia | `cliente.estado`; relación 1:N sin duplicar el estado en `orden_trabajo` | Enmienda aprobada del 2026-10-06 |
| 0–3 pisos; consecutivos cuando existen | `ot_detalle`, unicidad y validación del conjunto | Decisión aprobada Spec 002 |
| Tipo, material y gramaje separados | `tipo_material` 1:N `material` 1:N `gramaje` | Decisión aprobada Spec 002 |
| Sin gramaje en piso | Ausencia de `ot_detalle.gramaje_id` | Decisión aprobada Spec 002 |
| Diseños y posiciones | `armado`, `formato`; enteros positivos y `formato >= armado` | Definición confirmada por Rosa Betania SRL |
| Dimensiones atómicas en centímetros | Seis componentes X/Y numéricos | Decisión aprobada Spec 002 |
| Acabados múltiples y opcionales | `ot_acabado` | Decisión aprobada Spec 002 |
| Estado separado de sector | `estado_ot_parametro_id` frente al último `movimiento_ot` | Reglas de flujo proporcionadas |
| Cierre de la última permanencia terminal | `terminado_en` para `TERMINADO`; `anulado_en` para `ANULADO`; duración derivada | Enmienda aprobada del 2026-10-06 |
| Inicio variable, saltos y devoluciones | `movimiento_ot` | Reglas de flujo proporcionadas |
| Responsable físico separado del usuario | `responsable_sector` frente a `perfil_usuario` | Reglas operativas proporcionadas |
| Sector y responsable actuales derivados | Último `movimiento_ot` | Regla de normalización proporcionada |
| Tiempo por sector derivado | Diferencia de marcas de movimiento/finalización | Regla de normalización proporcionada |
| Trazabilidad mínima por registro | Atributos de creación y última modificación (DR-043) | Constitution X; Enmienda 3 |
| OT nunca eliminada físicamente | Anulación con `anulado_en` (DR-037) | Enmienda 3 |
| Credenciales solo como hash | `perfil_usuario.contrasena_hash`, `token_usuario.token_hash` | Spec 000 v1.1.0; Enmienda 3 |
| Bloqueo por intentos fallidos | `perfil_usuario.intentos_fallidos`, `perfil_usuario.bloqueado_hasta` | Spec 003 FR-017a; Enmienda 3 |
| Volumen de referencia comparable a 19.000 OT y crecimiento | Claves de historial y requisitos conceptuales de consulta; no implica migración obligatoria | Spec 001 y reglas proporcionadas |

## Fuera de alcance

Esta Spec no genera tablas reales, SQL, migraciones, índices físicos, triggers, funciones, RPC, RLS,
frontend, botones, backend, Plan, Tasks ni código. No configura el proveedor de base de datos, no define subprocesos
internos de PRE_ACABADO o PRODUCCIÓN y no aprueba ni crea una migración de la base histórica.

## Success Criteria *(mandatory)*

- **SC-001**: Las **15 entidades** propuestas tienen finalidad, clave primaria, atributos y reglas
  documentadas.
- **SC-002**: El 100 % de las relaciones nuevas solicitadas expresa cardinalidad y conservación
  histórica.
- **SC-003**: Una revisión puede reconstruir cualquier secuencia de inicio, avances, saltos y
  devoluciones usando exclusivamente filas ordenadas de `movimiento_ot`.
- **SC-004**: El sector actual, responsable actual y tiempo por sector se obtienen sin columnas
  duplicadas ni rutas almacenadas como texto.
- **SC-005**: Los cinco sectores iniciales están documentados; cuatro participan del flujo y ALMACÉN
  queda excluido de destinos productivos.
- **SC-006**: Los cuatro estados de OT y los tres tipos de movimiento están definidos sin confundir
  estado con ubicación.
- **SC-007**: La revisión completa encuentra **cero decisiones estructurales bloqueantes** y clasifica
  las seis decisiones del flujo como funcionales para Spec 003.
- **SC-008**: El 100 % de las entidades editables documenta los cuatro atributos de trazabilidad y
  ninguna regla permite eliminar físicamente una OT.
- **SC-009**: El modelo conserva las reglas aprobadas de materiales, pisos, montaje, dimensiones,
  acabados, usuarios, estados, trazabilidad y anulación enumeradas en esta Spec.
- **SC-010**: La revisión encuentra cero SQL, migraciones, RLS, RPC, índices físicos, Plan, Tasks o
  código de implementación.

## Assumptions

- Los códigos funcionales son estables aunque los nombres visibles se corrijan posteriormente.
- Los clientes con OT históricas se inactivan en lugar de eliminarse y conservan su relación 1:N
  con `orden_trabajo`.
- Un movimiento representa una llegada a un sector y selecciona exactamente un responsable físico
  del destino.
- La asignación histórica del actor se conserva mediante `movimiento_ot.realizado_por_perfil_id`; un
  cambio de usuario operativo no modifica movimientos previos.
- Las correcciones administrativas del recorrido deben conservar los hechos anteriores; su operación
  exacta se define funcionalmente.
- Una OT sin movimientos todavía no tiene sector ni responsable actuales.
- Los tiempos se interpretan por visita al sector; los totales agrupados son resultados derivados.
- La migración total o parcial de la base anterior es una posibilidad futura a evaluar y no bloquea
  esta Spec, Spec 003 ni el desarrollo del nuevo sistema.
- La aprobación humana de esta Spec fue otorgada el 2026-10-06; la Enmienda 3 requiere una nueva
  aprobación humana.
- El primer ADMINISTRADOR se crea mediante un procedimiento privilegiado de arranque; por eso su
  `creado_por_perfil_id` puede ser null.
