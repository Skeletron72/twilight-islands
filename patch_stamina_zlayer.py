with open("scenes/characters/player/player.tscn", "r") as f:
    content = f.read()

# Set z_as_relative=false and high z_index on the StaminaIndicator node itself
# so it renders above everything regardless of parent z_index set by z_sort_fix
old = '[node name="StaminaIndicator" type="Node2D" parent="." unique_id=996980844]\nscript = ExtResource("8_xuses")'
new = '[node name="StaminaIndicator" type="Node2D" parent="." unique_id=996980844]\nz_index = 900\nz_as_relative = false\nscript = ExtResource("8_xuses")'

if old in content:
    content = content.replace(old, new)
    print("StaminaIndicator z_index patched")
else:
    print("Pattern not found")

with open("scenes/characters/player/player.tscn", "w") as f:
    f.write(content)
