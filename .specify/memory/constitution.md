<!--
Sync Impact Report
- Version change: plantilla sin versión -> 1.0.0
- Modified principles: plantilla genérica -> 17 principios aprobados de RosaBetaniaOts
- Added sections: Propósito; I-XVII; metadatos del proyecto; flujo documental inicial
- Removed sections: placeholders y comentarios de ejemplo de la plantilla
- Templates requiring updates: no evaluadas ni modificadas por restricción explícita de alcance
- Follow-up TODOs: ninguno
-->

# Rosa Betania OTs Constitution

**Proyecto:** RosaBetaniaOts — Sistema de Órdenes de Trabajo  
**Organización:** Rosa Betania SRL  
**Versión:** 1.0.0  
**Estado:** Ratificada  
**Fecha de ratificación:** 2026-10-02  
**Última modificación:** 2026-10-02

---

## Propósito

El proyecto **RosaBetaniaOts** tiene como propósito desarrollar una herramienta digital para la
gestión de Órdenes de Trabajo de **Rosa Betania SRL**, empresa dedicada a la impresión física y
digital de material gráfico y publicitario.

El sistema deberá mejorar el registro, control, consulta y seguimiento de las Órdenes de Trabajo,
reduciendo la dependencia de procesos manuales y facilitando el acceso a la información necesaria
para la producción.

La solución será una aplicación web responsive con enfoque **mobile-first** para las operaciones de
registro y consulta rápida de Órdenes de Trabajo.

Las funciones administrativas, de parametrización, gestión de usuarios, revisión detallada y
análisis estarán optimizadas también para entorno de escritorio.

Esta Constitution define los principios obligatorios que deberán respetar las especificaciones, el
modelo de datos, la arquitectura, la implementación y la evolución futura del sistema.

## I. Arquitectura basada en datos — NO NEGOCIABLE

El modelo de datos relacional constituye el contrato estructural del sistema y será una de las
principales fuentes de verdad del proyecto.

Antes de iniciar la implementación funcional del backend o frontend deberá existir un modelo de
datos base suficientemente definido, documentado y aprobado.

El modelo deberá estar respaldado por un **Diccionario de Datos Maestro**, definido inicialmente en
la **Spec 002 — Diccionario de Datos**.

El Diccionario de Datos deberá documentar como mínimo:

- entidades;
- atributos;
- tipos de datos;
- claves primarias;
- claves foráneas;
- nulabilidad;
- restricciones;
- relaciones;
- cardinalidades;
- catálogos;
- estados;
- reglas de integridad;
- reglas de negocio representadas mediante datos;
- información de auditoría cuando corresponda.

La implementación no deberá introducir tablas, columnas, relaciones o reglas estructurales que no
estén justificadas por las especificaciones aprobadas.

### Evolución del modelo de datos

El modelo aprobado NO se considera inmutable.

Cuando una necesidad funcional real requiera modificarlo, el cambio deberá realizarse de forma
controlada.

Toda modificación estructural posterior deberá incluir:

- justificación funcional;
- identificación de la Spec que origina el cambio;
- análisis de impacto;
- actualización del Diccionario de Datos;
- migración versionada cuando corresponda;
- preservación de los datos existentes;
- actualización de contratos o RPC afectados;
- verificación de compatibilidad con frontend y backend;
- aprobación antes de considerarse definitiva.

Se priorizarán cambios compatibles y extensiones controladas frente a reestructuraciones
disruptivas.

## II. Órdenes de Trabajo como núcleo del dominio

La **Orden de Trabajo** constituye la entidad principal del dominio de RosaBetaniaOts.

Las decisiones funcionales, estructurales y de interfaz deberán priorizar la correcta creación,
consulta, actualización, seguimiento y control de las Órdenes de Trabajo.

Las reglas detalladas de una OT no deberán definirse únicamente en el código.

Deben estar documentadas previamente en las Specs correspondientes y, cuando tengan representación
estructural, también en el Diccionario de Datos.

El sistema deberá mantener una separación clara entre:

- información general de la Orden de Trabajo;
- información específica de producción;
- detalles o pisos de producción;
- catálogos y parámetros;
- acabados;
- estados;
- usuarios y permisos;
- información de auditoría.

Las reglas concretas sobre materiales, gramajes, impresión, colorimetría, máquinas, muestrario,
acabados y demás elementos de producción deberán quedar formalizadas en las Specs antes de ser
consideradas reglas definitivas del sistema.

## III. Mobile-First y operación multiplataforma

El registro y consulta rápida de Órdenes de Trabajo deberá diseñarse bajo un enfoque
**mobile-first**.

La interfaz deberá priorizar:

- rapidez de registro;
- claridad visual;
- mínima cantidad de acciones innecesarias;
- controles adecuados para pantallas táctiles;
- formularios comprensibles;
- jerarquía visual clara;
- prevención de errores de captura.

Todas las funcionalidades críticas deberán seguir siendo utilizables desde navegadores de
escritorio.

Las funciones administrativas, configuración, parametrización, mantenimiento y análisis podrán
aprovechar interfaces de escritorio más amplias cuando ello mejore la productividad.

Mobile-first NO significa limitar las capacidades de escritorio.

Significa que las operaciones principales deberán continuar siendo utilizables correctamente desde
dispositivos móviles.

## IV. Alcance controlado del MVP

El MVP deberá concentrarse en resolver el proceso principal de gestión de Órdenes de Trabajo.

El alcance inicial comprende:

1. autenticación de usuarios;
2. gestión de perfiles y roles;
3. autorización según rol;
4. creación de Órdenes de Trabajo;
5. consulta y listado de Órdenes de Trabajo;
6. visualización detallada de una OT;
7. edición de Órdenes de Trabajo;
8. cambio controlado de estado;
9. eliminación según permisos;
10. gestión de la información de producción asociada a la OT;
11. uso de catálogos y parámetros necesarios para registrar una OT;
12. trazabilidad básica de creación y modificación;
13. administración de usuarios cuando corresponda al rol autorizado.

Las reglas exactas de cada funcionalidad deberán documentarse en sus Specs respectivas.

Una funcionalidad que no esté incluida en el alcance aprobado no deberá incorporarse simplemente
porque sea técnicamente posible.

Toda ampliación deberá responder a una necesidad real de Rosa Betania SRL.

## V. Seguridad y control de acceso

La seguridad deberá formar parte de la arquitectura y no ser únicamente una característica visual
del frontend.

El sistema deberá contar con autenticación segura.

Las autorizaciones deberán verificarse en las capas responsables de proteger los datos y
operaciones.

Ocultar un botón en la interfaz NO será considerado una medida de seguridad suficiente.

El sistema deberá contemplar inicialmente los roles:

- Administrador;
- Usuario.

Las capacidades concretas de cada rol deberán quedar documentadas en las Specs funcionales
correspondientes.

Las operaciones sensibles deberán contar con protección adecuada.

Entre ellas pueden encontrarse:

- eliminación de Órdenes de Trabajo;
- gestión de usuarios;
- modificación de roles;
- modificación de parámetros administrativos;
- operaciones que alteren información crítica.

Las credenciales privilegiadas, claves administrativas o secretos de infraestructura nunca deberán
exponerse en código ejecutado por el navegador.

Las sesiones deberán gestionarse de forma segura.

Cuando la tecnología seleccionada lo permita, se deberán contemplar mecanismos razonables contra
abuso, accesos no autorizados y fuerza bruta.

## VI. Integridad y validación de datos

Las reglas críticas de negocio no deberán depender exclusivamente de validaciones realizadas en el
frontend.

El frontend deberá prevenir errores y mejorar la experiencia del usuario.

El backend y/o la base de datos deberán proteger la integridad de las operaciones críticas.

Cuando una regla pueda afectar la consistencia de los datos, deberá existir validación en una capa
confiable.

Las restricciones estructurales deberán expresarse preferentemente mediante mecanismos apropiados
del modelo relacional cuando corresponda:

- claves primarias;
- claves foráneas;
- restricciones UNIQUE;
- restricciones CHECK;
- NOT NULL;
- relaciones;
- transacciones;
- procedimientos o funciones controladas.

Las validaciones duplicadas entre frontend y backend solo se aceptarán cuando cada una tenga una
finalidad diferente:

- frontend para experiencia de usuario;
- backend/base de datos para integridad y seguridad.

## VII. Código limpio y mantenibilidad

Todo código deberá seguir principios de Clean Code.

Se priorizarán:

- nombres descriptivos;
- funciones con responsabilidades claras;
- bajo acoplamiento;
- alta cohesión;
- eliminación de duplicación innecesaria;
- manejo consistente de errores;
- separación de responsabilidades;
- estructuras fáciles de mantener;
- código comprensible antes que soluciones excesivamente sofisticadas.

No deberán incorporarse soluciones temporales que comprometan de forma conocida la mantenibilidad
del sistema sin documentar previamente la deuda técnica generada.

Las abstracciones deberán existir porque resuelven un problema real, no únicamente para anticipar
necesidades hipotéticas.

## VIII. Arquitectura y separación de responsabilidades

El sistema deberá mantener una arquitectura con responsabilidades claramente separadas.

Como principio general deberán diferenciarse:

- interfaz de usuario;
- lógica de aplicación;
- acceso a datos;
- autenticación y autorización;
- persistencia;
- infraestructura.

El frontend no deberá asumir responsabilidades que correspondan exclusivamente a seguridad o
integridad del backend.

La lógica crítica del negocio deberá concentrarse en componentes controlados y reutilizables.

La arquitectura concreta, tecnologías, frameworks, servicios y estrategia de despliegue deberán
documentarse en:

**Spec 000 — Definición Tecnológica**

La Constitution establece los principios; la Spec 000 establece las decisiones tecnológicas
concretas.

## IX. Responsive y consistencia de interfaz

La aplicación deberá ser responsive.

La interfaz deberá conservar consistencia en:

- navegación;
- formularios;
- botones;
- mensajes;
- estados;
- tablas;
- diálogos;
- controles de selección;
- validaciones.

Las operaciones críticas no deberán quedar ocultas o inutilizables debido al tamaño de pantalla.

La presentación deberá priorizar claridad, legibilidad y productividad sobre elementos puramente
decorativos.

El diseño visual deberá adaptarse al proceso real de trabajo de Rosa Betania SRL.

## X. Trazabilidad y auditoría

Las operaciones importantes deberán permitir identificar, cuando corresponda:

- quién creó un registro;
- cuándo fue creado;
- quién realizó la última modificación;
- cuándo ocurrió la modificación.

Cuando una funcionalidad requiera historial completo de cambios, esta deberá especificarse
explícitamente antes de implementarse.

No se asumirá automáticamente que disponer de fecha de modificación equivale a disponer de auditoría
histórica completa.

Las necesidades de auditoría deberán quedar documentadas en las Specs y representadas adecuadamente
en el modelo de datos.

## XI. Especificaciones antes de implementación

Ninguna funcionalidad relevante deberá implementarse únicamente a partir de una instrucción
informal.

Cada módulo o cambio funcional significativo deberá contar con una Spec suficientemente clara.

Las Specs deberán definir, cuando corresponda:

- propósito;
- actores;
- escenarios;
- historias de usuario;
- requisitos funcionales;
- reglas de negocio;
- casos límite;
- criterios de aceptación;
- dependencias;
- restricciones;
- criterios de éxito.

Las ambigüedades que puedan cambiar significativamente la solución deberán aclararse antes de
generar un plan de implementación.

## XII. Flujo de desarrollo dirigido por especificaciones

El proyecto seguirá un enfoque de desarrollo dirigido por especificaciones.

El flujo general será:

Constitution  
→ especificación  
→ clarificación  
→ planificación  
→ tareas  
→ implementación  
→ validación.

Para las bases documentales iniciales del proyecto y su continuidad hacia la implementación se
seguirá este orden obligatorio:

Constitution  
→ Spec 000 — Definición Tecnológica  
→ Spec 001 — Especificaciones No Funcionales  
→ Spec 002 — Diccionario de Datos  
→ Validación estructural  
→ Specs funcionales  
→ Plan  
→ Tasks  
→ Implementación.

La implementación funcional no deberá adelantarse a decisiones estructurales que aún estén
pendientes de validación.

## XIII. Criterios de aceptación obligatorios

Ninguna historia de usuario deberá considerarse preparada para implementación si no posee criterios
de aceptación verificables.

Los criterios deberán expresar resultados observables.

Siempre que sea posible deberán poder comprobarse mediante:

- prueba funcional;
- validación automatizada;
- consulta de datos;
- revisión de permisos;
- prueba de interfaz;
- prueba de integración.

Expresiones vagas como:

"debe funcionar bien"

"debe ser rápido"

"debe ser seguro"

no serán consideradas criterios suficientes sin una definición verificable asociada.

## XIV. Pruebas y validación

Cada implementación deberá validarse en función de la Spec que la originó.

La estrategia concreta de pruebas será definida en las especificaciones técnicas correspondientes.

Como mínimo, los cambios deberán verificar:

- criterios de aceptación;
- reglas de negocio;
- manejo de errores;
- integridad de datos;
- permisos;
- compatibilidad con funcionalidades existentes afectadas.

Un cambio no se considerará terminado únicamente porque compile o porque la interfaz pueda abrirse.

Debe demostrarse que satisface los requisitos correspondientes.

## XV. Simplicidad como criterio predeterminado

La solución más simple que cumpla correctamente los requisitos tendrá prioridad sobre una
alternativa más compleja.

No deberán introducirse:

- patrones innecesarios;
- abstracciones especulativas;
- infraestructura sin necesidad demostrada;
- microservicios sin justificación;
- duplicación de entidades;
- generalizaciones prematuras.

Toda complejidad adicional deberá justificar claramente el problema que resuelve.

## XVI. Gobernanza

Esta Constitution prevalece sobre decisiones técnicas informales que entren en conflicto con sus
principios.

Toda propuesta que implique:

- ampliar significativamente el alcance;
- modificar reglas estructurales;
- alterar el modelo de datos aprobado;
- cambiar una decisión arquitectónica fundamental;
- debilitar una regla de seguridad;
- introducir una incompatibilidad deliberada;

deberá contar con justificación documentada.

La propuesta deberá identificar:

1. necesidad funcional o técnica;
2. Specs afectadas;
3. impacto estructural;
4. impacto sobre datos existentes;
5. impacto sobre frontend y backend;
6. estrategia de migración cuando corresponda;
7. pruebas requeridas;
8. aprobación.

Las modificaciones de esta Constitution deberán quedar versionadas.

Se utilizará versionado semántico:

- **MAJOR:** cambio incompatible en los principios o gobernanza;
- **MINOR:** nuevo principio o ampliación sustancial;
- **PATCH:** aclaración o corrección que no altera las reglas esenciales.

## XVII. Autoridad y cumplimiento

Antes de aprobar una Spec, Plan o cambio estructural deberá verificarse su compatibilidad con esta
Constitution.

Cuando exista conflicto entre una decisión de implementación y la Constitution, deberá prevalecer
la Constitution hasta que esta sea formalmente modificada.

Un agente de IA, desarrollador o colaborador no deberá alterar decisiones fundamentales del proyecto
silenciosamente.

Cuando detecte una contradicción deberá:

- señalarla;
- identificar los documentos implicados;
- explicar su impacto;
- solicitar o documentar la decisión correspondiente antes de continuar.

La Constitution define las reglas del proyecto.

Las Specs definen qué necesita el sistema.

Los Planes definen cómo se implementará.

Las Tasks dividen ese plan en trabajo ejecutable.

El código deberá ser consecuencia de estas decisiones y no sustituirlas.

---

**Versión:** 1.0.0 | **Ratificada:** 2026-10-02 | **Última modificación:** 2026-10-02
