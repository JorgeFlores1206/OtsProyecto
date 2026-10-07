# Especificación: Spec 000 — Definición Tecnológica

**Directorio de especificación**: `specs/000-define-tech-stack`  
**Creada**: 2026-10-02  
**Enmendada**: 2026-10-07 (alineación con Constitution v1.1.0, principio XVIII)  
**Versión**: 1.1.0  
**Estado**: Borrador listo para revisión  
**Proyecto**: RosaBetaniaOts  
**Organización**: Rosa Betania SRL  
**Tipo**: Especificación documental no funcional  
**Input**: Definir las tecnologías base, sus responsabilidades, restricciones, riesgos y decisiones
pendientes para el sistema web de gestión de Órdenes de Trabajo, con backend y frontend como
entregables separados según la Constitution v1.1.0.

## Registro de enmienda

| Versión | Fecha | Cambio | Motivo |
|---|---|---|---|
| 1.0.0 | 2026-10-02 | Versión inicial: frontend React + Vite conectado directamente a Supabase, sin backend separado. | Arquitectura base original. |
| 1.1.0 | 2026-10-07 | Se incorpora un backend independiente (NestJS) que expone la API del sistema; el frontend deja de acceder directamente a Supabase; la autenticación pasa a ser gestionada por el backend; el lenguaje pasa de JavaScript a TypeScript; Supabase queda solo como posible proveedor de PostgreSQL; Vercel despliega ambos entregables. | Constitution v1.1.0, principio XVIII (entregables separados) y VIII (el frontend no accede a la persistencia). Resuelve el conflicto registrado en el Sync Impact Report de la Constitution. |

Decisiones de la versión 1.0.0 que quedan **reemplazadas** por esta enmienda:

- "La arquitectura base NO incluirá inicialmente un servidor backend tradicional separado."
- Supabase Auth como mecanismo de autenticación (SEC-001 anterior).
- RLS como mecanismo principal de autorización de datos.
- JavaScript como lenguaje del frontend.
- "Vercel desplegará únicamente el frontend."
- Decisión pendiente 6 (necesidad futura de backend separado): queda resuelta.

## Clarifications

### Session 2026-10-07

- Q: ¿Con qué lenguaje y framework se construirá el servidor backend de la Fase 1? → A: NestJS con
  TypeScript, según la enmienda 1.1.0 ya registrada; se descarta la alternativa Fastify + JavaScript.
- Q: ¿Qué nivel de trazabilidad se requiere para el MVP? → A: Solo campos de trazabilidad por
  registro (creado por, creado en, modificado por, modificado en), asignados por el backend. No hay
  historial de cambios con valores anteriores y nuevos ni consulta de auditoría; el recorrido de la
  OT sigue siendo su historial funcional.
- Q: ¿Qué sistemas operativos y asistentes de IA deben figurar como entorno de desarrollo aprobado?
  → A: Entorno de trabajo abierto y adaptable: no se impone sistema operativo, consola, editor ni
  asistente; los flujos automatizados del proyecto DEBEN ser multiplataforma.
- Q: ¿El acceso de usuarios será con correo y contraseña, cuentas creadas por ADMINISTRADOR y
  recuperación por correo? → A: Sí. Correo y contraseña; cuentas creadas por ADMINISTRADOR sin
  auto-registro; invitación y recuperación por correo enviadas por el backend. El proveedor de envío
  queda como decisión pendiente.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Revisar y aprobar la base tecnológica (Priority: P1)

Como responsable del proyecto, quiero disponer de una definición tecnológica única y justificada
para evaluar si las herramientas seleccionadas son adecuadas antes de diseñar el modelo de datos o
iniciar cualquier implementación.

**Why this priority**: La base tecnológica condiciona las especificaciones posteriores y debe quedar
aprobada antes de la Spec 001 y la Spec 002.

**Independent Test**: Una persona revisora puede identificar, sin consultar código, todas las
tecnologías aprobadas, el entregable al que pertenece cada una, su propósito y la razón de su
selección.

**Acceptance Scenarios**:

1. **Given** la Constitution ratificada y las tecnologías propuestas, **When** se revisa esta Spec,
   **Then** cada tecnología aprobada aparece con su entregable, una responsabilidad y una
   justificación explícitas.
2. **Given** una tecnología no incluida entre las decisiones aprobadas, **When** se revisa esta Spec,
   **Then** la tecnología no se presenta como seleccionada ni se incorpora silenciosamente.
3. **Given** la necesidad de conocer la arquitectura base, **When** se revisan los esquemas
   conceptuales, **Then** puede comprenderse el recorrido Frontend → API del Backend → PostgreSQL y el
   flujo de entrega de ambos entregables hacia Vercel sin interpretar detalles de implementación.

---

### User Story 2 - Verificar límites arquitectónicos y de seguridad (Priority: P2)

Como responsable técnico o de seguridad, quiero conocer dónde reside cada responsabilidad y qué
restricciones son obligatorias para evitar que el frontend asuma controles de seguridad o integridad
que corresponden al backend o a la base de datos.

**Why this priority**: La separación entre entregables solo aporta valor si autenticación,
autorización, integridad y operaciones privilegiadas residen efectivamente en el backend y en la
base de datos.

**Independent Test**: Una revisión documental puede confirmar que el frontend no accede a la
persistencia, que la autenticación y la autorización se verifican en el backend, y que ninguna
credencial privilegiada llega al navegador.

**Acceptance Scenarios**:

1. **Given** una operación sensible, **When** se determina su ubicación arquitectónica, **Then** su
   autorización se verifica en el backend y no se confía exclusivamente a la interfaz web.
2. **Given** una credencial de base de datos o un secreto de firma de tokens, **When** se revisan las
   restricciones, **Then** queda prohibida su inclusión en el frontend o en artefactos públicos.
3. **Given** una lectura o escritura de datos del dominio, **When** se revisa la arquitectura,
   **Then** dicha operación pasa por la API del backend y nunca directamente desde el frontend a la
   base de datos.
4. **Given** un cliente distinto de la interfaz web (CLI o MCP en Fase 2), **When** se revisa el
   mecanismo de autenticación, **Then** este no depende de capacidades exclusivas del navegador.

---

### User Story 3 - Gobernar decisiones futuras (Priority: P3)

Como integrante futuro del proyecto, quiero distinguir las decisiones ya aprobadas de las pendientes
y del alcance reservado a otras Specs para evolucionar la solución sin inventar reglas ni generar
sobrearquitectura.

**Why this priority**: Una separación explícita evita que elecciones aún no justificadas se conviertan
accidentalmente en compromisos del proyecto.

**Independent Test**: Cada aspecto no resuelto puede localizarse bajo `DECISIÓN PENDIENTE`, junto con
la información requerida y el momento documental en que debe resolverse.

**Acceptance Scenarios**:

1. **Given** una cuestión técnica sin información suficiente, **When** se consulta esta Spec,
   **Then** aparece como `DECISIÓN PENDIENTE` y no como una solución asumida.
2. **Given** una propuesta de tabla, endpoint o regla de negocio concreta, **When** se compara con el
   alcance, **Then** se identifica como materia de una Spec posterior.
3. **Given** una propuesta de trabajo de Fase 2 (MCP o CLI), **When** se compara con el alcance de
   la Fase 1, **Then** se identifica como fuera de alcance según el principio XVIII.

### Edge Cases

- Si una limitación del entorno serverless de Vercel entra en conflicto con un requisito aprobado,
  deberá registrarse el impacto y evaluarse el traslado del backend a un entorno de contenedor
  (contingencia aprobada) de forma controlada.
- Si una operación requiere estado persistente entre peticiones (por ejemplo, control de intentos
  de inicio de sesión), dicho estado DEBE residir en un almacenamiento externo y no en la memoria
  del proceso.
- Si una tecnología cambia su modelo de soporte, compatibilidad, licencia o seguridad, la decisión
  deberá reevaluarse antes de actualizarla.
- Si una Spec posterior intenta definir tablas, restricciones o endpoints antes de la Spec 002 y de
  la validación estructural, deberá detenerse por incumplir el flujo constitucional.
- Si el proveedor de PostgreSQL elegido ofrece servicios adicionales (autenticación, API REST,
  cliente para navegador), NO DEBEN utilizarse sin una enmienda de esta Spec.

## Requirements *(mandatory)*

### Requisitos documentales

- **FR-001**: Esta Spec DEBE identificar las tecnologías aprobadas y distinguirlas de las decisiones
  pendientes.
- **FR-002**: Esta Spec DEBE documentar el entregable, la responsabilidad y la justificación de cada
  tecnología aprobada.
- **FR-003**: Esta Spec DEBE describir la arquitectura conceptual de ejecución y el flujo conceptual
  de control de versiones y despliegue de cada entregable.
- **FR-004**: Esta Spec DEBE establecer restricciones verificables de seguridad, compatibilidad,
  mantenibilidad y separación de responsabilidades.
- **FR-005**: Esta Spec DEBE identificar riesgos técnicos sin convertir sus mitigaciones en
  implementación prematura.
- **FR-006**: Esta Spec DEBE delimitar expresamente las materias reservadas para Specs posteriores.
- **FR-007**: Cada decisión pendiente DEBE indicar qué información hace falta para resolverla.
- **FR-008**: Esta Spec DEBE mostrar trazabilidad explícita con los principios constitucionales
  aplicables.
- **FR-009**: Esta Spec NO DEBE definir funcionalidades del sistema, estructuras de datos, SQL,
  endpoints concretos ni diseño visual definitivo.
- **FR-010**: Esta Spec DEBE definir la tecnología del backend, su estrategia de despliegue y el
  mecanismo de autenticación entre frontend y backend, según el principio XVIII.

### Decisiones tecnológicas aprobadas

#### Transversales (todo el proyecto)

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Lenguaje | TypeScript | Expresar la lógica de backend, frontend y contratos con tipos estáticos. | Un solo lenguaje para ambos entregables; los tipos del contrato se comparten y los errores se detectan antes de ejecutar. Reemplaza a JavaScript (v1.0.0). |
| Runtime | Node.js (versión LTS) | Ejecutar el backend y los procesos de construcción. | Plataforma estándar para NestJS, Vite y las herramientas aprobadas. |
| Organización del repositorio | Monorepo con npm workspaces | Alojar backend, frontend y paquetes compartidos en un solo repositorio. | Facilita compartir contratos sin duplicarlos, manteniendo entregables separados. |
| Orquestación de tareas | Turborepo | Construir, probar y validar cada entregable de forma independiente y en el orden correcto. | Cumple el requisito de construir, probar y desplegar cada entregable por separado (XVIII). |
| Contrato API | Zod | Definir una única vez las estructuras de entrada y salida de cada operación. | Fuente única para validación en backend, validación de formularios y tipos; evita reglas duplicadas (VI). |
| Documentación del contrato | OpenAPI generado desde Zod (zod-to-openapi) | Publicar el contrato formal entre backend y clientes. | Cumple el requisito de contrato documentado (XVIII) y permite generar clientes, incluida la Fase 2. |
| Control de versiones local | Git | Registrar y comparar cambios de los artefactos del proyecto. | Aporta trazabilidad y evolución controlada. |
| Repositorio remoto | GitHub | Alojar y colaborar sobre el repositorio Git. | Centraliza el historial y facilita revisión y colaboración. |
| Integración continua | GitHub Actions | Ejecutar validaciones automáticas en cada cambio. | Impide integrar cambios que no superen pruebas (XIV). |
| Calidad de código | ESLint + Prettier | Detectar errores comunes y uniformar el formato. | Sostiene Clean Code y consistencia (VII). |
| Desarrollo dirigido por especificaciones | Specify / GitHub Spec Kit | Ordenar Constitution, Specs, Planes, Tasks e implementación. | Materializa el flujo documental obligatorio definido por la Constitution. |
| Asistencia de desarrollo | Abierta (por ejemplo, Codex o Claude Code) | Asistir en documentación y desarrollo bajo instrucciones y artefactos aprobados. | Cada integrante elige su asistente; todos operan bajo la Constitution, las Specs y las instrucciones compartidas del repositorio. |
| Entorno de desarrollo | Abierto y adaptable: sistema operativo, consola y editor a elección de cada integrante | Permitir que cada integrante trabaje con sus herramientas habituales. | Evita imponer un entorno único; la reproducibilidad se garantiza con flujos multiplataforma (DEV-001). |
| Entorno local de servicios | Docker + docker-compose | Ejecutar PostgreSQL y el backend en el equipo de desarrollo. | Permite desarrollar y probar sin depender de servicios contratados. |

#### Entregable Backend

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Framework | NestJS | Exponer la API del sistema y concentrar lógica de aplicación, autorización y acceso a datos. | Su organización en módulos, guards, interceptors y filtros materializa la separación de responsabilidades (VIII) sin inventar estructura propia. |
| Validación de entrada | nestjs-zod | Validar toda petición con los esquemas del contrato. | Reutiliza el contrato Zod; evita un segundo sistema de validación. |
| Configuración | @nestjs/config con validación al arranque | Cargar y verificar variables de entorno. | El servicio no inicia si falta un secreto requerido; elimina valores por defecto inseguros (V). |
| Autenticación | JWT de corta duración enviado como `Authorization: Bearer` | Identificar al usuario en cada petición. | Funciona igual para navegador, CLI o MCP (previsión de XVIII). Reemplaza a Supabase Auth (v1.0.0). |
| Continuidad de sesión | Refresh token rotativo almacenado con hash | Renovar el acceso sin reingresar credenciales. | Permite revocar sesiones; en navegador se transporta en cookie `HttpOnly`. |
| Métodos de acceso | Correo y contraseña; cuentas creadas por ADMINISTRADOR, sin auto-registro público | Definir cómo se identifican las personas usuarias. | Coherente con la clarificación de la Spec 003; resuelve la decisión pendiente 8. |
| Correo transaccional | Envío de invitaciones y recuperación de contraseña desde el backend mediante un proveedor externo (decisión pendiente 9) | Entregar enlaces de un solo uso y caducidad corta para activar la cuenta o restablecer la contraseña. | Sustituye el envío que antes realizaba Supabase Auth; las credenciales del proveedor permanecen solo en el backend (SEC-005). |
| Resguardo de contraseñas | argon2 | Almacenar contraseñas de forma irreversible. | Algoritmo recomendado actualmente para contraseñas. |
| Autorización | Guards y decoradores de rol en el backend | Verificar el rol y los permisos en cada operación. | Sitúa la autorización en una capa confiable (V). |
| Protección contra abuso | @nestjs/throttler con almacenamiento externo | Limitar intentos repetidos en operaciones sensibles. | Mitiga fuerza bruta (V); compatible con ejecución serverless. |
| Seguridad HTTP | helmet + CORS con lista blanca | Aplicar cabeceras de seguridad y restringir orígenes. | Solo el frontend oficial puede invocar la API desde un navegador. |
| Trazabilidad | Campos creado por / creado en / modificado por / modificado en asignados por el backend en cada escritura | Identificar quién creó y quién modificó por última vez cada registro, y cuándo. | Cumple exactamente el mínimo del principio X; el actor proviene de la identidad autenticada y nunca de la petición. Sin historial de cambios en el MVP. |
| Manejo de errores | Filtro global con códigos de error de dominio | Devolver errores con formato uniforme. | Contrato de errores predecible para todos los clientes (XVIII). |
| Salud del servicio | @nestjs/terminus | Informar disponibilidad de la API y de la base de datos. | Permite monitoreo y diagnóstico operativo. |
| Registro de eventos | pino | Generar registros estructurados con identificador por petición. | Facilita diagnóstico de incidentes. |
| Acceso a datos | Prisma (ORM) | Ejecutar consultas tipadas contra PostgreSQL. | Tipado extremo a extremo y experiencia previa del equipo. |
| Migraciones | Prisma Migrate | Versionar los cambios estructurales de la base. | Cumple la evolución controlada del modelo (I). |

#### Entregable Frontend

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Interfaz web | React | Construir la interfaz basada en componentes y gestionar la interacción del usuario. | Permite estructurar una interfaz responsive y reutilizable para flujos móviles y administrativos. |
| Herramienta de desarrollo frontend | Vite | Proporcionar el entorno de desarrollo y el proceso de construcción del frontend. | Genera una aplicación estática sin servidor propio, lo que impide el acceso directo a la persistencia (XVIII). |
| Componentes visuales | MUI | Proveer controles consistentes y adaptables a móvil y escritorio. | Sostiene la consistencia de interfaz (IX) y el enfoque mobile-first (III); experiencia previa del equipo. |
| Navegación | React Router | Gestionar pantallas y rutas protegidas por rol. | Estándar maduro para aplicaciones React. |
| Datos del servidor | TanStack Query | Obtener, cachear y sincronizar datos provenientes de la API. | Reduce lógica manual de carga, errores y actualización. |
| Cliente de la API | Cliente tipado generado desde OpenAPI | Invocar la API del backend con tipos derivados del contrato. | Un cambio incompatible del contrato se detecta al compilar. |
| Formularios | react-hook-form con validación Zod | Capturar y validar datos de las Órdenes de Trabajo en pantalla. | Validación de experiencia de usuario con las mismas reglas del contrato (VI). |
| Estado local | Zustand | Mantener la sesión y preferencias de interfaz. | Mínimo y suficiente; los datos del dominio residen en la API. |

#### Persistencia

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Base de datos | PostgreSQL administrado | Almacenar el modelo relacional y aplicar restricciones de integridad definidas en la Spec 002. | Cumple el principio de arquitectura basada en datos (I) y ofrece capacidades relacionales maduras. |
| Uso del proveedor | Exclusivamente como servidor PostgreSQL | Alojar la base con respaldos administrados. | Servicios adicionales del proveedor (autenticación, API REST, cliente para navegador) no se utilizan, para no eludir el backend (XVIII). |
| Credenciales de acceso | Usuario de base de datos sin privilegios de superusuario | Limitar lo que el backend puede hacer en la base. | Mínimo privilegio (V). |
| Conexión | Pooler de conexiones del proveedor; conexión directa solo para migraciones | Evitar el agotamiento de conexiones en ejecución serverless. | Requisito del modelo de despliegue aprobado. |

#### Despliegue

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Plataforma | Vercel | Publicar ambos entregables. | Plataforma conocida por el equipo; soporta NestJS y Vite sin configuración especial. |
| Separación | Dos proyectos Vercel independientes desde el mismo repositorio (backend y frontend) | Construir, desplegar y revertir cada entregable por separado. | Cumple el despliegue independiente exigido por XVIII. |
| Ejecución del backend | Vercel Functions | Ejecutar la API bajo demanda con escalado automático. | Reduce la operación de infraestructura. |
| Región | Misma región que la base de datos | Minimizar la latencia entre API y base. | Afecta directamente el tiempo de respuesta percibido. |
| Plan | Vercel Pro, precedido de un piloto con la prueba Pro | Cumplir las condiciones de uso comercial. | El plan Hobby está restringido a uso personal no comercial. |
| Contingencia | Contenedor en Railway | Alojar el backend si el modelo serverless resulta limitante. | El backend NestJS puede trasladarse sin cambios de código. |

Estas decisiones no fijan versiones de productos. Se utilizará la versión mayor estable vigente de
cada herramienta al preparar la implementación. Cualquier cambio o incorporación deberá
justificarse y documentarse de acuerdo con la gobernanza del proyecto.

### Decisión arquitectónica de alto nivel

La arquitectura base se compone de **dos entregables independientes**, conforme al principio XVIII:

- **Backend**: servidor NestJS que expone la API del sistema y concentra la lógica de aplicación,
  la autenticación, la autorización de operaciones, la trazabilidad y el acceso a la persistencia.
- **Frontend**: aplicación web React + Vite, responsive y mobile-first, que consume exclusivamente la
  API del backend.

El frontend NO accede directamente a la base de datos ni a servicios de persistencia. La base de
datos mantiene sus propias restricciones de integridad como última defensa: el backend complementa,
y no reemplaza, las garantías del modelo relacional (VI).

El contrato entre ambos entregables se define una sola vez con Zod y se publica como OpenAPI. La
API es utilizable por clientes distintos de la interfaz web, lo que habilita la Fase 2 sin
construir en la Fase 1 funcionalidades específicas para IA.

```text
Usuario (celular / PC)
  ↓
Entregable Frontend
React + Vite + TypeScript
  ↓  HTTPS + Bearer JWT
Entregable Backend — API
NestJS
  ├── Validación (contrato Zod)
  ├── Autenticación y autorización por rol
  ├── Reglas de negocio
  └── Trazabilidad (creado/modificado por y en)
  ↓  Prisma
PostgreSQL administrado
  └── Restricciones de integridad (definidas en Spec 002)

[Fase 2] Cliente MCP o CLI ──► misma API, misma autenticación y autorización
```

```text
Código y documentación
  ↓
Git
  ↓
GitHub ──► GitHub Actions (validaciones)
  ↓
Vercel
  ├── Proyecto Backend  ──► API desplegada
  └── Proyecto Frontend ──► Aplicación web desplegada
```

Los esquemas son conceptuales: no definen carpetas, componentes, endpoints, consultas ni recursos
de despliegue.

### Restricciones de seguridad

- **SEC-001**: La autenticación DEBE ser gestionada por el backend mediante tokens JWT de corta
  duración transportados en la cabecera `Authorization: Bearer`.
- **SEC-002**: Autenticación y autorización DEBEN tratarse como responsabilidades distintas.
- **SEC-003**: Ocultar controles en React NO DEBE considerarse una autorización suficiente; toda
  operación DEBE autorizarse en el backend.
- **SEC-004**: Las operaciones sensibles DEBEN protegerse en el backend y, cuando corresponda,
  reforzarse con restricciones de la base de datos.
- **SEC-005**: Ninguna credencial de base de datos, secreto de firma de tokens ni clave privilegiada
  DEBE incorporarse al frontend, al paquete publicado o al repositorio.
- **SEC-006**: Las variables de entorno DEBEN distinguir valores públicos permitidos de secretos,
  DEBEN gestionarse fuera del código versionado y DEBEN validarse al iniciar el backend.
- **SEC-007**: Ambos entregables DEBEN utilizar HTTPS en producción.
- **SEC-008**: Cada componente DEBE operar con el mínimo nivel de privilegio necesario, incluido el
  usuario con el que el backend se conecta a la base de datos.
- **SEC-009**: Los permisos concretos por rol y los umbrales contra abuso se definirán y validarán en
  Specs posteriores antes de la implementación correspondiente.
- **SEC-010**: La integridad crítica NO DEBE depender exclusivamente de validaciones del frontend.
- **SEC-011**: El frontend NO DEBE acceder directamente a la base de datos ni a servicios de
  persistencia para operaciones de negocio.
- **SEC-012**: Las contraseñas y los refresh tokens DEBEN almacenarse únicamente como hash.
- **SEC-013**: El backend DEBE aceptar peticiones de navegador únicamente desde los orígenes
  autorizados (CORS con lista blanca).
- **SEC-014**: Los enlaces de invitación y recuperación DEBEN ser de un solo uso, caducar y
  almacenarse únicamente como hash; la solicitud de recuperación NO DEBE revelar si un correo existe.

### Requisitos de compatibilidad

- **COMP-001**: El producto DEBE ser una aplicación web moderna; no será una aplicación móvil
  nativa ni una aplicación de escritorio empaquetada.
- **COMP-002**: La experiencia DEBE ser responsive y las operaciones principales DEBEN diseñarse
  bajo un enfoque mobile-first.
- **COMP-003**: La aplicación DEBE funcionar mediante navegador moderno en dispositivos móviles.
- **COMP-004**: La aplicación DEBE funcionar mediante navegador moderno en equipos de escritorio.
- **COMP-005**: Las funciones administrativas DEBEN poder aprovechar pantallas amplias sin impedir
  el acceso a funcionalidades críticas desde tamaños menores cuando la Constitution las exige.
- **COMP-006**: No se incorporarán Flutter, Electron ni tecnologías no aprobadas mediante esta Spec
  o una enmienda posterior.
- **COMP-007**: El mecanismo de autenticación de la API DEBE ser utilizable por clientes que no son
  navegadores.

### Restricciones de mantenibilidad y evolución

- La solución DEBE conservar responsabilidades claras entre interfaz, lógica de aplicación, acceso
  a datos, autenticación, autorización, persistencia e infraestructura.
- El backend DEBE separar en cada módulo la recepción de peticiones, las reglas de negocio y el
  acceso a datos.
- El contrato compartido NO DEBE depender de las tecnologías específicas de backend ni de frontend.
- La adopción de nuevas capas o servicios DEBE resolver una necesidad demostrada.
- Las reglas críticas DEBEN quedar documentadas antes de convertirse en código o configuración.
- Las versiones concretas y dependencias futuras DEBEN seleccionarse de forma compatible y
  registrarse en el artefacto técnico que corresponda antes de implementar.
- Los cambios de arquitectura DEBEN evaluar impacto sobre datos, seguridad, ambos entregables,
  despliegue y Specs afectadas.

### Restricciones del entorno de desarrollo

- **DEV-001**: Los flujos locales del proyecto (instalación, servicios, migraciones, pruebas,
  construcción) DEBEN poder ejecutarse en cualquier sistema operativo soportado por Node.js y
  Docker, mediante scripts npm, Docker o herramientas multiplataforma equivalentes.
- **DEV-002**: Ningún flujo obligatorio DEBE depender de una consola, editor o asistente de IA
  específico.
- **DEV-003**: Las instrucciones para asistentes de IA DEBEN mantenerse en un único documento
  compartido del repositorio, sin reglas divergentes por asistente.

### Restricciones derivadas del despliegue serverless

- **OPS-001**: El backend NO DEBE mantener estado de aplicación en la memoria del proceso entre
  peticiones.
- **OPS-002**: La conexión a PostgreSQL en ejecución DEBE realizarse mediante pooler de conexiones.
- **OPS-003**: Ninguna petición DEBE depender de procesamiento de larga duración; los procesos
  extensos deberán especificarse con un mecanismo propio antes de implementarse.

### Fuera de alcance

Esta Spec no define:

- tablas, columnas, relaciones, claves, secuencias ni un modelo entidad-relación;
- procedimientos, funciones PostgreSQL, restricciones CHECK concretas ni políticas RLS;
- migraciones, SQL o modificaciones de base de datos;
- endpoints, operaciones concretas de la API ni su formato detallado;
- módulos funcionales definitivos ni la estructura detallada de las Órdenes de Trabajo;
- reglas específicas de materiales, gramajes, impresión, colorimetría, máquinas o acabados;
- diseño visual definitivo, componentes de interfaz ni estructura de carpetas;
- requisitos no funcionales cuantitativos (concurrencia, idempotencia, latencia, disponibilidad);
- el entregable de Fase 2 (MCP o CLI);
- plan de implementación, tareas o código.

El modelo y el Diccionario de Datos pertenecen a la **Spec 002 — Diccionario de Datos**. Los
requisitos no funcionales cuantitativos pertenecen a la **Spec 001**. El contrato concreto de la API
y las reglas funcionales pertenecen a sus Specs posteriores. La Fase 2 requiere una Spec propia.

### Riesgos técnicos

| Riesgo | Impacto potencial | Tratamiento documental requerido |
|---|---|---|
| Controles confiados por error al frontend | Acceso no autorizado o pérdida de integridad | Exigir autorización en el backend e integridad en restricciones de la base definidas posteriormente. |
| Exposición de secretos en el paquete web | Compromiso de datos y operaciones privilegiadas | Mantener todos los secretos en el backend, clasificar variables y revisar el artefacto publicado. |
| Uso de servicios del proveedor de base de datos que eluden la API | Ruptura del principio XVIII | Restringir el proveedor a PostgreSQL y exigir enmienda para cualquier otro servicio. |
| Limitaciones del entorno serverless | Errores por conexiones, estado o tiempos de ejecución | Cumplir OPS-001 a OPS-003 y mantener la contingencia en contenedor documentada. |
| Agotamiento de conexiones a la base | Indisponibilidad del sistema | Uso obligatorio de pooler (OPS-002). |
| Divergencia entre contrato y entregables | Fallos de integración entre frontend y backend | Contrato único en Zod/OpenAPI y cliente tipado generado. |
| Latencia por distancia entre API y base | Experiencia lenta en móvil | Ubicar API y base en la misma región (decisión pendiente 4). |
| Mayor complejidad por dos entregables | Más esfuerzo de configuración y despliegue | Monorepo, contrato compartido y despliegue independiente automatizado. |
| Costos de plataforma no estimados | Gasto mayor al previsto | Medir el consumo durante el piloto con la prueba Pro antes de contratar. |

### Decisiones pendientes

Las siguientes cuestiones no bloquean la aprobación de esta base tecnológica, pero deberán
resolverse antes de que afecten una implementación:

1. **DECISIÓN PENDIENTE — Versiones soportadas.** Falta determinar las versiones de Node.js, NestJS,
   React, Vite, Prisma, Zod y demás herramientas aprobadas. Se necesita revisar compatibilidad y
   soporte vigente al preparar la implementación.
2. **DECISIÓN PENDIENTE — Matriz exacta de navegadores.** Falta definir navegadores y versiones
   mínimas para escritorio y móvil. Se necesitan datos sobre los dispositivos utilizados por Rosa
   Betania SRL y criterios de soporte de la Spec 001.
3. **DECISIÓN PENDIENTE — Proveedor de PostgreSQL administrado.** Opciones: Supabase o Neon. Se
   necesitan costos, región disponible, política de respaldos y condiciones de uso comercial.
4. **DECISIÓN PENDIENTE — Entornos, región y dominio.** Falta definir separación de entornos
   (desarrollo, piloto, producción), región común de API y base de datos, y dominios de ambos
   entregables. Se necesitan requisitos no funcionales, residencia de datos y el dominio de Rosa
   Betania SRL.
5. **DECISIÓN PENDIENTE — Almacenamiento del control de abuso.** Opciones: tabla en PostgreSQL o
   servicio externo de clave-valor. Se necesitan los umbrales que defina la Spec 001.
6. **DECISIÓN PENDIENTE — Herramientas de pruebas.** Candidatas: Jest o Vitest (unitarias),
   Testcontainers (integración con PostgreSQL real), Supertest (API) y Playwright (extremo a
   extremo). Se necesitan la estrategia de pruebas y los umbrales de la Spec 001.
7. **DECISIÓN PENDIENTE — Estrategia operativa.** Falta definir monitoreo de errores (candidato:
   Sentry), recuperación, copias de seguridad y continuidad. Se necesitan objetivos no funcionales y
   capacidades contratadas de los servicios.
8. **RESUELTA (2026-10-07) — Métodos de autenticación para el usuario.** Correo y contraseña,
   cuentas creadas por ADMINISTRADOR, invitación y recuperación por correo enviadas por el backend.
9. **DECISIÓN PENDIENTE — Proveedor de correo transaccional.** Candidatos: Resend, Amazon SES o el
   SMTP del dominio de Rosa Betania SRL. Se necesitan el dominio remitente, costos, volumen esperado
   y requisitos de entregabilidad (SPF, DKIM).

### Trazabilidad con la Constitution

| Principio | Aplicación en esta Spec |
|---|---|
| I. Arquitectura basada en datos | Selecciona PostgreSQL administrado, migraciones versionadas y reserva el modelo para la Spec 002. |
| III. Mobile-First y operación multiplataforma | Exige una aplicación web responsive con prioridad para registro y consulta móvil. |
| IV. Alcance controlado del MVP | Limita esta Spec a la Fase 1 y excluye el entregable de Fase 2. |
| V. Seguridad y control de acceso | Sitúa autenticación y autorización en el backend, prohíbe secretos en el navegador y exige protección contra abuso. |
| VI. Integridad y validación de datos | Valida en backend con el contrato y mantiene las restricciones de la base como última defensa. |
| VII. Código limpio y mantenibilidad | Exige capas separadas en el backend, contrato único y herramientas de calidad. |
| VIII. Arquitectura y separación de responsabilidades | Define backend y frontend como entregables separados y prohíbe el acceso del frontend a la persistencia. |
| IX. Responsive y consistencia de interfaz | Adopta una librería de componentes consistente sin definir todavía el diseño visual. |
| X. Trazabilidad y auditoría | Fija la trazabilidad mínima (creación y última modificación) asignada por el backend; el MVP no incluye historial completo de cambios. |
| XI. Especificaciones antes de implementación | Mantiene esta decisión como documento previo y prohíbe implementar materias no especificadas. |
| XII. Flujo de desarrollo dirigido por especificaciones | Reconoce esta Spec como Spec 000 y no avanza hacia Plan, Tasks o implementación. |
| XIV. Pruebas y validación | Incorpora integración continua y define las herramientas de prueba como decisión pendiente con candidatas. |
| XV. Simplicidad como criterio predeterminado | Un solo lenguaje, un solo repositorio y una sola plataforma de despliegue; sin microservicios. |
| XVI. Gobernanza | Documenta la enmienda 1.0.0 → 1.1.0 con su motivo y las decisiones reemplazadas. |
| XVIII. Entregables por fases | Define tecnología, despliegue independiente y autenticación del backend; contrato documentado; API utilizable por clientes no web. |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de las tecnologías aprobadas en el alcance de esta Spec tiene un entregable,
  una responsabilidad y una justificación documentados.
- **SC-002**: El 100 % de las restricciones de seguridad está expresado como requisito verificable,
  incluida la prohibición de acceso directo del frontend a la persistencia.
- **SC-003**: Los quince principios constitucionales aplicables cuentan con trazabilidad explícita.
- **SC-004**: Toda cuestión tecnológica importante no resuelta aparece como `DECISIÓN PENDIENTE` con
  la información necesaria para resolverla.
- **SC-005**: Una revisión de alcance confirma cero tablas, columnas, endpoints, SQL, migraciones,
  módulos funcionales, código, Planes o Tasks definidos por esta Spec.
- **SC-006**: Una persona revisora puede identificar sin consultar código el límite entre frontend,
  backend, persistencia, autenticación, autorización y despliegue.
- **SC-007**: La arquitectura base incorpora cero componentes tecnológicos adicionales no aprobados.
- **SC-008**: El registro de enmienda identifica el 100 % de las decisiones de la versión 1.0.0
  reemplazadas por esta versión.

## Assumptions

- Esta Spec documenta una decisión tecnológica de alto nivel y no constituye autorización para
  implementar ni contratar servicios.
- La Orden de Trabajo seguirá siendo el núcleo del dominio, pero su estructura se definirá en Specs
  posteriores.
- PostgreSQL se consumirá como servicio administrado; no se define una instalación autogestionada
  para producción.
- Vercel desplegará ambos entregables como proyectos independientes. La contratación del plan Pro se
  realizará tras un piloto con la prueba Pro.
- El desarrollo diario se realizará en entorno local sin depender de servicios contratados.
- Las Specs 001 y 003 deberán revisarse tras esta enmienda: la Spec 003 asumía conexión directa del
  frontend a Supabase.
- La reducción de la trazabilidad al mínimo del principio X exige enmendar la Spec 002 (entidades
  `auditoria_evento` y `auditoria_cambio`) y la Spec 003 (US9, FR-030, FR-074–FR-077, SC-010).
- Las decisiones pendientes se resolverán respetando el orden Constitution → Spec 000 → Spec 001 →
  Spec 002 → Validación estructural → Specs funcionales → Plan → Tasks → Implementación.