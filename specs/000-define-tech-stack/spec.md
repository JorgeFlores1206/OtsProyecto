# Especificación: Spec 000 — Definición Tecnológica

**Directorio de especificación**: `specs/000-define-tech-stack`  
**Creada**: 2026-10-02  
**Estado**: Borrador listo para revisión  
**Proyecto**: RosaBetaniaOts  
**Organización**: Rosa Betania SRL  
**Tipo**: Especificación documental no funcional  
**Input**: Definir las tecnologías base, sus responsabilidades, restricciones, riesgos y decisiones
pendientes para el sistema web de gestión de Órdenes de Trabajo.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Revisar y aprobar la base tecnológica (Priority: P1)

Como responsable del proyecto, quiero disponer de una definición tecnológica única y justificada
para evaluar si las herramientas seleccionadas son adecuadas antes de diseñar el modelo de datos o
iniciar cualquier implementación.

**Why this priority**: La base tecnológica condiciona las especificaciones posteriores y debe quedar
aprobada antes de la Spec 001 y la Spec 002.

**Independent Test**: Una persona revisora puede identificar, sin consultar código, todas las
tecnologías aprobadas, el propósito de cada una y la razón de su selección.

**Acceptance Scenarios**:

1. **Given** la Constitution ratificada y las tecnologías propuestas, **When** se revisa esta Spec,
   **Then** cada tecnología aprobada aparece con una responsabilidad y una justificación explícitas.
2. **Given** una tecnología no incluida entre las decisiones aprobadas, **When** se revisa esta Spec,
   **Then** la tecnología no se presenta como seleccionada ni se incorpora silenciosamente.
3. **Given** la necesidad de conocer la arquitectura base, **When** se revisan los esquemas
   conceptuales, **Then** puede comprenderse el recorrido de la aplicación hacia Supabase y el flujo
   de entrega hacia Vercel sin interpretar detalles de implementación.

---

### User Story 2 - Verificar límites arquitectónicos y de seguridad (Priority: P2)

Como responsable técnico o de seguridad, quiero conocer dónde reside cada responsabilidad y qué
restricciones son obligatorias para evitar que el frontend asuma controles de seguridad o integridad
que corresponden a una capa confiable.

**Why this priority**: La arquitectura basada en cliente y servicios administrados solo es aceptable
si autenticación, autorización, integridad y operaciones privilegiadas permanecen correctamente
separadas.

**Independent Test**: Una revisión documental puede confirmar la separación entre autenticación y
autorización, la prohibición de secretos privilegiados en el navegador y el tratamiento de
operaciones sensibles en mecanismos del servidor o la base de datos.

**Acceptance Scenarios**:

1. **Given** una operación sensible, **When** se determina su ubicación arquitectónica, **Then** no
   se confía su protección exclusivamente a la interfaz web.
2. **Given** una credencial con privilegios administrativos, **When** se revisan las restricciones,
   **Then** queda prohibida su inclusión en el frontend o en artefactos públicos.
3. **Given** que Supabase proporciona servicios de datos y seguridad, **When** se revisa la
   arquitectura, **Then** no se exige un servidor backend separado sin una necesidad documentada.

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
2. **Given** una propuesta de tabla, política RLS o RPC concreta, **When** se compara con el alcance,
   **Then** se identifica como materia de una Spec posterior.
3. **Given** una propuesta de servidor backend independiente, **When** no existe una necesidad
   funcional, de integración o de seguridad demostrada, **Then** no se incorpora a la arquitectura
   base.

### Edge Cases

- Si una funcionalidad futura no puede protegerse mediante los mecanismos aprobados, deberá
  documentarse la necesidad antes de incorporar un componente backend adicional.
- Si una operación requiere privilegios que no pueden exponerse al navegador, deberá ejecutarse en
  una capa confiable; el mecanismo concreto se definirá en la Spec correspondiente.
- Si una limitación de Supabase o Vercel entra en conflicto con un requisito aprobado, deberá
  registrarse el impacto y revisarse la decisión tecnológica de forma controlada.
- Si una tecnología cambia su modelo de soporte, compatibilidad o seguridad, la decisión deberá
  reevaluarse antes de actualizarla.
- Si una Spec posterior intenta definir tablas, RLS o RPC antes de la Spec 002 y de la validación
  estructural, deberá detenerse por incumplir el flujo constitucional.

## Requirements *(mandatory)*

### Requisitos documentales

- **FR-001**: Esta Spec DEBE identificar las tecnologías aprobadas y distinguirlas de las decisiones
  pendientes.
- **FR-002**: Esta Spec DEBE documentar la responsabilidad y justificación de cada tecnología
  aprobada.
- **FR-003**: Esta Spec DEBE describir la arquitectura conceptual de ejecución y el flujo conceptual
  de control de versiones y despliegue.
- **FR-004**: Esta Spec DEBE establecer restricciones verificables de seguridad, compatibilidad,
  mantenibilidad y separación de responsabilidades.
- **FR-005**: Esta Spec DEBE identificar riesgos técnicos sin convertir sus mitigaciones en
  implementación prematura.
- **FR-006**: Esta Spec DEBE delimitar expresamente las materias reservadas para Specs posteriores.
- **FR-007**: Cada decisión pendiente DEBE indicar qué información hace falta para resolverla.
- **FR-008**: Esta Spec DEBE mostrar trazabilidad explícita con los principios constitucionales
  aplicables.
- **FR-009**: Esta Spec NO DEBE definir funcionalidades del sistema, estructuras de datos, SQL,
  políticas RLS concretas, RPC concretas ni diseño visual definitivo.

### Decisiones tecnológicas aprobadas

| Área | Decisión | Responsabilidad | Justificación |
|---|---|---|---|
| Interfaz web | React | Construir la interfaz basada en componentes y gestionar la interacción del usuario. | Permite estructurar una interfaz responsive y reutilizable para flujos móviles y administrativos. |
| Herramienta de desarrollo frontend | Vite | Proporcionar el entorno de desarrollo y el proceso de construcción del frontend. | Favorece un ciclo de desarrollo simple y rápido para una aplicación web React. |
| Lenguaje del frontend | JavaScript | Expresar la lógica de presentación y la integración del cliente web. | Es la decisión aprobada para el frontend y cuenta con soporte directo en React y Vite. |
| Plataforma de servicios | Supabase | Proveer acceso administrado a datos, autenticación y mecanismos confiables de seguridad e integridad. | Reúne las capacidades base requeridas y evita incorporar inicialmente infraestructura adicional sin justificación. |
| Persistencia | PostgreSQL administrado mediante Supabase | Almacenar el modelo relacional y aplicar restricciones de integridad definidas posteriormente. | Cumple el principio constitucional de arquitectura basada en datos y ofrece capacidades relacionales maduras. |
| Autenticación | Supabase Auth | Gestionar identidad, inicio y continuidad de sesión mediante mecanismos de la plataforma. | Se integra con Supabase y permite mantener separadas la autenticación y la autorización. |
| Autorización de datos | Row Level Security (RLS) | Restringir el acceso a filas según el contexto autorizado en la base de datos. | Sitúa controles de acceso a datos en una capa confiable y no solo en la interfaz. |
| Operaciones controladas | RPC y funciones PostgreSQL, cuando corresponda | Encapsular operaciones atómicas, reglas de integridad u operaciones que requieran control del lado servidor/base de datos. | Permite proteger lógica crítica sin asumir automáticamente un servidor backend independiente. |
| Control de versiones local | Git | Registrar y comparar cambios de los artefactos del proyecto. | Aporta trazabilidad y evolución controlada. |
| Repositorio remoto | GitHub | Alojar y colaborar sobre el repositorio Git. | Centraliza el historial y facilita revisión y colaboración. |
| Despliegue frontend | Vercel | Publicar y servir la aplicación web construida. | Se ajusta al despliegue de un frontend web y reduce complejidad operativa inicial. |
| Desarrollo dirigido por especificaciones | Specify / GitHub Spec Kit | Ordenar Constitution, Specs, Planes, Tasks e implementación. | Materializa el flujo documental obligatorio definido por la Constitution. |
| Asistencia de desarrollo | Codex | Asistir en documentación y desarrollo bajo instrucciones y artefactos aprobados. | Apoya el trabajo sin sustituir la autoridad de la Constitution ni de las Specs. |
| Editor principal | Visual Studio Code | Editar y revisar los artefactos y el código futuro del proyecto. | Es el entorno de edición aprobado para el equipo. |
| Entorno de desarrollo | Windows 11 y PowerShell | Proporcionar el sistema operativo y la consola principal para los flujos locales. | Refleja el entorno operativo aprobado y permite estandarizar instrucciones futuras. |

Estas decisiones no fijan versiones de productos ni incorporan bibliotecas adicionales. Cualquier
cambio o incorporación deberá justificarse y documentarse de acuerdo con la gobernanza del proyecto.

### Decisión arquitectónica de alto nivel

La arquitectura base NO incluirá inicialmente un servidor backend tradicional separado. React y
Vite conformarán la aplicación web; el cliente de Supabase permitirá utilizar los servicios
autorizados de la plataforma; Supabase concentrará autenticación, persistencia relacional y los
controles confiables que correspondan.

La ausencia inicial de un servidor independiente no elimina la separación de responsabilidades. La
interfaz se ocupará de presentación y experiencia de usuario; la autorización, la integridad y las
operaciones privilegiadas deberán protegerse mediante capacidades del servidor o de la base de
datos. Un backend adicional solo podrá incorporarse si una necesidad documentada demuestra que la
arquitectura base no puede satisfacerla de forma segura y mantenible.

```text
Usuario
  ↓
Aplicación web responsive
React + Vite + JavaScript
  ↓
Cliente Supabase
  ↓
Supabase
  ├── Supabase Auth
  ├── PostgreSQL
  ├── RLS
  └── RPC / funciones PostgreSQL cuando corresponda
```

```text
Código y documentación
  ↓
Git
  ↓
GitHub
  ↓
Vercel
  ↓
Aplicación web desplegada
```

Los esquemas son conceptuales: no definen carpetas, componentes, contratos, consultas ni recursos
de despliegue.

### Restricciones de seguridad

- **SEC-001**: La autenticación DEBE realizarse mediante Supabase Auth.
- **SEC-002**: Autenticación y autorización DEBEN tratarse como responsabilidades distintas.
- **SEC-003**: Ocultar controles en React NO DEBE considerarse una autorización suficiente.
- **SEC-004**: Las operaciones sensibles DEBEN protegerse mediante mecanismos confiables del
  servidor o de la base de datos.
- **SEC-005**: Ninguna credencial administrativa, secreto privilegiado ni clave `service_role` DEBE
  incorporarse al frontend, al paquete publicado o al repositorio.
- **SEC-006**: Las variables de entorno DEBEN distinguir valores públicos permitidos de secretos y
  DEBEN gestionarse fuera del código versionado.
- **SEC-007**: La aplicación desplegada DEBE utilizar HTTPS en producción.
- **SEC-008**: Cada componente DEBE operar con el mínimo nivel de privilegio necesario.
- **SEC-009**: Las políticas RLS concretas, los permisos por rol y los mecanismos contra abuso se
  definirán y validarán en Specs posteriores antes de la implementación correspondiente.
- **SEC-010**: La integridad crítica NO DEBE depender exclusivamente de validaciones del frontend.

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

### Restricciones de mantenibilidad y evolución

- La solución DEBE conservar responsabilidades claras entre interfaz, lógica de aplicación, acceso
  a datos, autenticación, autorización, persistencia e infraestructura.
- La adopción de nuevas capas o servicios DEBE resolver una necesidad demostrada.
- Las reglas críticas DEBEN quedar documentadas antes de convertirse en código o configuración.
- Las versiones concretas y dependencias futuras DEBEN seleccionarse de forma compatible y
  registrarse en el artefacto técnico que corresponda antes de implementar.
- Los cambios de arquitectura DEBEN evaluar impacto sobre datos, seguridad, frontend, despliegue y
  Specs afectadas.

### Fuera de alcance

Esta Spec no define:

- tablas, columnas, relaciones, claves ni un modelo entidad-relación;
- procedimientos, funciones PostgreSQL, RPC o políticas RLS concretas;
- migraciones, SQL o modificaciones de base de datos;
- módulos funcionales definitivos ni la estructura detallada de las Órdenes de Trabajo;
- reglas específicas de materiales, gramajes, impresión, colorimetría, máquinas o acabados;
- diseño visual definitivo, componentes de interfaz ni estructura de carpetas;
- implementación frontend, backend o infraestructura;
- plan de implementación, tareas o código.

El modelo y el Diccionario de Datos pertenecen a la **Spec 002 — Diccionario de Datos**. Las reglas
funcionales pertenecen a sus Specs posteriores.

### Riesgos técnicos

| Riesgo | Impacto potencial | Tratamiento documental requerido |
|---|---|---|
| Controles confiados por error al frontend | Acceso no autorizado o pérdida de integridad | Exigir autorización e integridad en RLS, restricciones o mecanismos controlados definidos posteriormente. |
| Exposición de secretos en el paquete web | Compromiso de datos y operaciones privilegiadas | Clasificar variables, prohibir `service_role` en el cliente y revisar el artefacto publicado. |
| Acoplamiento excesivo a servicios de plataforma | Mayor costo de cambio futuro | Mantener responsabilidades explícitas y documentar cualquier dependencia nueva. |
| Crecimiento de complejidad en JavaScript | Menor mantenibilidad y más defectos | Definir convenciones y estrategia de calidad en una especificación posterior sin agregar herramientas ahora. |
| Compatibilidad de navegador no delimitada | Comportamiento inconsistente entre dispositivos | Aprobar una matriz de navegadores y versiones antes de validar el producto. |
| Incorporación prematura de un backend adicional | Sobrecosto operativo y arquitectónico | Requerir una necesidad funcional, de integración o de seguridad demostrada. |
| Uso inadecuado de RPC o funciones | Lógica opaca o difícil de mantener | Exigir justificación, contrato y trazabilidad con la Spec que origine cada operación. |

### Decisiones pendientes

Las siguientes cuestiones no bloquean la aprobación de esta base tecnológica, pero deberán
resolverse antes de que afecten una implementación:

1. **DECISIÓN PENDIENTE — Versiones soportadas y gestor de dependencias.** Falta determinar las
   versiones de React, Vite y demás herramientas aprobadas, además del gestor de dependencias y el
   runtime requerido por el proceso de construcción. Se necesita revisar compatibilidad y soporte
   vigente al preparar la implementación.
2. **DECISIÓN PENDIENTE — Matriz exacta de navegadores.** Falta definir navegadores y versiones
   mínimas para escritorio y móvil. Se necesitan datos sobre los dispositivos utilizados por Rosa
   Betania SRL y criterios de soporte de la Spec 001.
3. **DECISIÓN PENDIENTE — Métodos concretos de autenticación.** Supabase Auth está aprobado, pero
   aún no se ha definido si el acceso será por correo y contraseña u otros métodos compatibles. Se
   necesitan requisitos de usuarios, operación y recuperación de acceso de una Spec posterior.
4. **DECISIÓN PENDIENTE — Entornos, región y configuración de servicios.** Falta definir separación
   de entornos, región, dominio y parámetros operativos de Supabase y Vercel. Se necesitan requisitos
   no funcionales, disponibilidad, residencia de datos y operación.
5. **DECISIÓN PENDIENTE — Herramientas de pruebas y calidad.** Falta seleccionar herramientas para
   pruebas, análisis estático y formato. Se necesitan la estrategia de pruebas y los umbrales que se
   definirán en la Spec 001 o en el plan posterior autorizado.
6. **DECISIÓN PENDIENTE — Necesidad futura de backend separado.** La arquitectura base no lo incluye.
   Esta decisión solo se reabrirá si una Spec demuestra una integración, procesamiento, secreto u
   operación privilegiada que no pueda resolverse adecuadamente con los mecanismos aprobados.
7. **DECISIÓN PENDIENTE — Estrategia operativa.** Falta definir monitoreo, recuperación, copias de
   seguridad y continuidad. Se necesitan objetivos no funcionales y capacidades contratadas de los
   servicios.

### Trazabilidad con la Constitution

| Principio | Aplicación en esta Spec |
|---|---|
| I. Arquitectura basada en datos | Selecciona PostgreSQL administrado por Supabase y reserva el modelo para la Spec 002. |
| III. Mobile-First y operación multiplataforma | Exige una aplicación web responsive con prioridad para registro y consulta móvil. |
| V. Seguridad y control de acceso | Separa autenticación de autorización y prohíbe secretos privilegiados en el navegador. |
| VI. Integridad y validación de datos | Sitúa la integridad crítica en mecanismos confiables y no exclusivamente en React. |
| VII. Código limpio y mantenibilidad | Limita la complejidad, exige responsabilidades claras y pospone herramientas no aprobadas. |
| VIII. Arquitectura y separación de responsabilidades | Define las responsabilidades de interfaz, plataforma, datos, identidad, seguridad y despliegue. |
| IX. Responsive y consistencia de interfaz | Establece compatibilidad web en escritorio y móvil sin definir todavía el diseño visual. |
| XI. Especificaciones antes de implementación | Mantiene esta decisión como documento previo y prohíbe implementar materias no especificadas. |
| XII. Flujo de desarrollo dirigido por especificaciones | Reconoce esta Spec como Spec 000 y no avanza hacia Plan, Tasks o implementación. |
| XV. Simplicidad como criterio predeterminado | Adopta servicios administrados y excluye un backend separado mientras no exista una necesidad demostrada. |

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de las tecnologías aprobadas en el alcance de esta Spec tiene una
  responsabilidad y una justificación documentadas.
- **SC-002**: El 100 % de las restricciones de seguridad solicitadas está expresado como requisito
  verificable, incluida la prohibición de `service_role` en el frontend.
- **SC-003**: Los diez principios constitucionales requeridos cuentan con trazabilidad explícita.
- **SC-004**: Toda cuestión tecnológica importante no resuelta aparece como `DECISIÓN PENDIENTE` con
  la información necesaria para resolverla.
- **SC-005**: Una revisión de alcance confirma cero tablas, columnas, políticas RLS, RPC, SQL,
  migraciones, módulos funcionales, código, Planes o Tasks definidos por esta Spec.
- **SC-006**: Una persona revisora puede identificar sin consultar código el límite entre frontend,
  servicios de plataforma, persistencia, autenticación, autorización y despliegue.
- **SC-007**: La arquitectura base incorpora cero componentes tecnológicos adicionales no aprobados.

## Assumptions

- Esta Spec documenta una decisión tecnológica de alto nivel y no constituye autorización para
  implementar ni contratar servicios.
- La Orden de Trabajo seguirá siendo el núcleo del dominio, pero su estructura se definirá en Specs
  posteriores.
- PostgreSQL se consumirá como servicio administrado de Supabase; no se define una instalación
  autogestionada.
- Vercel desplegará únicamente el frontend mientras no se apruebe otro alcance.
- Las capacidades mencionadas de RLS, RPC y funciones son opciones arquitectónicas controladas, no
  diseños ni autorizaciones para crear objetos concretos.
- Las decisiones pendientes se resolverán respetando el orden Constitution → Spec 000 → Spec 001 →
  Spec 002 → Validación estructural → Specs funcionales → Plan → Tasks → Implementación.

