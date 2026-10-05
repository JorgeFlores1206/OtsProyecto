# Especificación: Spec 001 — Especificaciones No Funcionales

**Directorio de especificación**: `specs/001-especificaciones-no-funcionales`  
**Creada**: 2026-10-02  
**Estado**: APROBADA PARA CONTINUAR A SPEC 002  
**Última revisión**: 2026-10-02  
**Proyecto**: RosaBetaniaOts  
**Organización**: Rosa Betania SRL  
**Tipo**: Especificación documental no funcional  
**Fuentes obligatorias**: Constitution v1.0.0 y Spec 000 — Definición Tecnológica  
**Input**: Definir características de calidad, restricciones operativas y criterios verificables
para la aplicación web de gestión de Órdenes de Trabajo.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Validar la calidad mínima del sistema (Priority: P1)

Como responsable de Rosa Betania SRL, quiero criterios de calidad claros para decidir si el sistema
es suficientemente rápido, seguro, confiable y comprensible antes de ponerlo en operación.

**Why this priority**: Sin condiciones verificables, una implementación podría abrirse o compilar
sin satisfacer las necesidades operativas del negocio.

**Independent Test**: Una revisión de calidad puede asociar cada requisito aprobado con una evidencia
observable y separar los valores aún sujetos a aprobación humana.

**Acceptance Scenarios**:

1. **Given** una característica de calidad con fundamento suficiente, **When** se revisa esta Spec,
   **Then** aparece como `REQUISITO APROBADO` y puede verificarse sin conocer la estructura del código.
2. **Given** un objetivo numérico sin datos operativos, **When** se revisa esta Spec, **Then** aparece
   como `DECISIÓN PENDIENTE` o `RECOMENDACIÓN PARA VALIDAR`, nunca como requisito aprobado.
3. **Given** un criterio de terminación, **When** se evalúa el sistema, **Then** la evidencia esperada
   permite determinar objetivamente si el criterio se cumple.

---

### User Story 2 - Mantener una operación segura y recuperable (Priority: P2)

Como usuario autorizado, quiero que mis sesiones, datos y operaciones estén protegidos y que los
fallos temporales se gestionen de forma segura para trabajar sin accesos indebidos, duplicaciones o
pérdidas silenciosas.

**Why this priority**: Las Órdenes de Trabajo son el núcleo del dominio y su confidencialidad,
integridad y continuidad no pueden depender solo de la interfaz.

**Independent Test**: Se pueden simular errores de red, expiración de sesión, falta de autorización y
fallos parciales para comprobar que el sistema protege datos, informa al usuario y permite una
recuperación controlada.

**Acceptance Scenarios**:

1. **Given** una sesión inválida o expirada, **When** el usuario intenta una operación protegida,
   **Then** la operación no se ejecuta y el usuario recibe una orientación comprensible.
2. **Given** una interrupción durante una operación, **When** se recupera la conectividad, **Then** el
   sistema evita confirmar como exitosa una operación no verificada y previene duplicaciones.
3. **Given** un error interno, **When** se muestra el resultado, **Then** el usuario no ve secretos ni
   información técnica sensible y existe información diagnóstica correlacionable.

---

### User Story 3 - Operar desde móvil y escritorio (Priority: P3)

Como persona que trabaja en un entorno de imprenta, quiero registrar y consultar información desde
un navegador móvil y realizar tareas administrativas desde escritorio con controles claros y
consistentes.

**Why this priority**: La Constitution exige un enfoque mobile-first sin limitar el aprovechamiento
de pantallas de escritorio.

**Independent Test**: Los flujos críticos definidos posteriormente pueden recorrerse con entrada
táctil y con teclado en tamaños móviles y de escritorio, sin pérdida de información ni controles
inaccesibles.

**Acceptance Scenarios**:

1. **Given** una pantalla móvil soportada, **When** se accede a registro o consulta de OT, **Then** no
   se requiere desplazamiento horizontal de la página para completar el flujo.
2. **Given** información tabular extensa, **When** el espacio es reducido, **Then** la presentación se
   adapta sin ocultar acciones críticas ni perder el contexto indispensable.
3. **Given** una operación sensible, **When** se activa desde móvil o escritorio, **Then** la
   confirmación y el resultado son claros en ambos contextos.

---

### User Story 4 - Evolucionar con control y simplicidad (Priority: P4)

Como integrante del proyecto, quiero requisitos de mantenibilidad, observabilidad y escalabilidad
proporcionales al uso real para poder diagnosticar y cambiar el sistema sin incorporar complejidad
especulativa.

**Why this priority**: La evolución controlada reduce deuda técnica y conserva la simplicidad exigida
por la Constitution.

**Independent Test**: Un cambio puede revisarse contra responsabilidades, documentación, pruebas,
errores y deuda técnica sin exigir microservicios ni infraestructura no aprobada.

**Acceptance Scenarios**:

1. **Given** un cambio significativo, **When** se propone su incorporación, **Then** identifica la
   Spec de origen, impacto, evidencia de validación y deuda técnica conocida.
2. **Given** una propuesta de infraestructura compleja, **When** no existe una necesidad medible,
   **Then** se rechaza por incumplir el principio de simplicidad.

### Edge Cases

- Una solicitud puede llegar al servidor después de que el navegador informe un error de red; el
  sistema no debe inducir al usuario a repetirla sin verificar su resultado.
- La sesión puede expirar mientras un formulario contiene datos no guardados; la interfaz debe
  proteger la información capturada cuando sea seguro y orientar la reautenticación.
- Una lista puede crecer hasta dejar de ser razonable cargarla completa; deberá aplicarse paginación
  o un mecanismo equivalente según el umbral validado.
- Una dependencia externa puede responder lentamente, rechazar una solicitud o quedar indisponible;
  el sistema debe distinguir esos estados de un error de validación del usuario.
- Dos operaciones concurrentes pueden intentar cambios incompatibles; el resultado no debe producir
  un estado imposible ni una confirmación engañosa.
- Una restauración puede recuperar datos pero no configuración o permisos coherentes; las pruebas de
  recuperación deben comprobar el servicio completo dentro del alcance aprobado.
- La información extensa puede exceder el ancho móvil; debe conservarse el acceso a datos y acciones
  esenciales sin forzar una interfaz de escritorio reducida.

## Requirements *(mandatory)*

### Convenciones normativas

- **REQUISITO APROBADO** identifica una condición obligatoria sustentada por la Constitution, la
  Spec 000 o el alcance explícito de esta Spec.
- **DECISIÓN PENDIENTE** identifica un valor o elección que requiere información real o aprobación
  de Rosa Betania SRL.
- **RECOMENDACIÓN PARA VALIDAR** identifica un candidato no vinculante que puede usarse como punto de
  partida para una decisión posterior.
- Los términos DEBE y NO DEBE son normativos únicamente dentro de requisitos aprobados.

### 1. Rendimiento — REQUISITO APROBADO

- **PERF-001**: La carga inicial DEBE mostrar contenido útil o un estado de carga comprensible sin
  dejar una pantalla aparentemente bloqueada.
- **PERF-002**: El listado de Órdenes de Trabajo DEBE presentar primero una cantidad limitada y
  navegable de resultados cuando cargar el conjunto completo perjudique la respuesta percibida.
- **PERF-003**: Las operaciones comunes DEBEN producir retroalimentación visible inmediata y evitar
  activaciones repetidas mientras una misma acción esté en proceso.
- **PERF-004**: Toda operación que no se complete de forma perceptiblemente instantánea DEBE mostrar
  un estado de progreso o espera asociado a la acción iniciada.
- **PERF-005**: La interfaz DEBE seguir siendo comprensible bajo una conexión razonablemente lenta:
  conservar el contexto, informar esperas y permitir reintentos seguros cuando corresponda.
- **PERF-006**: Las consultas de listas DEBEN soportar paginación o un mecanismo equivalente de carga
  gradual; el umbral y tamaño de página son decisiones posteriores basadas en volumen real.
- **PERF-007**: Los objetivos de rendimiento DEBEN validarse en perfiles de dispositivo, red y
  volumen representativos acordados antes de la aceptación.
- **PERF-008**: Las validaciones de rendimiento DEBEN utilizar como referencia inicial un conjunto
  de al menos 19.000 Órdenes de Trabajo y contemplar que el volumen seguirá creciendo.
- **PERF-009**: Las validaciones DEBEN contemplar más de 10 usuarios registrados, sin asumir que
  todos operarán simultáneamente; la concurrencia de prueba se aprobará por separado.

**DECISIÓN PENDIENTE — Objetivos numéricos de rendimiento**: se conocen aproximadamente 19.000 OT,
crecimiento continuo y más de 10 usuarios totales, pero faltan la tasa de crecimiento, la
concurrencia simultánea, el perfil de red y los tiempos máximos aprobados. Sin esos datos no se
aprueban tiempos definitivos para carga inicial, listado u operaciones comunes.

### 2. Disponibilidad y continuidad — REQUISITO APROBADO

- **AVL-001**: El sistema DEBE reconocer la dependencia operativa de Supabase para autenticación y
  datos, y de Vercel para servir la aplicación web.
- **AVL-002**: Ante indisponibilidad temporal, la interfaz DEBE indicar que la operación no pudo
  verificarse, evitar afirmar éxito y ofrecer una acción segura de reintento cuando proceda.
- **AVL-003**: Después de una interrupción, el usuario DEBE poder recuperar una sesión válida o
  reautenticarse y continuar sin crear cambios duplicados.
- **AVL-004**: Las operaciones confirmadas como exitosas DEBEN permanecer consistentes tras la
  recuperación del servicio.
- **AVL-005**: Debe existir un procedimiento documentado y probado de respaldo y restauración antes
  de operar con información real.
- **AVL-006**: El sistema DEBE tratarse como herramienta operativa crítica de lunes a viernes de
  08:00 a 19:00 y sábados de 08:00 a 13:00.
- **AVL-007**: Durante el horario operativo, la continuidad DEBE priorizar la disponibilidad y la
  recuperación pronta; la operación normal NO DEBE depender de un procedimiento manual alternativo.
- **AVL-008**: Las interrupciones planificadas DEBEN programarse fuera del horario operativo siempre
  que sea posible y comunicarse con antelación suficiente.
- **AVL-009**: Debe existir un procedimiento excepcional de contingencia para una interrupción
  prolongada, aunque no constituya el modo normal de trabajo.

**DECISIÓN PENDIENTE — Disponibilidad objetivo**: el horario crítico está aprobado, pero Rosa
Betania SRL aún debe aprobar el porcentaje exacto de disponibilidad y la forma de medición. No se
establece un SLA numérico en esta versión.

**DECISIÓN PENDIENTE — Región técnica exacta**: no existe una restricción empresarial que obligue a
almacenar los datos en Bolivia o en una región determinada. La región de Supabase se seleccionará
posteriormente según disponibilidad, rendimiento y operación, sin alterar su aprobación como
plataforma.

### 3. Seguridad — REQUISITO APROBADO

- **SEC-001**: La autenticación DEBE realizarse mediante Supabase Auth.
- **SEC-002**: Autenticación y autorización DEBEN verificarse como responsabilidades independientes.
- **SEC-003**: Toda operación protegida DEBE rechazar sesiones ausentes, inválidas o expiradas.
- **SEC-004**: El cierre de sesión DEBE impedir el uso posterior de la sesión en el navegador dentro
  de las capacidades aprobadas para la gestión de sesiones.
- **SEC-005**: La experiencia DEBE procurar que la sesión permanezca iniciada hasta que el usuario
  cierre sesión voluntariamente y NO DEBE forzar el cierre únicamente por un periodo corto de
  inactividad. Esta persistencia deseada NO sustituye la validación, renovación y revocación segura
  de la sesión: se DEBE requerir reautenticación cuando la sesión haya sido revocada, sea inválida,
  ya no pueda renovarse de forma segura o exista una condición de seguridad que lo exija.
- **SEC-006**: Usuarios y componentes DEBEN operar con el mínimo privilegio necesario.
- **SEC-007**: Las operaciones sensibles DEBEN protegerse en mecanismos confiables del servidor o la
  base de datos, nunca únicamente mediante controles visuales.
- **SEC-008**: Ninguna clave `service_role`, credencial administrativa o secreto privilegiado DEBE
  incorporarse al frontend, repositorio o artefacto público.
- **SEC-009**: Las variables de entorno DEBEN distinguir valores públicos autorizados de secretos y
  DEBEN gestionarse fuera del código versionado.
- **SEC-010**: Toda comunicación en producción DEBE utilizar HTTPS.
- **SEC-011**: Las reglas críticas DEBEN validarse en una capa confiable aunque también exista
  validación de experiencia de usuario en el frontend.
- **SEC-012**: Los errores visibles y registros diagnósticos NO DEBEN exponer credenciales, tokens,
  datos sensibles, consultas internas ni detalles explotables.
- **SEC-013**: Los intentos no autorizados DEBEN rechazarse de forma consistente y generar evidencia
  diagnóstica apropiada cuando corresponda.
- **SEC-014**: Las políticas RLS, permisos por operación y RPC concretas se definirán posteriormente
  y NO forman parte de esta Spec.

La configuración concreta de tokens, renovación y sesiones de Supabase Auth se definirá
posteriormente respetando esta decisión de negocio y los controles de seguridad de la plataforma.

### 4. Usabilidad — REQUISITO APROBADO

- **USA-001**: Los flujos críticos DEBEN utilizar lenguaje comprensible para el personal de Rosa
  Betania SRL y evitar terminología técnica innecesaria.
- **USA-002**: Los formularios DEBEN agrupar información relacionada, identificar datos obligatorios
  y mantener una secuencia coherente con el trabajo real.
- **USA-003**: Las validaciones DEBEN mostrarse cerca del dato afectado, explicar qué debe corregirse
  y conservar los demás valores ingresados.
- **USA-004**: Las operaciones sensibles o destructivas DEBEN solicitar confirmación explícita y
  describir la consecuencia antes de ejecutarse.
- **USA-005**: Navegación, acciones, mensajes, estados y validaciones DEBEN conservar patrones
  consistentes en todo el sistema.
- **USA-006**: Las vistas DEBEN contemplar estados de carga, vacío, éxito, error y falta de permisos
  sin dejar al usuario ante una pantalla ambigua.
- **USA-007**: El sistema DEBE prevenir la pérdida accidental de información no guardada ante
  navegación, cierre o expiración de sesión cuando técnicamente sea seguro conservarla.
- **USA-008**: Una acción ejecutada DEBE producir una confirmación de éxito o una explicación de por
  qué no se completó; la ausencia de respuesta no es aceptable.
- **USA-009**: Los flujos críticos deberán validarse con personas representativas del entorno de
  imprenta antes de considerarse aceptados.
- **USA-010**: La presentación DEBE ser formal, profesional, moderna y visualmente atractiva. Esta
  decisión no define colores, tipografías, componentes ni layouts concretos.

### 5. Responsive y mobile-first — REQUISITO APROBADO

- **RSP-001**: El registro y la consulta rápida de OT DEBEN poder completarse desde un navegador
  móvil soportado sin requerir una aplicación nativa.
- **RSP-002**: Los controles interactivos DEBEN ser utilizables mediante entrada táctil, contar con
  separación suficiente y no depender exclusivamente de acciones de puntero como `hover`.
- **RSP-003**: Formularios, campos, botones y diálogos DEBEN adaptarse al ancho disponible sin
  superposiciones, recortes de contenido esencial ni desplazamiento horizontal de la página.
- **RSP-004**: Las tablas DEBEN ofrecer una adaptación que conserve identificación, datos y acciones
  críticas en pantallas estrechas; el patrón visual concreto se decidirá posteriormente.
- **RSP-005**: Los diálogos DEBEN mantener visibles su propósito, contenido esencial y acciones en
  pantallas móviles, permitiendo desplazamiento interno cuando sea necesario.
- **RSP-006**: El foco, la posición y los valores ingresados DEBEN conservarse razonablemente ante
  cambios de orientación o tamaño de ventana.
- **RSP-007**: Las pantallas de escritorio PUEDEN aprovechar mayor densidad y espacio, pero NO DEBEN
  eliminar la disponibilidad de operaciones críticas exigidas en móvil.
- **RSP-008**: La prioridad y cantidad de información visible PUEDEN adaptarse al espacio siempre que
  no se oculte información necesaria para comprender o completar la operación.

### 6. Compatibilidad — REQUISITO APROBADO

- **CMP-001**: El producto DEBE funcionar como aplicación web responsive mediante navegador en
  dispositivos Android, dispositivos iOS, equipos de escritorio y equipos portátiles.
- **CMP-002**: El producto NO se convertirá en aplicación Android nativa, iOS nativa ni Electron.
- **CMP-003**: La aceptación DEBE ejecutarse sobre una matriz documentada de navegador, versión,
  sistema operativo, tipo de dispositivo y tamaño de pantalla.
- **CMP-004**: Una versión fuera de la matriz aprobada PUEDE recibir soporte limitado, pero no debe
  presentarse como validada.
- **CMP-005**: La aplicación DEBE adaptarse correctamente a diferentes tamaños de pantalla sin
  convertirse en una aplicación Android nativa, iOS nativa o Electron.

**DECISIÓN PENDIENTE — Matriz de compatibilidad**: las categorías de dispositivo están aprobadas,
pero aún faltan navegadores, versiones mínimas, sistemas operativos y dispositivos representativos
para las pruebas de aceptación.

### 7. Integridad de datos — REQUISITO APROBADO

- **INT-001**: Los datos que una Spec funcional declare críticos DEBEN ser obligatorios y validados
  antes de confirmar la operación correspondiente.
- **INT-002**: La integridad NO DEBE depender exclusivamente del frontend.
- **INT-003**: El modelo definido en la Spec 002 DEBE impedir relaciones inválidas y estados
  estructuralmente imposibles mediante mecanismos apropiados.
- **INT-004**: Una operación compuesta que requiera éxito conjunto DEBE ser atómica o disponer de un
  resultado controlado que no deje información parcialmente confirmada.
- **INT-005**: Ante un fallo parcial, el sistema DEBE identificar qué se confirmó, qué no se confirmó
  y qué acción segura puede realizarse.
- **INT-006**: Los reintentos de operaciones NO DEBEN producir duplicados ni repetir efectos sin una
  verificación adecuada.
- **INT-007**: Las validaciones duplicadas solo se aceptan cuando la interfaz mejora la experiencia y
  la capa confiable protege integridad o seguridad.

### 8. Auditoría y trazabilidad — REQUISITO APROBADO

**TRAZABILIDAD BÁSICA** significa poder conocer, cuando corresponda, quién creó un registro, cuándo
fue creado, quién realizó su última modificación y cuándo ocurrió esa modificación.

**HISTORIAL COMPLETO DE CAMBIOS** significa conservar información suficiente para reconstruir los
cambios relevantes y sucesivos, no solo el estado actual y su última modificación.

- **AUD-001**: La información definida como auditable DEBE incluir trazabilidad básica e historial
  completo de cambios para operaciones `CREATE`, `UPDATE` y `DELETE` cuando correspondan.
- **AUD-002**: Cada evento auditable DEBE identificar al actor autenticado; la identidad NO DEBE
  proceder de un valor libre enviado por el navegador.
- **AUD-003**: Cada evento auditable DEBE permitir conocer la fecha y hora y el tipo de operación
  realizada. Las marcas temporales DEBEN ser coherentes y comparables; la convención concreta se
  documentará en la Spec 002.
- **AUD-004**: El historial DEBE conservar información suficiente para reconstruir modificaciones
  relevantes y sucesivas, incluida la creación, sin definir todavía su representación física.
- **AUD-005**: La eliminación de información auditable DEBE conservar quién eliminó el registro,
  cuándo lo eliminó y la información histórica necesaria, aunque el registro original deje de estar
  disponible en su forma operativa.

**DECISIÓN PENDIENTE — Retención del historial de auditoría**: el historial completo está aprobado,
pero Rosa Betania SRL aún debe definir durante cuánto tiempo debe conservarse. Las Specs funcionales
deberán identificar qué información es auditable dentro de cada módulo.

### 9. Mantenibilidad — REQUISITO APROBADO

- **MNT-001**: El código futuro DEBE usar nombres descriptivos y responsabilidades claras.
- **MNT-002**: Los componentes DEBEN favorecer bajo acoplamiento, alta cohesión y eliminación de
  duplicación innecesaria.
- **MNT-003**: Interfaz, lógica de aplicación, acceso a datos, autenticación, autorización,
  persistencia e infraestructura DEBEN conservar responsabilidades diferenciadas.
- **MNT-004**: El manejo de errores DEBE seguir criterios consistentes y reutilizables.
- **MNT-005**: Las decisiones no evidentes, contratos y procedimientos operativos DEBEN documentarse
  en el artefacto apropiado sin duplicar fuentes de verdad.
- **MNT-006**: Todo cambio significativo DEBE identificar su Spec de origen, impacto y evidencia de
  validación.
- **MNT-007**: La deuda técnica conocida DEBE documentarse con impacto, riesgo, responsable de
  decisión y condición de resolución.
- **MNT-008**: Las unidades con lógica propia DEBEN poder probarse de forma aislada cuando ello sea
  razonable, sin definir todavía estructura de carpetas ni herramientas.
- **MNT-009**: No se incorporarán abstracciones, servicios o patrones para necesidades hipotéticas.

### 10. Observabilidad y errores — REQUISITO APROBADO

- **OBS-001**: Los errores de red DEBEN distinguirse de errores de autenticación, autorización,
  validación, persistencia y fallos inesperados en el mensaje y acción ofrecidos al usuario.
- **OBS-002**: Los mensajes visibles DEBEN ser comprensibles, accionables y no revelar detalles
  técnicos sensibles.
- **OBS-003**: Los fallos inesperados DEBEN generar información diagnóstica suficiente para ubicar
  momento, contexto general, operación y correlación, sin registrar secretos ni datos sensibles
  innecesarios.
- **OBS-004**: Las operaciones sensibles fallidas DEBEN dejar evidencia diagnóstica cuando ello sea
  necesario para seguridad y soporte.
- **OBS-005**: El sistema DEBE evitar mostrar directamente mensajes internos de base de datos o de
  proveedores al usuario final.
- **OBS-006**: Debe existir un procedimiento para comunicar, investigar y cerrar incidentes antes de
  la operación productiva.
- **OBS-007**: No se selecciona en esta Spec una plataforma externa de monitoreo.

**DECISIÓN PENDIENTE — Retención y acceso a diagnósticos**: faltan periodo de retención, personal
autorizado y necesidades de reporte. Deben aprobarse antes de operar en producción.

### 11. Backups y recuperación — REQUISITO APROBADO

- **BKR-001**: La información operativa DEBE estar cubierta por una estrategia documentada de copia
  de seguridad compatible con las capacidades contratadas.
- **BKR-002**: El procedimiento de restauración DEBE probarse antes de depender del sistema en
  producción y repetirse con una periodicidad aprobada.
- **BKR-003**: Una prueba de restauración DEBE verificar integridad, acceso autorizado y utilidad de
  la información recuperada, no solo la existencia de una copia.
- **BKR-004**: El acceso a copias y restauraciones DEBE limitarse a personal autorizado y protegerse
  con mínimo privilegio.
- **BKR-005**: Los fallos de respaldo o restauración DEBEN detectarse, informarse y quedar disponibles
  para diagnóstico.
- **BKR-006**: La estrategia de protección y recuperación DEBE garantizar un RPO máximo de 1 hora;
  ante un incidente grave, la pérdida tolerable de información NO DEBE superar una hora.
- **BKR-007**: La estrategia DEBE procurar una pérdida inferior al RPO máximo siempre que sea
  razonablemente posible.

**DECISIÓN PENDIENTE — RTO**: la recuperación tiene prioridad alta y debe realizarse lo más pronto
posible, pero Rosa Betania SRL aún debe aprobar un tiempo máximo concreto para convertir esta
intención en un criterio medible.

### 12. Accesibilidad — REQUISITO APROBADO

- **ACC-001**: Texto, controles y estados DEBEN mantener contraste y legibilidad suficientes en los
  contextos de uso aprobados.
- **ACC-002**: Todo campo DEBE tener una etiqueta comprensible y una relación perceptible con sus
  instrucciones y errores.
- **ACC-003**: Los flujos críticos DEBEN poder navegarse con teclado en escritorio y mediante entrada
  táctil en móvil.
- **ACC-004**: El foco visible, los estados y los errores NO DEBEN comunicarse únicamente mediante
  color.
- **ACC-005**: Los controles táctiles DEBEN tener tamaño y separación suficientes para evitar
  activaciones accidentales.
- **ACC-006**: Mensajes, títulos y acciones DEBEN usar lenguaje directo y estructura comprensible.
- **ACC-007**: Esta Spec NO declara conformidad formal con WCAG ni con un nivel específico sin
  aprobación y validación correspondiente.

### 13. Escalabilidad — REQUISITO APROBADO

- **SCL-001**: La solución DEBE sostener como referencia inicial aproximadamente 19.000 Órdenes de
  Trabajo y su crecimiento posterior sin degradar los objetivos de calidad acordados.
- **SCL-002**: Listados y consultas DEBEN evitar depender de la carga completa de colecciones en
  crecimiento.
- **SCL-003**: La capacidad DEBE medirse antes de introducir optimizaciones o infraestructura
  adicional.
- **SCL-004**: No se incorporarán microservicios, Kubernetes, colas, caché compleja ni infraestructura
  distribuida sin una necesidad medible y una decisión arquitectónica aprobada.
- **SCL-005**: Se preferirá ampliar la arquitectura aprobada de forma simple y compatible antes de
  reestructurarla.
- **SCL-006**: La capacidad DEBE contemplar más de 10 usuarios totales sin interpretar ese dato como
  una cifra de concurrencia simultánea.

**DECISIÓN PENDIENTE — Capacidad objetivo**: se conocen el volumen inicial aproximado y que habrá
más de 10 usuarios, pero faltan la tasa de crecimiento, la concurrencia simultánea y los picos
operativos esperados para definir pruebas de carga.

### 14. Criterios medibles y condiciones de calidad — REQUISITO APROBADO

- **QLT-001**: Todo requisito no funcional aprobado DEBE vincularse antes de implementación con una
  prueba, inspección, medición o evidencia reproducible.
- **QLT-002**: Ninguna recomendación se convierte en requisito sin aprobación documentada.
- **QLT-003**: Ningún valor pendiente puede presentarse como criterio de aceptación definitivo.
- **QLT-004**: Los perfiles de prueba DEBEN documentar dispositivo, navegador, red, volumen de datos
  y condiciones relevantes para permitir repetición.
- **QLT-005**: Un cambio no se considera terminado por compilar o abrirse; DEBE satisfacer requisitos,
  errores, integridad, permisos y compatibilidad aplicables.
- **QLT-006**: Los resultados de validación DEBEN registrar requisito evaluado, entorno, resultado y
  evidencia suficiente.

### Recomendaciones para validar

Estos valores son candidatos no vinculantes y NO son requisitos aprobados:

| ID | RECOMENDACIÓN PARA VALIDAR | Información necesaria antes de aprobar |
|---|---|---|
| REC-001 | Contenido útil inicial visible en un máximo de 3 segundos. | Dispositivos, red, tamaño del paquete y percepción de usuarios reales. |
| REC-002 | Primera página del listado visible en un máximo de 2 segundos. | Volumen, filtros, tamaño de página y perfil de red. |
| REC-003 | Retroalimentación visual dentro de 0,1 segundos y estado de progreso para esperas mayores a 1 segundo. | Pruebas de percepción y comportamiento de operaciones reales. |
| REC-004 | Objetivo mensual inicial de disponibilidad de 99,5 %. | Horario operativo, criticidad y capacidades contratadas. |
| REC-005 | Objetivo de conformidad WCAG 2.2 nivel AA para los flujos críticos. | Aprobación del alcance y evaluación de esfuerzo. |
| REC-006 | Área táctil mínima de 44 por 44 píxeles CSS para controles principales. | Validación en dispositivos usados por el personal. |

### 15. Trazabilidad de decisiones pendientes de Spec 000

| # | Decisión pendiente de Spec 000 | Clasificación primaria | Tratamiento en esta Spec |
|---|---|---|---|
| 1 | Versiones soportadas y gestor de dependencias | D. Plan/implementación | Spec 001 exige compatibilidad y soporte; la selección concreta se difiere al Plan autorizado. |
| 2 | Matriz exacta de navegadores | A. Spec 001 | Se aprueba soporte web responsive en Android, iOS, escritorio y portátiles; las versiones exactas permanecen pendientes. |
| 3 | Métodos concretos de autenticación | C. Spec funcional posterior | Supabase Auth sigue aprobado; método de acceso y recuperación dependen de requisitos de usuarios. |
| 4 | Entornos, región y configuración de servicios | D. Plan/implementación | No existe restricción empresarial de residencia; la región y configuración exactas se seleccionarán según disponibilidad, rendimiento y operación. |
| 5 | Herramientas de pruebas y calidad | D. Plan/implementación | Esta Spec define evidencias y criterios; el Plan posterior seleccionará herramientas aprobadas. |
| 6 | Necesidad futura de backend separado | C. Spec funcional posterior | Solo una necesidad funcional, de integración o seguridad puede reabrir esta decisión. |
| 7 | Estrategia operativa | A. Spec 001 | Se aprueban horario crítico y RPO máximo de 1 hora; el SLA porcentual y el RTO numérico continúan pendientes. |

### 16. IMPLICACIONES PARA SPEC 002

Sin diseñar tablas, columnas ni mecanismos concretos, la Spec 002 deberá reflejar:

- identificación de datos críticos y su obligatoriedad;
- reglas de nulabilidad, unicidad, validez y consistencia justificadas por las Specs;
- relaciones válidas y prevención de estados estructuralmente imposibles;
- operaciones que requieran atomicidad o tratamiento controlado de fallos parciales;
- prevención de duplicaciones cuando una operación pueda reintentarse;
- separación entre validaciones de experiencia y protecciones confiables de integridad;
- necesidades de autorización y mínimo privilegio que después se expresarán mediante políticas
  concretas;
- trazabilidad de la creación, incluidas identidad autenticada del actor, fecha y hora;
- conservación de modificaciones sucesivas con actor autenticado, fecha y hora, tipo de operación e
  información suficiente para reconstruir los cambios relevantes;
- trazabilidad de eliminaciones con actor autenticado, fecha y hora, tipo de operación e información
  histórica suficiente;
- preservación del historial requerido aunque el registro original sea eliminado;
- convención temporal coherente para datos de auditoría;
- clasificación de información sensible y restricciones de acceso;
- requisitos de respaldo, restauración, conservación e integridad recuperada;
- capacidad estructural para el historial completo aprobado, sin presuponer su mecanismo físico;
- soporte para consultas paginadas o graduales sin fijar todavía índices ni consultas;
- trazabilidad entre cada restricción estructural y la Spec que la justifica.

### 17. Trazabilidad con la Constitution

| Principio constitucional | Aplicación en Spec 001 |
|---|---|
| I. Arquitectura basada en datos | Define restricciones de calidad que la Spec 002 deberá representar sin anticipar el modelo. |
| III. Mobile-First y operación multiplataforma | Convierte registro, consulta y operación táctil en condiciones verificables. |
| V. Seguridad y control de acceso | Establece sesión segura, mínimo privilegio, separación de autorización y protección de secretos. |
| VI. Integridad y validación de datos | Exige capa confiable, consistencia, atomicidad y control de fallos parciales. |
| VII. Código limpio y mantenibilidad | Define claridad, cohesión, bajo acoplamiento, deuda documentada y capacidad de prueba. |
| VIII. Arquitectura y separación de responsabilidades | Mantiene distintos frontend, autenticación, autorización, datos e infraestructura sin exigir backend separado. |
| IX. Responsive y consistencia de interfaz | Exige adaptación de formularios, tablas, diálogos, mensajes y acciones. |
| X. Trazabilidad y auditoría | Establece trazabilidad básica e historial completo obligatorio para información auditable. |
| XI. Especificaciones antes de implementación | Documenta calidad antes de Plan, Tasks y código. |
| XIII. Criterios de aceptación obligatorios | Separa requisitos aprobados, decisiones pendientes y recomendaciones no vinculantes. |
| XIV. Pruebas y validación | Requiere evidencia reproducible para rendimiento, errores, permisos, integridad y compatibilidad. |
| XV. Simplicidad como criterio predeterminado | Prohíbe infraestructura compleja sin necesidad medida y aprobada. |

### 18. Fuera de alcance

Esta Spec NO contiene ni autoriza:

- tablas, columnas, claves primarias, claves foráneas o modelo entidad-relación;
- SQL, migraciones, políticas RLS concretas o RPC concretas;
- estructura detallada ni reglas funcionales de una Orden de Trabajo;
- permisos detallados por operación;
- pantallas, componentes React, colores, tipografías o diseño visual definitivo;
- estructura concreta de código, herramientas de prueba o configuración de infraestructura;
- Plan, Tasks, implementación frontend o backend;
- aplicación Android nativa, iOS nativa o Electron.

### 19. PREGUNTAS PARA APROBACIÓN

1. ¿Qué porcentaje mínimo de disponibilidad debe cumplirse durante el horario operativo aprobado y
   sobre qué periodo debe medirse?
2. ¿Cuál es el tiempo máximo concreto de recuperación que debe aprobarse como RTO?
3. ¿Cuántos usuarios simultáneos y qué picos de trabajo deben utilizarse en pruebas de carga, y cuál
   es la tasa mensual aproximada de crecimiento de OT?
4. ¿Qué navegadores, versiones mínimas y dispositivos representativos integrarán la matriz formal de
   compatibilidad?
5. ¿Durante cuánto tiempo debe conservarse el historial completo de auditoría?
6. ¿Durante cuánto tiempo deben conservarse los diagnósticos, quién podrá consultarlos y qué reportes
   serán necesarios?
7. ¿Se aprueba usar WCAG 2.2 nivel AA como objetivo verificable para los flujos críticos?
8. ¿Se aprueban los tiempos candidatos de carga y retroalimentación de REC-001 a REC-003 o deben
   establecerse otros máximos?

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: El 100 % de las categorías solicitadas —rendimiento, disponibilidad, seguridad,
  usabilidad, responsive, compatibilidad, integridad, auditoría, mantenibilidad, observabilidad,
  recuperación, accesibilidad y escalabilidad— contiene requisitos verificables.
- **SC-002**: El 100 % de los valores numéricos sin fundamento se identifica como `DECISIÓN
  PENDIENTE` o `RECOMENDACIÓN PARA VALIDAR`, y cero recomendaciones se presenta como obligación.
- **SC-003**: Las siete decisiones pendientes de la Spec 000 tienen clasificación y destino
  documentados.
- **SC-004**: Los doce principios constitucionales requeridos cuentan con trazabilidad explícita.
- **SC-005**: Una revisión de alcance encuentra cero tablas, columnas, SQL, migraciones, políticas
  RLS, RPC, pantallas, componentes, Planes, Tasks o código definidos por esta Spec.
- **SC-006**: Todos los errores contemplados —red, autenticación, autorización, validación,
  persistencia e inesperados— tienen un comportamiento general seguro y comprensible definido.
- **SC-007**: La Spec 002 recibe una lista explícita de implicaciones de integridad, auditoría,
  seguridad, consistencia y recuperación sin recibir un diseño de datos anticipado.
- **SC-008**: Cada requisito aprobado puede asociarse antes de implementación con al menos una
  prueba, inspección, medición o evidencia reproducible.
- **SC-009**: La validación de recuperación demuestra que la pérdida máxima de información no supera
  el RPO aprobado de 1 hora.
- **SC-010**: Para cada operación auditable `CREATE`, `UPDATE` o `DELETE`, la evidencia permite
  identificar actor autenticado, fecha y hora, tipo de operación y cambios relevantes.

## Assumptions

- La aplicación seguirá la arquitectura aprobada en la Spec 000: React, Vite y JavaScript en el
  frontend; Supabase para autenticación y datos PostgreSQL; Vercel para despliegue web.
- No existe inicialmente un servidor backend tradicional separado.
- El sistema requiere conexión de red para autenticar, consultar o confirmar operaciones; esta Spec
  no aprueba operación offline.
- La trazabilidad básica y el historial completo de cambios forman parte del alcance para la
  información definida como auditable.
- Los requisitos funcionales y datos críticos concretos se definirán en Specs posteriores.
- La Spec 002 definirá el Diccionario de Datos después de aprobar las decisiones no funcionales que
  afecten su estructura.
- No se avanza a Plan, Tasks o implementación hasta completar el flujo documental constitucional.
