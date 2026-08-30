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
    
    # Remove the shadow node
    # It looks like:
    # [node name="Shadow" type="Sprite2D" parent="..." unique_id="..."]
    # position = ...
    # texture = SubResource("...")
    #
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_[^"]+"\)\n\n', '', content, flags=re.DOTALL)
    
    # In campfire, it didn't have unique_id or newlines exactly the same way if it was different
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?position = Vector2\(0, 0\)\n\n', '', content, flags=re.DOTALL)

    # Some of them had position = Vector2(0, -2) and then texture
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_universal_shadow"\)\n\n', '', content, flags=re.DOTALL)
    content = re.sub(r'\[node name="Shadow" type="Sprite2D".*?texture = SubResource\("AtlasTexture_player_shadow"\)\n\n', '', content, flags=re.DOTALL)
    
    # Clean up empty lines
    content = content.replace('\n\n\n', '\n\n')

    with open(filepath, 'w') as f:
        f.write(content)
