import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Add ext_resource for crafting UI
if 'res://scenes/ui/crafting_ui.tscn' not in content:
    content = content.replace('[node name="HomeIsland"', 
                              '[ext_resource type="PackedScene" uid="uid://craftui123" path="res://scenes/ui/crafting_ui.tscn" id="10_cui"]\n\n[node name="HomeIsland"')

# Add nodes
nodes = """
[node name="CraftingUI" parent="." instance=ExtResource("10_cui")]
"""

# Append to end
content += nodes

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
