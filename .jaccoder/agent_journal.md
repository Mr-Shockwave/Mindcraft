## Issues
- [turn 3] JSX comments `{/* ... */}` cause parse errors — Jac's JSX parser treats `/*` as division. Removed all JSX comments.
- [turn 3] Em dash `—` in JSX string caused "Unexpected character" error. Use plain `-` instead.
- [turn 3] `THEME_ASSETS.get()` returns `any` — must cast to `list[str]` before iterating.
- [turn 3] `document.getElementById()` returns `object` type — cast `document as any` first, then all chained calls return `any`.
- [turn 3] `any / any` division fails type check — cast numerator and denominator to `float` explicitly.
- [turn 3] `entity["x"] * 100` fails — dict values are `any`, must cast: `(entity["x"] as float) * 100.0`.
- [turn 3] `dragging_id = entity["id"]` fails — dict value is `any`, must cast: `entity["id"] as str`.
- [turn 3] Tray hidden below viewport — `flex: 1` on canvas consumed all space. Fixed with `height: 300px` fixed height.

## Learnings
- No JSX comments `{/* */}` in Jac — parser treats `/*` as division operator.
- `document as any` is the correct pattern for browser globals; all chained attribute accesses then return `any`.
- Dict value access `d["key"]` returns `any` — always cast before arithmetic or string assignment.
- `flex: 1` on a canvas inside a flex column will consume all space and hide siblings below. Use fixed height.
- `align-items: start` on the workspace grid prevents columns from stretching to equal height.

## Last Action
Turn 3: Completed SVG island canvas + entity tray + drag-and-drop placement.
- Backend: EmotionalEntity has placed/x/y; THEME_ASSETS maps theme to 3 assets; manifest_emotion creates 3 variants; place_entity walker sets position.
- Frontend: SVG island (sky/clouds/sun/water/island), 300px canvas drop target, entity tray below with 3 draggable cards, placed entities at absolute x/y positions.
- All rendering correctly in preview. Drag-to-place flow is live.
