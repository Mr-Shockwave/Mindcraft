# Two-Person Build and Demo Workflow

## Goal

Ship one reliable three-minute workflow before the 5:50 PM partial submission:

1. a student describes presentation anxiety;
2. Jac `by llm()` returns a typed, constrained metaphor;
3. a Jac walker creates and connects the entity in the graph;
4. the student chooses an interaction;
5. another walker records the interaction and transforms the entity;
6. the student commits one small values-guided action;
7. the demo visibly shows where Jac performs each step.

Anything outside this path is optional.

## Roles

### Person A — Product, visual frontend, and demo lead

Person A owns:

- visual direction and responsive layout;
- `styles.css`;
- approved icons and assets under `assets/`;
- UX copy that follows the psychological language guide;
- browser testing on desktop and mobile widths;
- Devpost description, screenshots, and demo video;
- the four-minute live-demo script;
- keeping the task board and calling scope cuts;
- JacHammer deployment and public-link verification.

Lovable may be used to explore layout, color, CSS, and interaction ideas. Do not allow it to create a second backend or make React/TypeScript the main product. Port useful visual output into Jac client JSX and `styles.css`. Keeping production logic and UI in Jac strengthens the 40% requirement and the 40-point Jac criterion.

Person A should avoid changing server nodes, walkers, AI contracts, or graph operations without coordinating with Person B.

### Person B — Jac architecture, logic, safety, and test lead

Person B owns:

- `main.jac` server-side nodes, edges, walkers, and helper functions;
- typed `by llm()` behavior and OpenAI configuration;
- strict asset and tool validation;
- deterministic fallback behavior;
- crisis-language interception;
- Jac compiler, formatter, and test results;
- graph traversal evidence for the judges;
- integration fixes and final technical sign-off.

Person B should avoid unplanned visual redesigns. UI changes needed for API integration should be communicated as a small interface contract.

## File ownership

To minimize conflicts:

- Person A has primary write ownership of `styles.css`, `assets/**`, `docs/DEMO_SCRIPT.md`, screenshots, and Devpost text.
- Person B has primary write ownership of `jac.toml`, the server portion of `main.jac`, tests, and safety logic.
- The client `cl { ... }` section of `main.jac` is a shared boundary. Person A proposes UI changes there; Person B reviews that walker calls and response shapes remain valid.
- `docs/PSYCHOLOGICAL_FOUNDATION.md` is changed only by agreement because it defines product constraints.

After the first stable run, split the client block into a `.cl.jac` module only if the installed Jac version compiles that refactor immediately. Do not risk a working demo merely to improve organization.

## Git setup on two devices

One person should create the initial baseline commit after Jac runs. Then both devices:

```powershell
git pull
git switch -c person-a-ui-demo
```

Person B uses:

```powershell
git pull
git switch -c person-b-jac-core
```

Use short commits that contain one coherent change:

```text
style: refine island layout
docs: add four-minute demo script
feat: validate emotion asset pairs
test: cover fallback and crisis guard
fix: preserve demo flow when LLM fails
```

Do not use a shared branch simultaneously from two devices. Do not force-push. Do not commit `.env`, API keys, `.jac/`, generated client bundles, recordings, or large raw design exports.

## Integration rhythm

Use a 25–30 minute cycle:

1. Pull the latest integration branch.
2. Work only in the files owned by your role.
3. Test the smallest relevant behavior.
4. Commit and push.
5. Tell the other person the commit hash and any changed interface.
6. Integrate one branch at a time.
7. Run the complete golden path after every merge.

Person B should act as technical integrator because they own compiler and test verification. Person A decides whether a build is visually and narratively demo-ready.

## Interface contract between frontend and backend

Person A can rely on four walkers:

- `get_world()` returns `entities` and `tools`;
- `manifest_emotion(feeling_text)` returns the entity, suggested tools, and world;
- `apply_interaction(entity_id, tool_id)` returns the transformed entity and world;
- `commit_value_action(entity_id, action_text)` returns the updated world.

Every mutation returns:

- `ok: bool`;
- `error: str` when unsuccessful;
- `world: list` when successful.

Person B must announce changes to these keys before merging. Person A should not bind the UI to internal node fields that are absent from `entity_view()`.

## Device-specific setup

On both devices:

1. Install the current Jac binary and the Jac Language Support extension.
2. Clone the same repository.
3. Run `jac install`.
4. Run `jac install byllm`.
5. Copy `.env.example` to `.env`.
6. Add a separate OpenAI key or securely share one outside Git.
7. Confirm `jac --version` matches on both devices.

Start development with:

```powershell
jac start --dev
```

Run verification with:

```powershell
jac check main.jac
jac test main.jac -v
```

If the Windows native installer is unavailable, use JacHammer for build and deployment or use the official Jac Docker image. Do not spend the final build hour debugging unrelated machine setup.

## JacHammer workflow

Person B:

1. confirms the repository root has `main.jac` and `jac.toml`;
2. verifies dependencies and the OpenAI model configuration;
3. imports or opens the existing project in JacHammer;
4. runs the core workflow and inspects logs.

Person A:

1. signs into JacHammer so the project can sync and be shared;
2. deploys to the free sandbox;
3. opens the public link in a private browser window;
4. checks the presentation screen resolution;
5. records the URL in the Devpost draft and demo notes.

Deploy early. A successful deployment at 4:30 PM is more valuable than an extra optional feature.

## Recommended event schedule

### 2:10–3:00 — Establish the golden path

Person B:

- install or open Jac in JacHammer;
- run compiler and tests;
- fix syntax or runtime incompatibilities;
- verify deterministic fallback without an API key;
- verify OpenAI mode with the key.

Person A:

- review the visual hierarchy and responsive layout;
- replace only essential placeholder symbols;
- prepare the one-sentence problem statement;
- start the Devpost draft.

Exit condition: one browser completes the full workflow.

### 3:00–4:00 — Parallel polish

Person B:

- make graph traversal visible and stable;
- test invalid asset, empty input, and crisis paths;
- prepare a code view showing nodes, edges, walkers, and `by llm()`.

Person A:

- tune CSS and interaction copy;
- test the student-presentation script;
- capture screenshots;
- keep the main interaction above the fold.

Exit condition: both people can independently run the golden path.

### 4:00–4:45 — Integrate and deploy

- Merge UI changes, then core changes.
- Run check, tests, and the golden path.
- Deploy through JacHammer.
- Test the public link on the second device.
- Freeze endpoint names and response shapes.

Exit condition: public deployment works from a clean browser.

### 4:45–5:35 — Submission and recording

Person A:

- finish Devpost text;
- record a concise demo video;
- prepare slides only if they strengthen the story.

Person B:

- provide the exact Jac technical description;
- calculate Jac file proportion;
- label the code sections to show judges;
- fix only blockers or clear defects.

### 5:35–5:50 — Partial submission

- Submit the GitHub link, current deployment, description, and video draft.
- Confirm the project explicitly describes how Jac is central.

### 5:50–6:40 — Reliability and story

- Run the demo at least five times.
- Test with the model available and unavailable.
- Keep a known-good input copied in the demo notes.
- Practice role handoff between Person A and Person B.

### 6:40–7:05 — Final freeze

- No new features.
- Make only submission-blocking fixes.
- Tag or record the known-good commit.
- Confirm links, permissions, audio, browser zoom, and API quota.

### 7:05–7:15 — Final submission

- Submit before the hard deadline.
- Verify the saved Devpost page rather than assuming autosave completed.

## Four-minute live-demo division

Person A, approximately 0:00–0:45:

- name one user: a student three minutes before a presentation;
- explain what fails today: no time for a therapy session and generic advice adds cognitive load;
- enter the prepared feeling statement.

Person A, approximately 0:45–2:15:

- show the entity appearing;
- choose a tool;
- show the visual transformation;
- commit the one-sentence next action;
- emphasize that the emotion was not destroyed.

Person B, approximately 2:15–3:20:

- show the Jac node and edge model;
- point to `manifest_emotion`, `apply_interaction`, and `commit_value_action`;
- show typed `by llm()` and allowed asset validation;
- explain deterministic fallback and crisis interception;
- briefly show the graph or walker traversal running.

Person A, approximately 3:20–4:00:

- return to the transformed island;
- state the social impact and non-clinical boundary;
- close with: “Mind Island helps a student take the next valued step without first having to defeat how they feel.”

## Scope-cut order

Cut features in this order if time becomes tight:

1. accounts and long-term history;
2. animation;
3. custom uploaded assets;
4. multiple worlds or personas;
5. counselor dashboard;
6. analytics;
7. extra emotional categories.

Never cut:

- a working end-to-end flow;
- Jac walkers and graph traversal;
- typed AI output plus deterministic fallback;
- asset validation;
- safety boundary;
- public deployment;
- a rehearsed four-minute story.

## Definition of done

- The public app completes the golden path.
- Jac performs the core logic rather than wrapping another backend.
- The demo works when the LLM fails.
- No API key or sensitive journal text appears in Git or logs.
- `jac check` and `jac test` pass on the known-good environment.
- The repository clearly exceeds 40% Jac.
- The partial and final submissions are saved before their deadlines.
- Both people can run the demo if the other device fails.
