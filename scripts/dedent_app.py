from pathlib import Path

p = Path("components/App.cl.jac")
text = p.read_text(encoding="utf-8")
marker = 'import "./styles.css";\n'
i = text.index(marker) + len(marker)
header = text[:i]
body = text[i:]
lines = body.splitlines(True)
indents = [len(line) - len(line.lstrip(" ")) for line in lines if line.strip()]
min_i = min(indents) if indents else 0
if min_i:
    body = "".join(
        line[min_i:] if line.startswith(" " * min_i) else line for line in lines
    )
p.write_text(header + "\n" + body.lstrip("\n"), encoding="utf-8")
print(f"dedented {min_i}")
