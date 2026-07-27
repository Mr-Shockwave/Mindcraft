# Mindcraft

Mindcraft is a three-minute, ACT-inspired emotional externalization experience for a university student facing an immediate stressful moment. A feeling becomes a gentle entity on a 2D island; the user chooses how to meet it and commits one small action that matters.

The emotion is never attacked or scored. Visual transformation represents a change in relationship to the experience, not a cure.

## Why Jac is central

The complete product is written in Jac:

- typed graph nodes represent the island, emotional entities, interactions, and value actions;
- typed edges preserve how each experience was met and what action followed;
- public walkers are the application API and traverse the persistent graph;
- `by llm()` produces a compiler-constrained emotional metaphor;
- Jac client JSX renders the interactive frontend;
- Jac’s runtime serves and deploys the application.

The main workflow would not operate without Jac’s OSP graph, walkers, meaning-typed AI, and client compiler.

## Golden path

1. Enter: `I feel anxious about presenting my project.`
2. The `manifest_emotion` walker validates the input, calls typed AI, and adds an `EmotionalEntity`.
3. Choose one of four non-combat interactions.
4. `apply_interaction` connects an `InteractionEvent` and transforms the visual metaphor.
5. Enter a small next action.
6. `commit_value_action` connects a `ValueAction` and marks the entity integrated.

If OpenAI is unavailable, deterministic mapping keeps the complete demo operational.

## Run

Install the current Jac binary, then:

```powershell
jac install
jac install byllm
# Prefer exporting the key into the shell so byllm can reach OpenAI
# (Jac may not always auto-load .env depending on how you start it)
$env:OPENAI_API_KEY = (Get-Content .env | Where-Object { $_ -match '^OPENAI_API_KEY=' }) -replace '^OPENAI_API_KEY=',''
jac start --dev
```

After Send, the toast shows `theme · AI reading` when the model is used, or `theme · local metaphor map` when the deterministic fallback ran.

## Verify

```powershell
jac check main.jac
jac test -d tests -v
```

Manual checks:

- empty input is rejected;
- crisis language displays urgent human-support guidance and is not persisted;
- every AI-selected asset belongs to the allowlist;
- the flow still completes without the OpenAI key;
- the deployed JacHammer sandbox link works in a private browser window (see `docs/JACHAMMER_DEPLOY.md`).

## Project layout (two-person merge safety)

- `main.jac` — Person B: graph, walkers, `by llm()`, validation + thin `cl` import
- `components/App.cl.jac` — Person A: live dream UI (may be redesigned substantially)
- `styles.css` / `assets/**` — Person A
- `tests/**` — Person B
- `docs/JACHAMMER_DEPLOY.md` — Person B publishes the public sandbox link
- `docs/MERGE_RULES.md` — parallel frontend without merge hell
- `docs/JAC_EVIDENCE.md` — where Jac runs (IDE walkthrough for judges)
- `docs/DEMO_SCRIPT.md` — four-minute live demo

## Important documents

- `context.md`: original product context.
- `docs/PSYCHOLOGICAL_FOUNDATION.md`: psychological logic, safety limits, and language rules.
- `docs/TWO_PERSON_WORKFLOW.md`: collaboration and demo runbook.
- `docs/MERGE_RULES.md`: parallel frontend without merge hell.
- `docs/JACHAMMER_DEPLOY.md`: Person B checklist to publish the sandbox link.
- `docs/JAC_EVIDENCE.md`: where Jac runs (show judges in the IDE).
- `docs/DEMO_SCRIPT.md`: four-minute live demo.
- `person_a_codex_brief.md` / `docs/PERSON_A_CODEX_BRIEF.md`: Codex brief for Person A.
- `assets/assets_library.json`: strict visual and interaction allowlist.

## Scope

This hackathon MVP is anonymous and non-clinical. It does not diagnose, provide therapy, or replace professional or crisis care. Any real-world pilot requires professional mental-health, privacy, and safeguarding review.
