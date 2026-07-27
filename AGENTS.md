# Mind Island Agent Guide

- Keep core logic, state, AI orchestration, graph operations, and APIs in Jac (`main.jac`).
- Keep production UI in Jac client files under `components/` (Person A), not a separate React app.
- Preserve `main.jac` and `jac.toml` at the repository root for JacHammer.
- Optimize for one reliable student-presentation demo, not feature breadth.
- Use nodes, typed edges, walkers, traversal, and typed `by llm()` as central architecture.
- Validate all model-selected IDs against the predefined asset library.
- Keep a deterministic fallback for every LLM-dependent demo step.
- Never add combat, health/damage meters, emotional leaderboards, or rewards for forced positivity.
- Use ACT-consistent stages: `externalized`, `acknowledged`, and `integrated`.
- Do not diagnose, promise treatment, or store unnecessary emotional free text.
- Intercept crisis language before model calls or persistence and redirect to human support.
- Never commit `.env`, credentials, `.jac/`, generated bundles, or raw user journal content.
- Before handoff, run `jac check main.jac`, `jac test -d tests -v`, and the complete browser workflow.
- Treat `docs/PSYCHOLOGICAL_FOUNDATION.md` as a product constraint.
- Treat `docs/TWO_PERSON_WORKFLOW.md`, `docs/MERGE_RULES.md`, and `person_a_codex_brief.md` as collaboration rules.
- Judge Jac evidence lives in `docs/JAC_EVIDENCE.md` (IDE walkthrough), not a required main-UI panel.
