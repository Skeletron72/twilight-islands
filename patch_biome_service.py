import sys

file_path = "scripts/components/biome_service.gd"
with open(file_path, "r") as f:
    content = f.read()

# Replace the LAYER_PRIORITY
old_line = 'const LAYER_PRIORITY = ["RoadsLayer", "WaterLayer", "GrassLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]'
new_line = 'const LAYER_PRIORITY = ["ObjectsLayer", "GroundDecorationLayer", "RoadsLayer", "WaterLayer", "GrassLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]'

if old_line in content:
    content = content.replace(old_line, new_line)
    with open(file_path, "w") as f:
        f.write(content)
    print("Patched LAYER_PRIORITY successfully.")
else:
    print("Could not find LAYER_PRIORITY line.")

