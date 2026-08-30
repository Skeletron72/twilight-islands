import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

if 'storage_ui.tscn' not in content:
    # Add to ext_resource
    content = content.replace('[ext_resource type="PackedScene" uid="uid://hotbar123" path="res://scenes/ui/hotbar_ui.tscn" id="5_hotbar"]', 
                              '[ext_resource type="PackedScene" uid="uid://hotbar123" path="res://scenes/ui/hotbar_ui.tscn" id="5_hotbar"]\n[ext_resource type="PackedScene" uid="uid://storageui123" path="res://scenes/ui/storage_ui.tscn" id="6_storage"]')
    
    # Add instance node
    content = content.replace('[node name="HotbarUI" parent="." instance=ExtResource("5_hotbar")]', 
                              '[node name="HotbarUI" parent="." instance=ExtResource("5_hotbar")]\n\n[node name="StorageUI" parent="." instance=ExtResource("6_storage")]')

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
