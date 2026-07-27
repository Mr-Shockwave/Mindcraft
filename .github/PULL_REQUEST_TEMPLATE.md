## Role

- [ ] Person A: visual/frontend/demo-only change
- [ ] Person B: Jac core/safety/test change

## Conflict Guard

- [ ] I branched from the latest `main`.
- [ ] I did not edit files owned by the other person without coordination.
- [ ] If this is a Person A PR, `git diff origin/main -- main.jac styles.css tests jac.toml` is empty or this PR documents the Person B-approved exception.
- [ ] I did not change walker names, response keys, asset IDs, tool IDs, ACT stages, safety guards, fallback behavior, or tests unless this is a Person B PR.
- [ ] I ran the smallest relevant check and recorded it below.

## Verification

Commands/manual flow run:

```text

```
