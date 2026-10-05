# Especificación: Spec 002 — Diccionario de Datos

**Directorio**: `specs/002-diccionario-datos`  
**Creada**: 2026-10-02  
**Estado**: LISTA PARA REVISIÓN Y APROBACIÓN  
**Fuentes**: Constitution v1.0.0, Spec 000, Spec 001 y reglas proporcionadas para Spec 002

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Comprender el contrato estructural (Priority: P1)

Como responsable del proyecto, quiero conocer entidades, atributos, claves, nulabilidad y relaciones
sin consultar código para aprobar la estructura antes de implementarla.

**Independent Test**: Cada entidad indica por qué existe, sus datos, relaciones y reglas pendientes.

**Acceptance Scenarios**:

1. **Given** una entidad, **When** se consulta el diccionario, **Then** se identifican finalidad, PK,
   atributos, tipos, obligatoriedad, unicidad, FK, eliminación y actualización.
2. **Given** una ambigüedad, **When** se revisa, **Then** se indica si bloquea la aprobación.
3. **Given** un `ot_detalle`, **When** se revisa su montaje, **Then** `armado` identifica los diseños
   distintos y `formato` las posiciones totales mediante dos atributos numéricos separados.
4. **Given** un tamaño final o de corte aplicable, **When** se revisa `ot_detalle`, **Then** sus
   dimensiones X e Y aparecen como atributos numéricos atómicos, positivos y separados.

### User Story 2 - Proteger OT, pisos y acabados (Priority: P2)

Como responsable de producción, quiero impedir pisos discontinuos, acabados duplicados y posiciones
inválidas.

**Independent Test**: Solo se admiten pisos 1; 1–2; o 1–2–3, y cada acabado aparece una vez por OT.

**Acceptance Scenarios**:

1. **Given** una OT confirmada, **When** se revisan sus pisos, **Then** existen entre uno y tres y son
   consecutivos.
2. **Given** `PERFORADO` o `ENGOMADO`, **When** se asigna posición, **Then** es `IZQUIERDA` o `ARRIBA`;
   para otro acabado la posición no aplica.

### User Story 3 - Conservar historial completo (Priority: P3)

Como responsable del negocio, quiero reconstruir cambios auditables aunque el registro sea eliminado.

**Independent Test**: Cada `CREATE`, `UPDATE` o `DELETE` conserva actor autenticado, momento,
operación y cambios relevantes.

### Edge Cases

- No existe piso 2 sin piso 1 ni piso 3 sin pisos 1 y 2.
- Eliminar un registro operativo no elimina su historial.
- Un parámetro inactivo permanece válido para datos históricos, pero no para nuevas selecciones.
- Un reintento no duplica pisos, acabados ni eventos de auditoría.
- `armado` y `formato` no admiten cero, negativos ni expresiones textuales como `"10 diseños"`.
- `formato` no puede ser menor que `armado`; puede no ser divisible exactamente entre `armado`.
- Cuando aplica un tamaño final o de corte, sus componentes X e Y deben existir juntos, admitir
  decimales y ser mayores que cero.
- No se admiten tamaños combinados en texto como `"15x10"` o `"31.7x22.6"`.

## Requirements *(mandatory)*

- **DR-001**: `orden_trabajo` DEBE ser la entidad central.
- **DR-002**: Cada OT confirmada DEBE tener 1–3 `ot_detalle` consecutivos.
- **DR-003**: (`orden_trabajo_id`, `numero_piso`) DEBE ser único.
- **DR-004**: Una OT PUEDE tener varios acabados sin repetir ninguno.
- **DR-005**: Los códigos funcionales, no IDs numéricos, DEBEN gobernar reglas de catálogos.
- **DR-006**: Una OT nueva DEBE iniciar con `ESTADO_OT/PENDIENTE`.
- **DR-007**: `perfil_usuario` DEBE enlazar Supabase Auth sin guardar credenciales.
- **DR-008**: Cabecera, pisos, acabados y auditoría de una OT forman una unidad lógica consistente.
- **DR-009**: El modelo DEBE soportar unas 19.000 OT, crecimiento, paginación e historial creciente.
- **DR-010**: Todos los nombres maestros DEBEN usar minúsculas y `snake_case`.
- **DR-011**: Cada `ot_detalle` DEBE registrar `armado` como la cantidad entera positiva de diseños
  distintos que participan en el montaje de su pliego.
- **DR-012**: Cada `ot_detalle` DEBE registrar `formato` como la cantidad entera positiva de
  posiciones totales del montaje dentro del pliego.
- **DR-013**: `armado` y `formato` DEBEN ser atributos separados y `formato` DEBE ser mayor o igual
  que `armado`; no se exige divisibilidad exacta entre ambos.
- **DR-014**: `total_pliegos` DEBE mantenerse como dato registrado y no como atributo calculado
  automáticamente mientras no exista una fórmula empresarial aprobada.
- **DR-015**: Cuando corresponda registrar el tamaño final, `ot_detalle` DEBE contener
  `tamano_final_x` y `tamano_final_y` como valores `numeric`, obligatorios conjuntamente y mayores
  que cero.
- **DR-016**: Cuando corresponda registrar el tamaño de corte, `ot_detalle` DEBE contener
  `tamano_corte_x` y `tamano_corte_y` como valores `numeric`, obligatorios conjuntamente y mayores
  que cero.
- **DR-017**: Los tamaños de material, final y corte DEBEN mantener componentes X/Y numéricos,
  atómicos y aptos para decimales; no se almacenan como texto combinado ni se presupone una unidad.

## COMPARACIÓN CON EL MODELO EXISTENTE

No existe material local para comparar: no se encontraron esquemas SQL, migraciones, exportaciones,
modelos relacionales ni diccionarios anteriores. El modelo maestro se construye desde Constitution,
Spec 000, Spec 001 y las reglas proporcionadas. No se inventan diferencias contra una base ausente.

## Convenciones y clasificación

- PK locales: `integer`; auditoría de alto crecimiento: `bigint`; identidad Auth: `uuid`.
- Texto: `text`; cantidades exactas: `numeric`; piso: `smallint`; fechas: `date`; eventos:
  `timestamptz`; estados binarios: `boolean`.
- “Generado” es un default lógico; el mecanismo físico se define después.

| Categoría | Entidades |
|---|---|
| Negocio | `cliente`, `orden_trabajo`, `ot_detalle`, `material`, `gramaje`, `maquina` |
| Catálogo | `parametro` |
| Relación | `ot_acabado` |
| Seguridad | `rol`, `perfil_usuario` |
| Auditoría | `auditoria_evento`, `auditoria_cambio` |
| Excluida | `tipo_material`, descartada mientras no exista una semántica diferenciada de `material` |

## MAPA DE RELACIONES

```text
cliente 1 ── N orden_trabajo 1 ── 1..3 ot_detalle
orden_trabajo 1 ── N ot_acabado N ── 1 parametro[ACABADO]
material 1 ── N ot_detalle; gramaje 0..1 ── N ot_detalle; maquina 1 ── N ot_detalle
parametro[TIPO_TRABAJO|ESTADO_OT] 1 ── N orden_trabajo
parametro[COLORIMETRIA|IMPRESION|MUESTRARIO] 1 ── N ot_detalle
rol 1 ── N perfil_usuario; Supabase Auth user 1 ── 0..1 perfil_usuario
perfil_usuario 1 ── N auditoria_evento 1 ── 1..N auditoria_cambio
```

## DICCIONARIO DE DATOS MAESTRO

En todas las tablas, `—` significa sin FK. Las reglas son lógicas, no SQL.

### `cliente`

Finalidad: cliente solicitante. PK: `id`.

| Atributo | Tipo | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `codigo` | text | No/— | UNIQUE, código estable |
| `nombre_comercial` | text | No/— | — |
| `nit`, `telefono`, `correo` | text | Sí/null | Unicidad de NIT pendiente en DP-007 |

Relación 1:N con OT. Eliminación restringida si tiene OT. Código estable. Fuente: regla CLIENTE.

### `orden_trabajo`

Finalidad: trabajo de producción. PK: `id`.

| Atributo | Tipo | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `codigo_ot` | text | No/— | UNIQUE |
| `cliente_id` | integer | No/— | FK `cliente` |
| `fecha_ot` | date | No/— | — |
| `cantidad` | numeric | No/— | > 0; precisión y escala pendientes en DP-009 |
| `tipo_trabajo_parametro_id` | integer | No/— | FK `parametro[TIPO_TRABAJO]` |
| `cantidad_paginas` | integer | Sí/null | > 0 cuando aplique; obligatoriedad futura en DP-002 |
| `nombre_trabajo` | text | No/— | — |
| `estado_ot_parametro_id` | integer | No/`PENDIENTE` | FK `parametro[ESTADO_OT]` |
| `creado_por_perfil_id`, `modificado_por_perfil_id` | integer | No/Sí | FK `perfil_usuario` |
| `creado_en`, `modificado_en` | timestamptz | No/Sí | Trazabilidad básica |

Relaciones: N:1 cliente, 1:1..3 detalles, 1:N acabados y auditoría. No persistir
`cantidad_pisos`: es derivado. Eliminación con dependencias es DP-003. Transiciones de estado quedan
en DP-008 para una Spec funcional. Fuente: Constitution II y reglas OT.

### `ot_detalle`

Finalidad: un piso de producción. PK: `id`.

| Atributo | Tipo | Nulo/default | Unicidad/FK y restricción |
|---|---|---|---|
| `id` | integer | No/generado | PK |
| `orden_trabajo_id`, `numero_piso` | integer, smallint | No/— | FK OT; UNIQUE conjunto; piso 1–3 |
| `material_id` | integer | No/— | FK `material` |
| `gramaje_id` | integer | Sí/null | FK `gramaje`; obligatoriedad futura en DP-001 |
| `tamano_material_x`, `tamano_material_y` | numeric | No/— | > 0; admiten decimales; unidad pendiente en DP-010 |
| `formato` | integer | No/— | > 0; `formato >= armado`; sin regla de divisibilidad |
| `armado` | integer | No/— | > 0; cantidad de diseños distintos del montaje |
| `total_pliegos` | integer | No/— | > 0; registrado, no calculado automáticamente |
| `colorimetria_parametro_id` | integer | No/— | FK `parametro[COLORIMETRIA]` |
| `cara_color` | text | No/— | `ANVERSO`, `REVERSO`, `AMBAS` |
| `impresion_parametro_id` | integer | No/— | FK `parametro[IMPRESION]` |
| `maquina_id` | integer | No/— | FK `maquina` |
| `muestrario_parametro_id` | integer | Sí/null | FK `parametro[MUESTRARIO]` |
| `tamano_final_x`, `tamano_final_y` | numeric | Condicional/— | Ambos obligatorios cuando aplica; > 0; admiten decimales; unidad en DP-010 |
| `tamano_corte_x`, `tamano_corte_y` | numeric | Condicional/— | Ambos obligatorios cuando aplica; > 0; admiten decimales; unidad en DP-010 |
| `cara_acabado` | text | Condicional/null | Dominio de caras; requerida si hay acabados |
| trazabilidad básica | integer/timestamptz | Según evento | FK perfil y momentos |

`tamano_material_z` se descarta y no forma parte del modelo. Eliminar con OT es DP-003. Renumerar
solo preservando el conjunto consecutivo. No se crea relación acabado-piso. Fuente: reglas PISOS e
información por piso y definición de montaje confirmada por Rosa Betania SRL.

#### Relación entre `armado` y `formato`

- `armado` = cantidad de diseños distintos que participan en el montaje de un pliego.
- `formato` = cantidad total de posiciones del trabajo distribuidas dentro del pliego de impresión.
- Los diseños identificados por `armado` pueden distribuirse o repetirse hasta completar las
  posiciones indicadas por `formato`.
- Ambos pertenecen a `ot_detalle` porque pueden variar según el piso o configuración de producción.
- Son atributos diferentes y no se combinan en una cadena como `"10(40)"`.

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

Por ejemplo, `armado = 10` y `formato = 40` representan diez diseños distintos distribuidos o
repetidos en cuarenta posiciones. `armado = 1` y `formato = 2` representan un diseño que ocupa o se
repite en dos posiciones. La única relación numérica aprobada es `formato >= armado`; no se define
`formato % armado = 0` ni ninguna otra fórmula.

`total_pliegos` continúa siendo un entero positivo registrado. El ejemplo `armado = 10`,
`formato = 40` y `total_pliegos = 117` no permite inferir una fórmula universal con `cantidad`; esa
eventual fórmula queda como regla funcional futura y no convierte el atributo en calculado en esta
Spec.

#### Dimensiones de material, tamaño final y tamaño de corte

El modelo utiliza una convención X/Y coherente para las tres dimensiones del piso:

- `tamano_material_x` y `tamano_material_y`;
- `tamano_final_x` y `tamano_final_y`;
- `tamano_corte_x` y `tamano_corte_y`.

Todos son valores `numeric`, positivos y aptos para decimales. Cuando corresponde registrar el
tamaño final, ambos componentes finales son obligatorios; cuando corresponde registrar el tamaño
de corte, ambos componentes de corte son obligatorios. No se admite registrar solo X o solo Y.

Ejemplos atómicos:

- tamaño final 15 × 10: `tamano_final_x = 15`, `tamano_final_y = 10`;
- tamaño de corte 31.7 × 22.6: `tamano_corte_x = 31.7`, `tamano_corte_y = 22.6`.

La presentación posterior puede mostrar `15 x 10` o `31.7 x 22.6`, pero esas cadenas no son la
representación estructural. La unidad dimensional exacta continúa pendiente: no se asumen
centímetros ni milímetros y no se agrega una columna de unidad sin una necesidad aprobada. Esta
decisión no altera la estructura X/Y.

### `material`, `gramaje`, `maquina`

| Entidad | Finalidad y PK | Atributos | Reglas |
|---|---|---|---|
| `material` | Insumo específico; `id integer` | `codigo text` UNIQUE, `descripcion text`, `estado boolean=true` | 1:N detalle; restringir eliminación; `tipo_material` queda excluida por no tener semántica diferenciada aprobada. |
| `gramaje` | Dominio numérico; `id integer` | `valor numeric` UNIQUE > 0, `estado boolean=true` | No guardar “gr”; DP-001 decide si será obligatorio para algún tipo de trabajo. |
| `maquina` | Recurso real; `id integer` | `nombre text`, `area text`, `estado boolean=true` | 1:N detalle; inactivar, no borrar si usada; unicidad y dominio de área pendientes en DP-007. |

### `parametro`

Finalidad: catálogos simples. PK: `id integer`. Atributos obligatorios: `grupo_codigo text`,
`valor_codigo text`, `descripcion text`, `estado boolean=true`. UNIQUE (`grupo_codigo`,
`valor_codigo`). Grupos: `TIPO_TRABAJO`, `COLORIMETRIA`, `IMPRESION`, `MUESTRARIO`, `ACABADO`,
`ESTADO_OT`. Cada FK debe validar el grupo esperado. Inactivar valores referenciados; no reciclar
códigos ni usar IDs como reglas.

### `ot_acabado`

Finalidad: relación multivaluada OT–acabado. PK compuesta (`orden_trabajo_id`,
`acabado_parametro_id`), ambas `integer` NOT NULL y FK a OT y `parametro[ACABADO]`. `posicion text` es
obligatoria con `IZQUIERDA|ARRIBA` para `PERFORADO|ENGOMADO` y debe ser null para los demás. Incluye
`creado_por_perfil_id integer` y `creado_en timestamptz`. Quitar un acabado es auditable; eliminación
con OT es DP-003.

### `rol` y `perfil_usuario`

| Entidad | PK y atributos | Reglas |
|---|---|---|
| `rol` | `id integer`; `codigo text` UNIQUE; `nombre text`; `estado boolean=true` | Valores iniciales `ADMINISTRADOR`, `USUARIO`; inactivar si está asignado. |
| `perfil_usuario` | `id integer`; `auth_usuario_id uuid` UNIQUE; `rol_id integer` FK; `estado boolean=true` | Una identidad Auth tiene 0..1 perfil; no guarda contraseñas; preservar si aparece en auditoría. |

Los permisos detallados quedan para Specs funcionales. El actor auditado se deriva del usuario
autenticado, nunca de un valor libre del navegador.

### `auditoria_evento` y `auditoria_cambio`

| Entidad | PK y atributos | Reglas |
|---|---|---|
| `auditoria_evento` | `id bigint`; `entidad_codigo text`; `registro_clave text`; `operacion text`; `actor_perfil_id integer` FK; `ocurrido_en timestamptz` | Operación `CREATE|UPDATE|DELETE`; inmutable; no depende en cascada del registro. |
| `auditoria_cambio` | `id bigint`; `auditoria_evento_id bigint` FK; `atributo_codigo text`; `valor_anterior` y `valor_nuevo` con representación física pendiente en DP-011 | Un atributo una vez por evento; inmutable; permite reconstrucción. |

En `CREATE`, anterior puede ser null; en `DELETE`, nuevo puede ser null. La representación física de
valores queda para Plan: no se aprueban JSON, snapshots, triggers, funciones ni event sourcing.

## CATÁLOGOS Y DOMINIOS

- `ESTADO_OT`: `PENDIENTE` aprobado como inicial; transiciones funcionales pendientes en DP-008.
- `COLORIMETRIA`: Full color, Pantone, Full + Pantone.
- `IMPRESION`: Tiro y volteo, Tira y retira, Cambio de pinza.
- `MUESTRARIO`: aprobación en máquina, prueba de color, muestra física, muestra digital, impresión
  de escritorio.
- `ACABADO`: incluye `PERFORADO`, `ENGOMADO`; catálogo completo pendiente en DP-008.
- `cara_color`/`cara_acabado`: `ANVERSO`, `REVERSO`, `AMBAS`.

## NORMALIZACIÓN DE NOMBRES Y 3FN

`ORDEN_TRABAJO` → `orden_trabajo`; `OT_DETALLE` → `ot_detalle`; `MÁQUINA` → `maquina`;
`Armado` → `armado`; `AUDITORIA/HISTORIAL` → `auditoria_evento` + `auditoria_cambio`.

- Pisos son filas, no columnas repetidas; acabados multivaluados usan `ot_acabado`.
- Cliente, materiales, recursos y descripciones de parámetros no se duplican en OT.
- `cantidad_pisos` no se almacena por ser derivada.
- `armado` y `formato` se almacenan como enteros separados: el primero representa diseños distintos
  y el segundo posiciones totales. La representación anterior `"10(40)"` queda descartada.
- Esta separación mejora la atomicidad: permite consultar y validar cada concepto de manera
  independiente sin codificar dos valores semánticos dentro de una cadena de texto.
- `tamano_final_x`, `tamano_final_y`, `tamano_corte_x` y `tamano_corte_y` son atributos atómicos
  `numeric`; se descartan `tamano_final = "15x10"` y `tamano_corte = "31.7x22.6"` como formas de
  almacenamiento.
- La separación X/Y mejora atomicidad, validación, comparaciones, cálculos futuros y consistencia
  con `tamano_material_x` y `tamano_material_y`.
- Evento y cambios de auditoría se separan por la relación 1:N.
- No se aprueba desnormalización. `tipo_material` se excluye mientras pueda duplicar `material`.

## MODELO LÓGICO DE AUDITORÍA VS MECANISMO

El modelo lógico usa `auditoria_evento` para actor, momento, entidad, registro y operación, y
`auditoria_cambio` para valores relevantes anteriores/posteriores. Permite reconstrucción y sobrevive
al borrado operativo. El mecanismo de captura, almacenamiento físico y autorización corresponde al
Plan; esta Spec no define SQL, triggers, funciones, RPC, RLS, JSON, event sourcing ni soft delete.

## DECISIONES PENDIENTES

La revisión se rehízo desde cero después de resolver `armado`, `formato`, la representación X/Y de
los tamaños, descartar `tamano_material_z` y excluir `tipo_material`. Quedan **11 decisiones
pendientes reales**: **0 bloquean la aprobación** y **11 no la bloquean**.

| ID | Decisión | Clasificación |
|---|---|---|
| DP-001 | Definir para qué trabajos `gramaje_id` es obligatorio. El modelo actual lo admite nullable y no requiere otra entidad. | **NO BLOQUEA APROBACIÓN** |
| DP-002 | Definir para qué trabajos `cantidad_paginas` aplica y es obligatoria. El modelo actual la admite nullable. | **NO BLOQUEA APROBACIÓN** |
| DP-003 | Definir la política de eliminación y acciones referenciales entre OT, detalles, acabados y demás dependencias; las relaciones ya están identificadas. | **NO BLOQUEA APROBACIÓN** |
| DP-004 | Definir el periodo de retención del historial completo de auditoría. | **NO BLOQUEA APROBACIÓN** |
| DP-005 | Definir qué entidades adicionales, además de OT, detalles y acabados, requieren historial completo. | **NO BLOQUEA APROBACIÓN** |
| DP-006 | Definir, si se desea automatizar en el futuro, la fórmula empresarial de `total_pliegos` en relación con `armado`, `formato` y `cantidad`. Hasta entonces se registra como entero positivo. | **NO BLOQUEA APROBACIÓN** |
| DP-007 | Definir unicidad de NIT y nombre de máquina, además del dominio de `area`. | **NO BLOQUEA APROBACIÓN** |
| DP-008 | Completar códigos de catálogos y transiciones de `ESTADO_OT` en las Specs funcionales. | **NO BLOQUEA APROBACIÓN** |
| DP-009 | Definir precisión y escala de `cantidad`. | **NO BLOQUEA APROBACIÓN** |
| DP-010 | Definir la unidad dimensional común de `tamano_material_x`, `tamano_material_y`, `tamano_final_x`, `tamano_final_y`, `tamano_corte_x` y `tamano_corte_y`. No se asumen cm ni mm y no se agrega una columna de unidad. | **NO BLOQUEA APROBACIÓN** |
| DP-011 | Definir posteriormente la representación física de `valor_anterior` y `valor_nuevo` de auditoría sin cambiar el modelo lógico evento–cambios. | **NO BLOQUEA APROBACIÓN** |

La representación atómica de los tamaños ya no es una decisión pendiente. La unidad dimensional sí
permanece pendiente, pero no cambia entidades, atributos fundamentales ni relaciones y por eso no
bloquea la aprobación estructural. Tampoco son decisiones pendientes `armado`, `formato`,
`tamano_material_z`, que se descarta, ni `tipo_material`, que no se incorpora sin una diferencia
empresarial demostrada.

## OBSERVACIONES DEL MODELO

| ID | Severidad | Elementos | Hecho, impacto y decisión |
|---|---|---|---|
| OBS-001 | RESUELTA | tamaños final y de corte | Se representan mediante cuatro atributos `numeric` atómicos: X/Y final y X/Y corte; no queda bloqueo estructural. |
| OBS-002 | RESUELTA | `armado`, `formato` | Son enteros positivos, obligatorios, separados y sujetos a `formato >= armado`, sin divisibilidad exigida. |
| OBS-003 | RESUELTA | `tamano_material_z` | Se descarta y no se reincorpora al modelo. |
| OBS-004 | RESUELTA | material/tipo_material | `tipo_material` se excluye para evitar duplicación semántica no justificada. |
| OBS-005 | MEDIA | gramaje | Se admite null hasta definir en qué trabajos es obligatorio; no cambia la estructura base. |
| OBS-006 | MEDIA | OT/dependencias | Falta elegir acciones referenciales de eliminación, sin alterar las relaciones aprobadas. |
| OBS-007 | MEDIA | auditoría | Retención, cobertura adicional y representación física determinan reglas futuras. |
| OBS-008 | MEDIA | parametro | Cada referencia debe proteger el grupo semántico esperado. |
| OBS-009 | MEDIA | modelo completo | No existe modelo previo para comparar o detectar datos heredados. |

## Trazabilidad de reglas críticas

| Regla | Modelo | Fuente |
|---|---|---|
| 1–3 pisos consecutivos | `ot_detalle`, unicidad y validación de conjunto | Reglas Spec 002 |
| Diseños distintos y posiciones totales | `ot_detalle.armado`, `ot_detalle.formato`; enteros positivos y `formato >= armado` | Definición confirmada por Rosa Betania SRL |
| `total_pliegos` registrado, sin fórmula inferida | `ot_detalle.total_pliegos` | Aclaración confirmada por Rosa Betania SRL |
| Tamaños final y de corte atómicos | `tamano_final_x`, `tamano_final_y`, `tamano_corte_x`, `tamano_corte_y`; `numeric` positivos | Definición confirmada por Rosa Betania SRL |
| Convención dimensional coherente | Componentes X/Y numéricos para material, final y corte; unidad pendiente | Definición confirmada por Rosa Betania SRL |
| Acabados múltiples/no repetidos/posición | `ot_acabado` | Reglas Spec 002 |
| Cara color/acabado y gramaje | dominios y FK de detalle | Reglas Spec 002 |
| Estado inicial PENDIENTE | `parametro[ESTADO_OT]` | Constitution/Spec 002 |
| Perfiles, roles y Auth externa | `perfil_usuario`, `rol` | Constitution V/Spec 000 |
| Historial completo | entidades de auditoría | Spec 001 AUD |
| Consistencia compuesta | unidad OT–pisos–acabados–auditoría | Spec 001 INT |
| 19.000 OT y crecimiento | tipos y paginación conceptual | Spec 001 PERF/SCL |

## Fuera de alcance

No se generan tablas reales, SQL, migraciones, índices físicos, triggers, funciones, RPC, RLS,
frontend, backend, Plan, Tasks ni código. Supabase no se modifica.

## Success Criteria *(mandatory)*

- **SC-001**: Las 12 entidades propuestas tienen finalidad, PK y atributos documentados.
- **SC-002**: Todas las relaciones expresan cardinalidad y reglas lógicas.
- **SC-003**: Las reglas críticas tienen trazabilidad explícita.
- **SC-004**: La revisión completa encuentra cero decisiones pendientes que cambien entidades,
  atributos fundamentales o relaciones.
- **SC-005**: Auditoría soporta `CREATE`, `UPDATE`, `DELETE` sin depender del registro operativo ni
  prescribir captura técnica.
- **SC-006**: La revisión encuentra cero SQL, migraciones, RLS, RPC, triggers o código.
- **SC-007**: La revisión de montaje encuentra `armado` y `formato` como dos enteros obligatorios,
  positivos y separados, con `formato >= armado` y sin una regla de divisibilidad no aprobada.
- **SC-008**: La revisión dimensional encuentra seis componentes X/Y numéricos y atómicos para
  material, tamaño final y tamaño de corte, sin cadenas combinadas ni unidad inventada.

## Assumptions

- OT, detalles y acabados son auditables; cobertura adicional queda pendiente.
- Una OT confirmada tiene al menos un piso; estados transitorios se definirán funcionalmente.
- `cara_acabado` es propiedad del piso para acabados globales; no existe relación acabado-piso.
- La unidad dimensional será una convención común futura para los componentes X/Y; su definición no
  altera la estructura aprobada y no se presume que sea centímetros ni milímetros.
- La Spec queda lista para revisión y aprobación humana; no se considera aprobada automáticamente.
