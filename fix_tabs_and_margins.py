import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# 1. Decrease margins to shift content outward
old_margins = """theme_override_constants/margin_left = 16
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 16
theme_override_constants/margin_bottom = 18"""
new_margins = """theme_override_constants/margin_left = 12
theme_override_constants/margin_top = 18
theme_override_constants/margin_right = 12
theme_override_constants/margin_bottom = 18"""
content = content.replace(old_margins, new_margins)

# 2. Resize Tabs to 42x42
content = content.replace('custom_minimum_size = Vector2(48, 48)', 'custom_minimum_size = Vector2(42, 42)')

# 3. Ensure all Icons inside Tabs have mouse_filter = 2
# Let's just blindly add mouse_filter = 2 to the Icon nodes inside Tabs
# Since we might not know their exact unique_id, we can use regex
content = re.sub(r'(\[node name="Icon" type="TextureRect" parent="DimBackground/CenterContainer/MainVBox/Tabs/.*?".*?\]\n)',
                 r'\1mouse_filter = 2\n', content)

# 4. Decrease Tabs Spacer to compensate for smaller tabs?
# Tab width was 48, now 42. (Difference of 6px per tab = 24px total)
# If tabs are smaller, they shift left by 24px.
# To keep them over the right page, we can slightly increase Spacer from 250 to 260.
content = content.replace('custom_minimum_size = Vector2(250, 0)', 'custom_minimum_size = Vector2(260, 0)')

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(content)

