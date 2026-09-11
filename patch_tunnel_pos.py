import sys

file_path = "scripts/components/dungeon_generator.gd"
with open(file_path, "r") as f:
    content = f.read()

content = content.replace("var support_pos = Vector2i(cx - 2, cy - 8)", "var support_pos = Vector2i(cx, cy - 8)")
content = content.replace("support.global_position = _tile_to_world(support_pos) + Vector2(-8, 8) # Align to grid", "support.global_position = _tile_to_world(support_pos) # Центрируем по тайлу cx")

with open(file_path, "w") as f:
    f.write(content)
