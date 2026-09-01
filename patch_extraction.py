import re

with open("scenes/levels/extraction_zone.tscn", "r") as f:
    content = f.read()

# Replace the texture path
content = content.replace("spr_deco_coracle_land.png", "spr_deco_coracle_strip4.png")

# We don't need AtlasTexture, we can just assign the texture directly and set hframes=4
# But to avoid breaking scene refs, let's just keep the AtlasTexture or add hframes to Sprite2D

sprite_node_pattern = r'(\[node name="Sprite2D" type="Sprite2D".*?\ntexture = SubResource\("AtlasTexture_.*?"\))'

if re.search(sprite_node_pattern, content):
    content = re.sub(sprite_node_pattern, r'\1\nhframes = 4', content)
    
with open("scenes/levels/extraction_zone.tscn", "w") as f:
    f.write(content)
