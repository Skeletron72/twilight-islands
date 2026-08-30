import re

def fix_shapes(filepath, col_w, col_h, size_x, size_y):
    with open(filepath, 'r') as f:
        content = f.read()

    sub_res = f"""
[sub_resource type="RectangleShape2D" id="RectangleShape2D_static"]
size = Vector2({col_w}, {col_h})

[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]
size = Vector2({size_x}, {size_y * 0.5})
"""
    if 'RectangleShape2D_static' not in content:
        # Insert before the first [node
        idx = content.find('[node')
        if idx != -1:
            content = content[:idx] + sub_res + '\n' + content[idx:]

    with open(filepath, 'w') as f:
        f.write(content)

fix_shapes('scenes/objects/tree.tscn', 16, 10, 32, 34)
fix_shapes('scenes/objects/stone.tscn', 24, 14, 32, 32)
fix_shapes('scenes/levels/twilight_ore.tscn', 24, 14, 32, 32)
