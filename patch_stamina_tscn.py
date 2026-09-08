with open("scenes/characters/player/player.tscn", "r") as f:
    content = f.read()

old = '''[node name="Sprite2D" type="Sprite2D" parent="StaminaIndicator" unique_id="stamp_spr_01"]
texture = ExtResource("loading_icon_tex")
hframes = 16
frame = 15
z_index = 10'''

new = '''[node name="Sprite2D" type="Sprite2D" parent="StaminaIndicator" unique_id="stamp_spr_01"]
texture = ExtResource("loading_icon_tex")
hframes = 16
vframes = 1
frame = 15
z_index = 10'''

if old in content:
    content = content.replace(old, new)
    with open("scenes/characters/player/player.tscn", "w") as f:
        f.write(content)
    print("Fixed: vframes=1")
else:
    print("Pattern not found")
