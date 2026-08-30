import re

with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

# Add ext_resource if not exists
if 'chicken.tscn' not in content:
    content = content.replace('[ext_resource', '[ext_resource type="PackedScene" path="res://scenes/characters/chicken.tscn" id="chicken_scene"]\n[ext_resource', 1)

# Add chicken nodes under Interactables
if 'name="Chicken1"' not in content:
    # Find the Interactables node and its children block. 
    # The easiest way is to just append it before the next root-level node, or right after the node declaration
    pattern = r'(\[node name="Interactables" type="Node2D"[^\]]*\]\n(?:y_sort_enabled = true\n)?)'
    
    chickens = """[node name="Chicken1" parent="Interactables" instance=ExtResource("chicken_scene")]
position = Vector2(50, 50)

[node name="Chicken2" parent="Interactables" instance=ExtResource("chicken_scene")]
position = Vector2(80, 40)

[node name="Chicken3" parent="Interactables" instance=ExtResource("chicken_scene")]
position = Vector2(20, 90)

"""
    content = re.sub(pattern, r'\1' + chickens, content)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
