with open("scenes/characters/player/player.tscn", "r") as f:
    content = f.read()

# 1. Add ext_resource for Loading_Icon if not present
tex_res = '[ext_resource type="Texture2D" uid="" path="res://assets/new_assets/Cute_Fantasy_UI/UI/Loading_Icon.png" id="loading_icon_tex"]'
if "Loading_Icon.png" not in content:
    # Insert after first [ext_resource line
    first_ext = content.find("[ext_resource")
    content = content[:first_ext] + tex_res + "\n" + content[first_ext:]
    print("Added Loading_Icon ext_resource")
else:
    # Find its id
    import re
    m = re.search(r'\[ext_resource[^\]]*Loading_Icon\.png[^\]]*id="([^"]+)"', content)
    if m:
        tex_res = tex_res.replace("loading_icon_tex", m.group(1))
    print("Loading_Icon already present, id:", m.group(1) if m else "?")

# 2. Fix StaminaIndicator - remove broken Sprite2D if any, re-add correct one
# Remove anything that was appended incorrectly
while '\n[node name="Sprite2D" type="Sprite2D" parent="StaminaIndicator"' in content:
    start = content.find('\n[node name="Sprite2D" type="Sprite2D" parent="StaminaIndicator"')
    end = content.find("\n[", start + 1)
    if end == -1:
        end = len(content)
    content = content[:start] + content[end:]
    print("Removed old broken Sprite2D")

# 3. Append correct Sprite2D at the end
# Get the correct tex id
import re
m = re.search(r'\[ext_resource[^\]]*Loading_Icon\.png[^\]]*id="([^"]+)"', content)
tex_id = m.group(1) if m else "loading_icon_tex"

content = content.rstrip() + '''

[node name="Sprite2D" type="Sprite2D" parent="StaminaIndicator" unique_id="stamp_spr_01"]
texture = ExtResource("''' + tex_id + '''")
hframes = 16
frame = 15
z_index = 10
'''

with open("scenes/characters/player/player.tscn", "w") as f:
    f.write(content)
print("player.tscn patched!")
