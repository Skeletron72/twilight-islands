import re

files = [
    'scenes/characters/player/player.tscn',
    'scenes/objects/stone.tscn',
    'scenes/objects/tree.tscn',
    'scenes/objects/campfire.tscn'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Remove the sub_resource
    content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_player_shadow"\].*?region = Rect2\(.*?\)\n\n', '', content, flags=re.DOTALL)
    content = re.sub(r'\[sub_resource type="AtlasTexture" id="AtlasTexture_universal_shadow"\].*?region = Rect2\(.*?\)\n\n', '', content, flags=re.DOTALL)
    
    # Remove the node
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_player_shadow"\)\n\n', '', content, flags=re.DOTALL)
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_universal_shadow"\)\n\n', '', content, flags=re.DOTALL)
    
    with open(filepath, 'w') as f:
        f.write(content)
