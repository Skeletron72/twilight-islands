import re

with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

old = """	var tex = load(tex_path)
	if tex:"""

new = """	var tex = load(tex_path)
	print("STONE LOAD:", tex_path, " RESULT:", tex)
	if tex:"""

content = content.replace(old, new)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
