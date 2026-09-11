import sys

file_path = "scenes/levels/dungeon.tscn"
with open(file_path, "r") as f:
    content = f.read()

bg_node = """[node name="VoidBackground" type="ColorRect" parent="."]
z_index = -10
offset_left = -2000.0
offset_top = -2000.0
offset_right = 2000.0
offset_bottom = 2000.0
color = Color(0.223529, 0.121569, 0.129412, 1)

"""

# Insert before FloorLayer
content = content.replace('[node name="FloorLayer"', bg_node + '[node name="FloorLayer"')

with open(file_path, "w") as f:
    f.write(content)
