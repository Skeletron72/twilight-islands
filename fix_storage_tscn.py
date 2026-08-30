import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

# Add script resource at the top
if 'storage_box.gd' not in content:
    content = content.replace('[ext_resource type="Texture2D"', '[ext_resource type="Script" path="res://scripts/components/storage_box.gd" id="1_script"]\n[ext_resource type="Texture2D"')

# Add script and collision properties to the root node
old_node = '[node name="StorageBox" type="StaticBody2D" unique_id=1251090626 groups=["interactable"]]\ny_sort_enabled = true'
new_node = """[node name="StorageBox" type="StaticBody2D" unique_id=1251090626 groups=["interactable"]]
y_sort_enabled = true
collision_layer = 5
collision_mask = 1
script = ExtResource("1_script")"""

content = content.replace(old_node, new_node)

with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)
