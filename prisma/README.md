# Modelo físico inicial

Este directorio representa en Prisma y SQL el modelo vigente de las Specs 000–003. La migración
`20261009104748_initial_schema` es la fuente reproducible de las 15 tablas de negocio creadas en
`public`; `schema.prisma` representa las mismas tablas, columnas, claves, relaciones e índices.

## Detalles técnicos conservadores

- Las claves locales `integer` y las históricas `bigint` usan columnas identity.
- Las dimensiones y el gramaje usan `numeric(12,3)`; la precisión es física y no agrega una regla
  empresarial.
- Los textos usan `text`, sin límites arbitrarios.
- `codigo_ot` conserva el tipo `text` y se genera correlativamente desde una secuencia; la
  representación decimal no introduce prefijo o formato empresarial no aprobado.
- Las restricciones entre grupos de `parametro`, los pisos consecutivos, la posición de acabados,
  la secuencia/inmutabilidad de movimientos y la prohibición de eliminar una OT se materializan con
  triggers porque no pueden expresarse completamente mediante FK/CHECK simples.
- Los códigos de MUESTRARIO son normalizaciones estables, en mayúsculas ASCII y `snake_case`, de
  los cinco nombres explícitos de Spec 002. No se cargan valores de TIPO_TRABAJO porque las Specs no
  definen ninguno.
- No se crea un índice para “un USUARIO activo por sector”: Spec 002 declara la regla lógica pero
  deja sin aprobar su mecanismo físico.
- Se habilita RLS sin políticas de Data API y se revocan todos los privilegios de `anon` y
  `authenticated`: el Data API y Supabase Auth no forman parte de la arquitectura vigente. No se
  inventa un rol de aplicación; antes del backend deberá aprobarse el rol PostgreSQL de mínimo
  privilegio, sus grants y las políticas que correspondan.
- Spec 000 aún deja pendiente la versión exacta de Prisma. Por eso este trabajo no instala paquetes
  ni genera Prisma Client.

La migración remota se aplica mediante el MCP de Supabase. Al incorporar Prisma Migrate al backend,
este baseline deberá registrarse como aplicado con la versión aprobada de Prisma, sin volver a
ejecutarlo sobre una base ya materializada.

## Registro de aplicación

- Proyecto Supabase: `OtsProyecto-dev`
- `project_ref`: `rrjtgrytrwqfkhuibwxz`
- Migración MCP: `initial_ot_schema`
- Versión registrada por Supabase: `20261009145823`
