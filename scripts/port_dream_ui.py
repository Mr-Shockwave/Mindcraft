"""Extract dream UI from main.jac into components/App.cl.jac and thin the entry."""
from pathlib import Path
import re

root = Path(__file__).resolve().parents[1]
main_path = root / "main.jac"
src = main_path.read_text(encoding="utf-8")

# Find the client block start (last occurrence of "cl {" that contains app)
matches = list(re.finditer(r"(?m)^cl \{", src))
if not matches:
    raise SystemExit("no cl { block found")
cl_match = matches[-1]
cl_start = cl_match.start()

# Server is everything before this cl block (strip trailing client comments)
server = src[:cl_start].rstrip()
# Drop duplicated client-entry comments at end of server
while True:
    lines = server.splitlines()
    if lines and ("Client entry" in lines[-1] or lines[-1].strip() == ""):
        if "Client entry" in lines[-1]:
            server = "\n".join(lines[:-1]).rstrip()
            continue
        if lines[-1].strip() == "":
            server = "\n".join(lines[:-1]).rstrip()
            continue
    break

cl_body = src[cl_match.end() :]
# Strip trailing closing brace of cl block
cl_body = cl_body.rstrip()
if cl_body.endswith("}"):
    cl_body = cl_body[:-1].rstrip()

# Prefer extracting from def:pub app through end
app_match = re.search(r"def:pub\s+app\s*\(", cl_body)
if not app_match:
    raise SystemExit("def:pub app not found inside cl block")
app_src = cl_body[app_match.start() :].rstrip()

# Label fix
app_src = app_src.replace(
    '<span className="tray-name">{entity["theme"]}</span>',
    '<span className="tray-name">{entity["label"]}</span>',
)

tool_block = """
                    <div className="tool-row" aria-label="Choose how to meet this feeling">
                        <button
                            className={"tool-chip" + (" selected" if selected_tool == "breathe" else "")}
                            onClick={lambda -> None { selected_tool = "breathe"; }}
                            type="button"
                        >🫧 Breathe</button>
                        <button
                            className={"tool-chip" + (" selected" if selected_tool == "sunlight" else "")}
                            onClick={lambda -> None { selected_tool = "sunlight"; }}
                            type="button"
                        >☀️ Warmth</button>
                        <button
                            className={"tool-chip" + (" selected" if selected_tool == "water" else "")}
                            onClick={lambda -> None { selected_tool = "water"; }}
                            type="button"
                        >💧 Make room</button>
                        <button
                            className={"tool-chip" + (" selected" if selected_tool == "name_it" else "")}
                            onClick={lambda -> None { selected_tool = "name_it"; }}
                            type="button"
                        >🏷️ Name it</button>
                    </div>
"""

if "tool-row" not in app_src and '<div className="chat-actions">' in app_src:
    app_src = app_src.replace(
        '<div className="chat-actions">',
        tool_block + "\n                    <div className=\"chat-actions\">",
    )

# Dedent if the extracted app was nested under cl with 4 spaces
lines = app_src.splitlines()
indents = [len(l) - len(l.lstrip(" ")) for l in lines if l.strip()]
min_i = min(indents) if indents else 0
if min_i >= 4:
    app_src = "\n".join(l[4:] if l.startswith("    ") else l for l in lines)

header = '''"""Mind Island client UI — Person A owns this file.

Person A may redesign freely here and in styles.css / assets.
Do not change walker names, arguments, or response keys.
"""

sv import from ..main {
    get_world,
    manifest_emotion,
    place_entity,
    apply_interaction,
    commit_value_action,
    reset_demo
}

import "./styles.css";

'''

(components := root / "components").mkdir(exist_ok=True)
(components / "App.cl.jac").write_text(header + app_src.strip() + "\n", encoding="utf-8")

bridge = (
    server
    + "\n\n# Client entry lives in components/App.cl.jac (Person A owns UI).\n"
    + 'cl {\n    import from "./components/App.cl.jac" { app }\n}\n'
)
main_path.write_text(bridge, encoding="utf-8")
print("OK: ported dream UI + tool-row to components/App.cl.jac")
print(f"main.jac lines={len(bridge.splitlines())} app lines={len(app_src.splitlines())}")
