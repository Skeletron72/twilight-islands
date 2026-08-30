import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_path = "@onready var craft_recipe_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer/RecipeList"
new_path = "@onready var craft_recipe_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollMargin/ScrollContainer/RecipeList"

content = content.replace(old_path, new_path)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
