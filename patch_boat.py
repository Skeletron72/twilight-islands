import re

with open("scenes/levels/extraction_zone.tscn", "r") as f:
    content = f.read()

# Replace the texture path. I might have replaced it to spr_deco_coracle_strip4.png before.
pattern = r'path="res://assets/sprites/other/spr_deco_coracle_strip4\.png"'
new_path = 'path="res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Other_Animations/Boat_Anim.png"'

content = re.sub(pattern, new_path, content)
# Also just in case it's still spr_deco_coracle_land.png
pattern2 = r'path="res://assets/sprites/other/spr_deco_coracle_land\.png"'
content = re.sub(pattern2, new_path, content)

with open("scenes/levels/extraction_zone.tscn", "w") as f:
    f.write(content)
