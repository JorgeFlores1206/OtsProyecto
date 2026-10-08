# Specification Quality Checklist: Spec 002 — Diccionario de Datos

**Purpose**: Validar el modelo lógico completo antes de su aprobación humana
**Created**: 2026-10-02
**Reevaluated**: 2026-10-06
**Approved**: 2026-10-06
**Feature**: [Spec 002 — Diccionario de Datos](../spec.md)

## Content Quality

- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

## Requirement Completeness

- [x] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous
- [x] Success criteria are measurable
- [x] Success criteria are technology-agnostic (no implementation details)
- [x] All acceptance scenarios are defined
- [x] Edge cases are identified
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

## Feature Readiness

- [x] All functional requirements have clear acceptance criteria
- [x] User scenarios cover primary flows
- [x] Feature meets measurable outcomes defined in Success Criteria
- [x] No implementation details leak into specification

## Validación específica del Diccionario de Datos

- [x] El inventario final contiene 15 entidades lógicas (Enmienda 3); `cliente` incluye nombre, contacto y estado Activo/Inactivo sin código empresarial ni NIT
- [x] `tipo_material`, `material` y `gramaje` conservan sus responsabilidades separadas
- [x] `ot_detalle` conserva 0..3 pisos, montaje, dimensiones X/Y en centímetros y muestrario obligatorio
- [x] `sector` documenta códigos, orden, participación en flujo, estado y catálogo inicial
- [x] ALMACÉN existe con `participa_flujo = false` y no es destino productivo
- [x] `responsable_sector` permanece separado de `perfil_usuario` y no tiene cuenta de acceso
- [x] `perfil_usuario.sector_id` aplica obligatoriamente a USUARIO y opcionalmente a ADMINISTRADOR
- [x] `movimiento_ot` permite inicio variable, saltos, devoluciones y ciclos sin sobrescribir historia
- [x] Sector actual, responsable actual y tiempos son derivados sin fuentes duplicadas
- [x] Estado de OT y sector actual están modelados como conceptos diferentes
- [x] `movimiento_ot` es el historial funcional y las entidades editables documentan trazabilidad mínima (Enmienda 3)
- [x] Las nuevas cardinalidades aparecen en el mapa de relaciones
- [x] Las decisiones del flujo pendientes están clasificadas para Spec 003
- [x] No quedan decisiones estructurales bloqueantes
- [ ] El estado es `APROBADA` por decisión humana (Enmienda 3 del 2026-10-08 pendiente de aprobación)
- [x] El documento no contiene SQL, migraciones, Plan, Tasks ni implementación

## Notes

- **32 de 32 controles aprobados** después de reevaluar el contenido real de la especificación; la
  aclaración de migración y las enmiendas de `cliente` y metadatos técnicos de OT también fueron
  verificadas.
- Tras la Enmienda 3 (2026-10-08) el modelo contiene 15 entidades: `cliente`, `orden_trabajo`,
  `ot_detalle`, `tipo_material`, `material`, `gramaje`, `maquina`, `parametro`, `ot_acabado`, `rol`,
  `perfil_usuario`, `token_usuario`, `sector`, `responsable_sector` y `movimiento_ot`. Se retiraron
  `auditoria_evento` y `auditoria_cambio`; una OT ya no se elimina físicamente (se anula).
- Revalidación 2026-10-08: 31 de 32 controles aprobados; queda pendiente la aprobación humana de la
  Enmienda 3.
- Enmienda posterior a aprobación del 2026-10-06: `cliente` conserva `id`, `nombre`, `telefono`,
  `correo` y `estado boolean` con Activo como valor conceptual predeterminado; no contiene `nit` ni
  un código empresarial adicional.
- Los clientes Inactivos no se ofrecen para nuevas OT, permanecen visibles en OT históricas y no se
  eliminan físicamente cuando tienen historial. La cardinalidad cliente 1:N orden_trabajo no cambia.
- Enmienda posterior a aprobación del 2026-10-06: `orden_trabajo.idempotencia_creacion` identifica
  de forma durable y única una operación de creación para impedir OT duplicadas, y
  `orden_trabajo.anulado_en` registra el momento confiable de anulación y cierra la última
  permanencia productiva. No se agregan entidades ni cambian cardinalidades.
- `terminado_en` ya estaba formalizado y continúa cerrando la última permanencia de una OT
  `TERMINADO`; `duracion_sector` sigue siendo un valor derivado y no se persiste.
- Se corrigieron decisiones desactualizadas: `tipo_material` vuelve a formar parte del modelo;
  `cantidad` es integer; una OT admite 0..3 pisos; `gramaje` pertenece a `material` y no existe
  `gramaje_id` en `ot_detalle`; el muestrario es obligatorio por piso; las dimensiones usan
  centímetros; el nombre de máquina es único; y cuatro acabados requieren posición.
- El recorrido no es rígido: admite sector inicial variable, saltos, devoluciones y repetición de
  ciclos mediante filas históricas de `movimiento_ot`.
- `sector_actual`, `responsable_actual` y `duracion_sector` no se almacenan; se derivan del último
  movimiento y de sus marcas de tiempo.
- ALMACÉN se conserva como sector empresarial con `participa_flujo = false` y queda fuera de los
  destinos productivos.
- Las seis decisiones pendientes del flujo están clasificadas como decisiones funcionales para
  Spec 003 y no bloquean Spec 002.
- Resultado de pendientes estructurales: **0 bloquean la aprobación**.
- La base anterior con aproximadamente 19.000 OT se mantiene como referencia de volumen; migrarla
  total o parcialmente es una posibilidad futura a evaluar y no bloquea Spec 002, Spec 003 ni el
  desarrollo del nuevo sistema.
- Estado correcto: `APROBADA` con enmienda controlada; la aprobación humana fue otorgada el
  2026-10-06 y no se reabrió el modelo completo.
- La presente reevaluación solo valida la consistencia documental de la enmienda; no ejecuta
  implementación ni modifica una base de datos.
