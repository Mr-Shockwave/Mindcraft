# Mind Island Agent Guide

- Keep core logic, state, AI orchestration, graph operations, APIs, and production UI in Jac.
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
- Before handoff, run `jac check main.jac`, `jac test main.jac -v`, and the complete browser workflow.
- Treat `docs/PSYCHOLOGICAL_FOUNDATION.md` as a product constraint.
- Treat `docs/TWO_PERSON_WORKFLOW.md` as the collaboration and demo runbook.
