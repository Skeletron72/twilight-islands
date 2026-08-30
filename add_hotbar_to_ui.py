import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Add HotbarUI to the UI layer
ext_res = """[ext_resource type="PackedScene" uid="uid://hotbar123" path="res://scenes/ui/hotbar_ui.tscn" id="5_hotbar"]"""

content = content.replace('[ext_resource type="PackedScene" uid="uid://m0b1l3ctrl5" path="res://scenes/ui/mobile_controls.tscn" id="4_mob"]', 
                          '[ext_resource type="PackedScene" uid="uid://m0b1l3ctrl5" path="res://scenes/ui/mobile_controls.tscn" id="4_mob"]\n' + ext_res)

hotbar_node = """[node name="HotbarUI" parent="." instance=ExtResource("5_hotbar")]"""
content = content.replace('[node name="MobileControls" parent="." unique_id=1148640189 instance=ExtResource("4_mob")]', 
                          hotbar_node + '\n\n[node name="MobileControls" parent="." unique_id=1148640189 instance=ExtResource("4_mob")]')

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
