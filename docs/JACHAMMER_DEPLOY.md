# JacHammer Deploy (Person B)

JacHammer is browser-based. There is no reliable unattended CLI deploy from this machine without your JacHammer login. Use this checklist.

## Preconditions (repo is ready)

- [x] `main.jac` + `jac.toml` at repository root
- [x] Full-stack Jac (`kind = "web-app"`)
- [x] Public GitHub: `https://github.com/Mr-Shockwave/Mindcraft`
- [ ] Sign in at [https://jachammer.ai](https://jachammer.ai)
- [ ] Set OpenAI key in JacHammer project secrets / env (never commit `.env`)

## Deploy existing project (recommended)

1. Open [https://jachammer.ai](https://jachammer.ai) → **Sign in**.
2. Choose **Deploy existing** / import from GitHub.
3. Select `Mr-Shockwave/Mindcraft` (prefer branch with latest dream UI + walkers: `main` or merged `person-b-jac-core`).
4. Confirm entry point `main.jac` and that sandbox hosting is enabled.
5. Add env: `OPENAI_API_KEY=...` (same key as local `.env`).
6. Deploy / run.
7. Open the share link in a **private window**.
8. Run golden path once:
   - check-in → tray (3) → drag → tool → interact → plant intention → reset.
9. Paste the public URL into Devpost and `docs/DEMO_SCRIPT.md`.

## If import fails

- Push latest branch to `origin/main`.
- Ensure `.jac/` and `.env` are not required in the repo (they are gitignored).
- Keep client under `components/App.cl.jac` with thin import in `main.jac` so JacHammer sees a clean root entry.

## Local fallback for judges

```powershell
bash -lc "jac start --dev"
```

App: `http://localhost:8000/`  
API: `http://localhost:8001/`

## After deploy

Record here (Person B fills in):

- Public URL: ________________________________
- Branch deployed: ____________________________
- Verified golden path (yes/no): ______________
- LLM live or fallback used: __________________
