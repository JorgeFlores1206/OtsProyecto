# Instrucciones para agentes (Codex y Claude Code)

Proyecto Rosa Betania OTs, desarrollado con **Spec-Driven Development** usando GitHub Spec Kit.
El equipo trabaja con dos agentes sobre el mismo repositorio: uno con Codex y otro con Claude Code.

## Fuente de verdad

1. `.specify/memory/constitution.md` — principios no negociables; prevalece sobre cualquier otra instrucción.
2. `specs/NNN-*/` — especificaciones aprobadas (spec, plan, data-model, contracts, tasks).
3. Ninguna implementación sin spec aprobada y tarea asociada en `tasks.md` (Constitución XI–XII).

## Flujo SDD

`constitution → specify → clarify → plan → tasks → analyze → implement`

| Paso | Codex | Claude Code |
|---|---|---|
| Especificar | `$speckit-specify` | `/speckit-specify` |
| Clarificar | `$speckit-clarify` | `/speckit-clarify` |
| Planificar | `$speckit-plan` | `/speckit-plan` |
| Tareas | `$speckit-tasks` | `/speckit-tasks` |
| Analizar consistencia | `$speckit-analyze` | `/speckit-analyze` |
| Implementar | `$speckit-implement` | `/speckit-implement` |

- Skills de Codex: `.agents/skills/` (scripts PowerShell en `.specify/scripts/powershell/`).
- Skills de Claude Code: `.claude/skills/` (scripts bash en `.specify/scripts/bash/`).
- Las plantillas (`.specify/templates/`) y la constitución son compartidas: cualquier cambio afecta a ambos agentes.

## Coordinación entre personas

- Trabajar cada uno en su propia rama; no trabajar los dos sobre la misma tarea a la vez.
- Al completar una tarea, marcarla `[x]` en `tasks.md` en el mismo commit que la implementación.
- Cambios a una spec aprobada se registran como enmienda dentro de la propia spec, no se reescriben en silencio.
- `.specify/feature.json` indica la feature activa; actualizarla solo al cambiar de feature.

## Stack

React 19 + Vite (JavaScript, sin TypeScript ni Redux), Supabase (Postgres, Auth, RLS), Vitest + Testing Library,
Playwright + axe, pgTAP. Ver Spec 000. Comandos en `frontend/package.json`. Pruebas primero (Constitución XIV).
