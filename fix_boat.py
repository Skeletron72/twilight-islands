import re

# Update extraction_zone.tscn
with open('scenes/levels/extraction_zone.tscn', 'r') as f:
    content = f.read()

# Replace land texture with water texture
content = content.replace('spr_deco_coracle_land.png', 'spr_deco_coracle_strip4.png')
# Add hframes
content = re.sub(r'(\[node name="Sprite2D".*?texture = [^\n]+)', r'\1\nhframes = 4', content)

with open('scenes/levels/extraction_zone.tscn', 'w') as f:
    f.write(content)

# Update positions in home_island
with open('scenes/levels/home_island.tscn', 'r') as f:
    content = f.read()

content = re.sub(r'\[node name="Boat".*?\nposition = Vector2\([0-9\., ]+\)', '[node name="Boat" parent="." unique_id=523352899 instance=ExtResource("8_boat")]\nposition = Vector2(40, 160)', content)

with open('scenes/levels/home_island.tscn', 'w') as f:
    f.write(content)
    
# Update positions in raid_island
with open('scenes/levels/raid_island.tscn', 'r') as f:
    content = f.read()
    
content = re.sub(r'\[node name="Boat".*?\nposition = Vector2\([0-9\., ]+\)', '[node name="Boat" parent="." unique_id=11111111 instance=ExtResource("8_boat")]\nposition = Vector2(40, 160)', content)

with open('scenes/levels/raid_island.tscn', 'w') as f:
    f.write(content)
