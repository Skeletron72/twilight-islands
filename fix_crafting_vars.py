import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Add missing craft variables right before _refresh_craft_tab
craft_vars = """
# --- TAB 3: CRAFTING LOGIC ---
@onready var craft_recipe_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer/RecipeList
@onready var craft_icon = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer/IconRect
@onready var craft_name = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer/NameLabel
@onready var craft_desc = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/DescLabel
@onready var craft_stats = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/StatsLabel
@onready var craft_req_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/CraftButton

var current_craft_id: String = ""

"""

content = content.replace('func _refresh_craft_tab() -> void:', craft_vars + 'func _refresh_craft_tab() -> void:')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
