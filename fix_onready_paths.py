import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_grid = "$DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/ScrollContainer/GridContainer"
new_grid = "$DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer/GridContainer"

old_details = "$DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/Details"
new_details = "$DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details"

content = content.replace(old_grid, new_grid)
content = content.replace(old_details, new_details)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
