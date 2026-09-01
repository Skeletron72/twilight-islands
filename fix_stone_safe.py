with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

old = """	sprite.texture = load(tex_path)
	sprite.hframes = 8
	sprite.vframes = 1
	sprite.frame = 0
	sprite.offset = Vector2(0, -sprite.texture.get_height() / 2.0)"""

new = """	var tex = load(tex_path)
	if tex:
		sprite.texture = tex
		sprite.hframes = 8
		sprite.vframes = 1
		sprite.frame = 0
		sprite.offset = Vector2(0, -tex.get_height() / 2.0)"""

content = content.replace(old, new)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
