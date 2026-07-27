from pathlib import Path

root = Path(__file__).resolve().parents[1]
src_path = root / "main.jac"
src = src_path.read_text(encoding="utf-8")
start = src.index("cl {")
inner_start = start + len("cl {\n")
end = src.rfind("\n}")
inner = src[inner_start:end]

components = root / "components"
components.mkdir(exist_ok=True)

header = '''"""Mind Island client UI — Person A owns this file.

Do not change walker names, arguments, or response keys.
Edit visuals, layout, copy, and IslandSvg freely.
"""

sv import from ..main {
    get_world,
    manifest_emotion,
    place_entity,
    apply_interaction,
    commit_value_action,
    reset_demo
}

'''

(components / "App.cl.jac").write_text(header + inner.strip() + "\n", encoding="utf-8")

server = (
    src[:start].rstrip()
    + "\n\n# Client entry lives in components/App.cl.jac (Person A).\n"
    + 'cl {\n    import from "./components/App.cl.jac" { app }\n}\n'
)
src_path.write_text(server, encoding="utf-8")
print("split ok")
