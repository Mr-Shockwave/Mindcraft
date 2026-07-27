# Where Jac Runs (Judge Evidence)

Use this during the 4-minute demo when judges ask “where is Jac?” Open these files in the IDE — **not** a separate frontend panel.

## One-sentence answer

Mindcraft is a full-stack Jac app: the graph, walkers, typed `by llm()`, validation, REST endpoints, and client JSX all compile from Jac. Without Jac, the golden path does not exist.

## Show these files in order (about 60–75 seconds)

### 1. Graph model — `main.jac` nodes and edges

Point to:

- `node MindIsland`
- `node EmotionalEntity` with `process_stage`, `placed`, `x`, `y`
- `node InteractionEvent`, `node ValueAction`
- `edge Contains`, `edge Chose`, `edge LedTo`

Say: *“The island is a persistent graph, not a React store.”*

### 2. Typed AI — `interpret_emotion` + `EmotionReading`

Point to:

- `obj EmotionReading`
- `def interpret_emotion(...) -> EmotionReading by llm(...)`
- `sem` strings
- `safe_reading` / `reading_is_valid` / `sanitize_tools`

Say: *“The model may only pick allowlisted assets and tools. Invalid output falls back deterministically.”*

### 3. Walkers = the product API

Point to each walker and name the stage:

| Walker | Stage |
|---|---|
| `manifest_emotion` | Externalize → creates 3 pending tray entities |
| `place_entity` | User places one metaphor on the island |
| `apply_interaction` | Acknowledge → transform (no combat) + `Chose` edge |
| `suggest_intentions` | Typed `by llm()` next steps via graph traversal |
| `commit_value_action` | Integrate → `ValueAction` via `LedTo` |
| `get_act_path` | Traverse island → entity → tools → intention |
| `reset_demo` | Clean anonymous session |

Say: *“Judges can hit these as `/walker/...` endpoints; the UI just spawns them.”*

### 4. Client still Jac — `components/App.cl.jac`

Point to `root spawn manifest_emotion(...)` / `place_entity` / etc.

Say: *“Even the browser UI is Jac client JSX compiling to React — not a separate Node backend.”*

### 5. Tests prove the contract — `tests/core_tests.jac`

Mention: crisis does not persist; place required before interact; stages end at `integrated`; 3 pending tray entities.

## What Jac is *not* doing here

- Not generating images
- Not diagnosing
- Not scoring mood or health
- Not requiring accounts

## Rubric talking points

- **Use of Jac (40%):** OSP graph + walkers + `by llm()` + Jac client are central.
- **Social impact:** short, non-clinical support for a student before a presentation.
- **Best JacHammer:** same repo deploys via JacHammer sandbox from `main.jac` + `jac.toml`.
