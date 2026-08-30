import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# For DescLabel in CraftTab
c1 = r'(\[node name="DescLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details".*?\nlayout_mode = 2\n)'
content = re.sub(c1, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

# For StatsLabel in CraftTab
c2 = r'(\[node name="StatsLabel" type="Label" parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details".*?\nlayout_mode = 2\n)'
content = re.sub(c2, r'\1label_settings = SubResource("LabelSettings_nd61c")\n', content)

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
