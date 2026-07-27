# Merge Rules — Parallel Frontend Without Unmergable Conflicts

## Goal

Person A can make **substantial** frontend changes. Person B can harden Jac core at the same time. Conflicts stay rare because ownership is **by file**, not by “don’t touch the UI.”

This is possible. You do **not** need to serialize to one builder — as long as both follow this split.

## File ownership (hard)

| Owner | Files | May do |
|---|---|---|
| **Person A** | `components/**`, `styles.css`, `assets/**` (keep IDs), screenshots, Devpost, JacHammer QA | Rewrite layout, IslandSvg, copy, motion, art |
| **Person B** | `main.jac` (server + thin `cl` import only), `tests/**`, `jac.toml`, `docs/JAC_EVIDENCE.md`, safety/AI helpers | Walkers, graph, `by llm()`, validation, tests |
| **Shared by agreement** | `docs/PSYCHOLOGICAL_FOUNDATION.md`, `person_a_codex_brief.md`, `docs/TWO_PERSON_WORKFLOW.md` | Product constraints |

## Critical architecture fact

```text
main.jac          → Person B  (nodes, walkers, by llm, thin cl import)
components/App.cl.jac → Person A  (all visible UI + walker spawn wiring)
styles.css        → Person A
```

Person A may rewrite `components/App.cl.jac` heavily.  
Person B must **not** restyle or restructure that file unless A asks for an API fix.

Person B may change walkers in `main.jac` freely.  
Person A must **not** edit walker bodies, nodes, edges, or tests.

## Locked contract (A must preserve)

Walker names and args:

- `get_world()`
- `manifest_emotion(feeling_text)`
- `place_entity(entity_id, x, y)`
- `apply_interaction(entity_id, tool_id)`
- `commit_value_action(entity_id, action_text)`
- `reset_demo()`

Golden path buttons / actions must remain available:

- Manifest check-in
- Drag/place from 3-choice tray
- Tool interaction
- Plant intention
- Reset demo

Unused tray entities **stay** in the world after one is placed (do not delete siblings).

Asset IDs and tool IDs are locked (see `person_a_codex_brief.md`).

## Integration order (ASAP)

1. Person B merges/pushes `person-b-jac-core` (this split + docs) to `main` or shared remote.
2. Person A rebases `person-a-demo` onto that tip **before** continuing Codex work.
3. Person A works only in `components/`, `styles.css`, `assets/`.
4. Person B works only in `main.jac` / `tests/` / evidence docs.
5. Merge A first for visuals, then B for any new API — or B first if A has not published; then A rebases.
6. After every merge: `jac check main.jac`, `jac test -d tests -v`, browser golden path.

## What creates unmergable hell (forbidden)

- Both editing `main.jac` client UI
- Person A’s Codex regenerating all of `main.jac`
- Person B “quickly fixing” CSS in `styles.css` while A is mid-rewrite
- Renaming walkers without announcing
- Creating a separate React/Lovable production app

## If conflicts still explode

Escalate once: freeze to one person on app code for 60 minutes. Prefer that over a broken demo. The file split exists so this should be rare.

## Codex one-liner for Person A

```text
Only edit components/**, styles.css, and assets/**.
Never edit main.jac walkers/nodes or tests/.
Preserve walker spawn names and the 3-tray → place → interact → commit flow.
```
