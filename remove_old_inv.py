import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Remove the line for InventoryUI node
content = re.sub(r'\[node name="InventoryUI" parent="\.".*?instance=ExtResource\("2_inv"\)\]\n', '', content)
# Also remove the ExtResource line just to be clean
content = re.sub(r'\[ext_resource type="PackedScene" uid=".*?" path="res://scenes/ui/inventory_ui.tscn" id="2_inv"\]\n', '', content)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
