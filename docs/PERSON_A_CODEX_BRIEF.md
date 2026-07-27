# Person A · Codex Visual Brief (Mindcraft)

**Audience:** Person A + Codex / Lovable / visual tools  
**Goal:** Make the product look demo-ready without touching Jac core logic.  
**Branch:** `person-a-demo` (rebase onto latest shared tip that includes the UI split)  
**Also read:** `docs/MERGE_RULES.md`

---

## Your job

You own **substantial frontend work**:

- Rewrite layout, visuals, IslandSvg, tray/item chrome, typography, motion in `components/**`
- `styles.css`
- Asset art under `assets/**` (IDs locked)
- Soft UX copy (ACT-safe)
- Screenshots, demo video, Devpost, JacHammer visual QA

You do **not** edit:

- `main.jac` walkers / nodes / edges / `by llm()` / validation
- `tests/**`
- `jac.toml` AI config
- Walker names, args, or response keys

---

## Why merges work now

UI lives in `components/App.cl.jac`. Core logic lives in `main.jac`.  
You can make large frontend changes without colliding with Person B — **if you never rewrite `main.jac`**.

---

## Golden path (preserve)

1. Check-in → manifest  
2. **Three** tray forms (`pending`, `placed: false`)  
3. Drag one onto island (`place_entity`) — **leave other tray entities in the world**  
4. Tool → interact (one click acknowledges + transforms)  
5. Plant intention → `integrated`  
6. Optional Reset demo  

Default input: `I feel anxious about presenting my project.`

---

## Files you may edit

| File | Allowed |
|---|---|
| `components/**` especially `App.cl.jac` | Yes — primary frontend surface |
| `styles.css` | Yes |
| `assets/**` | Yes — keep every asset/tool `id` unchanged |
| Screenshots / Devpost | Yes |

## Files you must not edit

| File | Why |
|---|---|
| `main.jac` (except if Person B asks for a one-line import fix) | Core Jac |
| `tests/**` | Person B |
| Creating a separate React/TS production app | Breaks Jac-central rubric |

---

## Locked walkers

- `get_world()`
- `manifest_emotion(feeling_text)` → includes `pending` (3 choices)
- `place_entity(entity_id, x, y)`
- `apply_interaction(entity_id, tool_id)`
- `commit_value_action(entity_id, action_text)`
- `reset_demo()`

Entity fields you may display:  
`id, label, theme, metaphor, asset_id, symbol, reflection, process_stage, interaction_count, is_transformed, placed, x, y`

---

## Locked IDs

Initial → transformed:  
`dark_cloud→rain_garden`, `tangled_knot→open_ribbon`, `heavy_stone→mossy_stone`, `windy_leaves→gentle_breeze`, `fog_patch→lantern_path`

Tools: `breathe`, `sunlight`, `water`, `name_it`

---

## Codex prompt

```text
You are Person A’s visual agent for Mindcraft (Jac full-stack).

ONLY edit components/**, styles.css, and assets/**.
NEVER edit main.jac walkers/nodes, tests/, or jac.toml AI config.
Preserve: 3-tray pending entities, drag place_entity, apply_interaction,
commit_value_action, reset_demo, and locked asset/tool IDs.
Leave unplaced tray siblings in the world after placing one.
Keep ACT-safe language. No combat. No separate React production app.
```

---

## Before you keep coding locally

1. Pull / rebase onto the branch that contains `components/App.cl.jac`.  
2. Move any Codex edits that landed in `main.jac`’s old `cl {}` into `components/App.cl.jac`.  
3. Confirm golden path once.  
4. Deploy JacHammer ASAP and send Person B the link.
