with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

old = """		anim_frame = (anim_frame + 1) % 8
		sprite.frame = anim_frame"""

new = """		anim_frame = (anim_frame + 1) % 8
		if sprite: sprite.frame = anim_frame"""

content = content.replace(old, new)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
