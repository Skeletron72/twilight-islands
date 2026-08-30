import re

with open('scripts/components/destructible.gd', 'r') as f:
    content = f.read()

old_interact = r'(\t# Visual feedback\n\tvar tween = create_tween\(\)\n\tvar sprite = get_node_or_null\("Sprite2D"\)\n\tif sprite:\n\t\tvar orig = sprite\.modulate\n\t\tsprite\.modulate = Color\.RED\n\t\ttween\.tween_property\(sprite, "modulate", orig, 0\.1\))'

new_interact = """	# Visual feedback
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Flash
		var orig_mod = sprite.modulate
		sprite.modulate = Color(1.5, 0.5, 0.5) # Soft red flash
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", orig_mod, 0.15)
		
		# Shake
		var orig_pos = sprite.position
		var shake_tween = create_tween()
		shake_tween.tween_property(sprite, "position:x", orig_pos.x + 3.0, 0.03)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x - 3.0, 0.04)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x + 2.0, 0.04)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x, 0.03)"""

content = re.sub(old_interact, new_interact, content)

with open('scripts/components/destructible.gd', 'w') as f:
    f.write(content)

