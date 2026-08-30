import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Add LabelSettings_danvl to Title labels missing it
# Any Label with text = "Экипировка" | "Гардероб" | "Чертежи" | "Создание"
titles = ["Экипировка", "Гардероб", "Чертежи", "Создание"]
for title in titles:
    pattern = rf'(text = "{title}"\nhorizontal_alignment = 1\n)'
    replacement = rf'\1label_settings = SubResource("LabelSettings_danvl")\n'
    content = re.sub(pattern, replacement, content)

# 2. Add LabelSettings_nd61c to other texts
# "Выберите чертеж"
pattern = r'(text = "Выберите чертеж"\n)'
content = re.sub(pattern, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

# DescLabel and StatsLabel in CraftTab
# We can match them via unique_id if we know it, or just match NameLabel / DescLabel blocks
# Let's do it carefully
pattern_desc_craft = r'(\[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab.*?autowrap_mode = 3\n)'
content = re.sub(pattern_desc_craft, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

pattern_stats_craft = r'(\[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab.*?theme_override_font_sizes/font_size = 12\n)'
content = re.sub(pattern_stats_craft, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

pattern_req_craft = r'(text = "Требуется:"\n)'
content = re.sub(pattern_req_craft, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

pattern_quest = r'(text = "Задания пока недоступны"\nhorizontal_alignment = 1\nvertical_alignment = 1\n)'
content = re.sub(pattern_quest, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)


# 3. Add size_flags_horizontal and separations to CharacterTab grids
pattern_equip = r'(\[node name="EquipGrid" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage".*?columns = 2\n)'
replacement = r'\1size_flags_horizontal = 6\ntheme_override_constants/h_separation = 2\ntheme_override_constants/v_separation = 2\n'
content = re.sub(pattern_equip, replacement, content)

pattern_char_inv = r'(\[node name="GridContainer" type="GridContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer".*?columns = 4\n)'
replacement = r'\1size_flags_horizontal = 6\ntheme_override_constants/h_separation = 2\ntheme_override_constants/v_separation = 2\n'
content = re.sub(pattern_char_inv, replacement, content)


# 4. Add horizontal_scroll_mode = 0 to CraftTab RecipeList scroll container to prevent pushing boundaries
pattern_scroll_craft = r'(\[node name="ScrollContainer" type="ScrollContainer" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage".*?size_flags_vertical = 3\n)'
content = re.sub(pattern_scroll_craft, r'\1horizontal_scroll_mode = 0\n', content)


with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)

