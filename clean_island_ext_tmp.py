import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Strip broken references
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/levels/twilight_ore.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/tree.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/spruce_tree.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/small_spruce.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/dead_tree.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/small_bush.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/berry_bush.tscn".*?\]\n', '', content)
content = re.sub(r'\[ext_resource type="PackedScene".*?path="res://scenes/objects/gatherable.tscn".*?\]\n', '', content)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
