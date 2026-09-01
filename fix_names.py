with open("resources/cute_tileset.tres", "r") as f:
    content = f.read()

old_block = """terrain_set_0/terrain_2/name = "Beach Water"
terrain_set_0/terrain_2/color = Color(0.2, 0.7, 0.8, 1)"""

new_block = """terrain_set_0/terrain_2/name = "Sand (Blob)"
terrain_set_0/terrain_2/color = Color(0.9, 0.9, 0.5, 1)"""

if old_block in content:
    content = content.replace(old_block, new_block)
    with open("resources/cute_tileset.tres", "w") as f:
        f.write(content)
    print("Fixed!")
else:
    print("Not found!")
