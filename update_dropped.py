import re

with open('scripts/components/dropped_item.gd', 'r') as f:
    content = f.read()

# Fix random offset to only fly downwards/sideways (never behind the tree)
content = re.sub(r'var random_offset = Vector2\(randf_range\(-20, 20\), randf_range\(-10, 20\)\)',
                 r'var random_offset = Vector2(randf_range(-24, 24), randf_range(8, 24))', content)

# Fix shadow to be pixelated
old_draw = r'func _draw\(\) -> void:\n\tdraw_set_transform\(Vector2\(0, 8\), 0, Vector2\(1\.0, 0\.3\)\)\n\tdraw_circle\(Vector2\.ZERO, 8\.0, Color\(0, 0, 0, 0\.4\)\)'
new_draw = """func _draw() -> void:
	# Pixel perfect shadow (8x4 oval)
	var c = Color(0, 0, 0, 0.35)
	draw_rect(Rect2(-4, 7, 8, 2), c)
	draw_rect(Rect2(-2, 6, 4, 1), c)
	draw_rect(Rect2(-2, 9, 4, 1), c)"""
content = re.sub(old_draw, new_draw, content)

with open('scripts/components/dropped_item.gd', 'w') as f:
    f.write(content)

