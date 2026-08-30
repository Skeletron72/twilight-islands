import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

ext = '[ext_resource type="PackedScene" uid="uid://debugpanel123" path="res://scenes/ui/debug_panel.tscn" id="10_debug"]\n'
content = content.replace('[ext_resource', ext + '[ext_resource', 1)

node = """[node name="DebugPanel" parent="." instance=ExtResource("10_debug")]
"""
content += '\n' + node

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
