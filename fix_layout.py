import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Change the main HBoxContainer to VBoxContainer (or keep it as Control/CenterContainer and rearrange)
# It's better to just change the main HBox to VBox
content = content.replace('[node name="HBoxContainer" type="HBoxContainer" parent="DimBackground/CenterContainer"]', 
                          '[node name="MainVBox" type="VBoxContainer" parent="DimBackground/CenterContainer"]\nlayout_mode = 2\ntheme_override_constants/separation = -8\nalignment = 1')

# Now fix the closing of the paths
content = content.replace('parent="DimBackground/CenterContainer/HBoxContainer"', 'parent="DimBackground/CenterContainer/MainVBox"')
content = content.replace('parent="DimBackground/CenterContainer/HBoxContainer/BookPanel"', 'parent="DimBackground/CenterContainer/MainVBox/BookPanel"')
content = content.replace('parent="DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages"', 'parent="DimBackground/CenterContainer/MainVBox/BookPanel/Pages"')
# Just doing a global replace of HBoxContainer to MainVBox for the path
content = content.replace('DimBackground/CenterContainer/HBoxContainer', 'DimBackground/CenterContainer/MainVBox')

# 2. Change Tabs from VBoxContainer to HBoxContainer
content = content.replace('[node name="Tabs" type="VBoxContainer" parent="DimBackground/CenterContainer/MainVBox"]\nlayout_mode = 2\nalignment = 1',
                          '[node name="Tabs" type="HBoxContainer" parent="DimBackground/CenterContainer/MainVBox"]\nlayout_mode = 2\nalignment = 1\ntheme_override_constants/separation = 16')

# 3. Move Tabs BEFORE BookPanel so it renders on top (visually above) or we can just keep it first in the VBox so it's physically above.
# Wait, in the scene file, nodes are ordered as they appear. If I just renamed HBoxContainer to MainVBox, Tabs is currently AFTER BookPanel, meaning it renders BELOW the book.
# Let's extract the Tabs block and move it before BookPanel block.

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)
