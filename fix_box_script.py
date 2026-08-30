import re

with open('scenes/objects/storage_box.tscn', 'r') as f:
    content = f.read()

ext = '[ext_resource type="Script" uid="uid://box_script_uid" path="res://scripts/components/storage_box.gd" id="2_script"]\n'
content = content.replace('[sub_resource', ext + '[sub_resource', 1)

content = content.replace('groups=["interactable"]', 'groups=["interactable"]\nscript = ExtResource("2_script")')

with open('scenes/objects/storage_box.tscn', 'w') as f:
    f.write(content)
