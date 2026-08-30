import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 3. Add size_flags_horizontal and separations to CharacterTab grids
pattern_equip = r'(\[node name="EquipGrid" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage".*?columns = 2\n)'
replacement = r'\1size_flags_horizontal = 6\ntheme_override_constants/h_separation = 2\ntheme_override_constants/v_separation = 2\n'
content = re.sub(pattern_equip, replacement, content, flags=re.DOTALL)

pattern_char_inv = r'(\[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer".*?columns = 4\n)'
replacement = r'\1size_flags_horizontal = 6\ntheme_override_constants/h_separation = 2\ntheme_override_constants/v_separation = 2\n'
content = re.sub(pattern_char_inv, replacement, content, flags=re.DOTALL)

pattern_scroll_craft = r'(\[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage".*?size_flags_vertical = 3\n)'
content = re.sub(pattern_scroll_craft, r'\1horizontal_scroll_mode = 0\n', content, flags=re.DOTALL)

# Re-apply some texts that might have failed
pattern_desc_craft = r'(\[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab.*?autowrap_mode = 3\n)'
content = re.sub(pattern_desc_craft, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content, flags=re.DOTALL)

pattern_stats_craft = r'(\[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab.*?theme_override_font_sizes/font_size = 12\n)'
content = re.sub(pattern_stats_craft, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content, flags=re.DOTALL)


with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
