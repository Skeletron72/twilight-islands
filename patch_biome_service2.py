import sys

file_path = "scripts/components/biome_service.gd"
with open(file_path, "r") as f:
    content = f.read()

old_if = 'if layer_name == "RoadsLayer":'
new_if = 'if layer_name == "RoadsLayer" or layer_name == "ObjectsLayer" or layer_name == "GroundDecorationLayer":'

if old_if in content:
    content = content.replace(old_if, new_if)
    with open(file_path, "w") as f:
        f.write(content)
    print("Patched is_road successfully.")
else:
    print("Could not find is_road if statement.")

