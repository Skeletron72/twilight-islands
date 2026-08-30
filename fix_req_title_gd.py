import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Add onready var
old_onready = """@onready var craft_desc = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/DescLabel
@onready var craft_stats = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/StatsLabel
@onready var craft_req_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/CraftButton"""

new_onready = """@onready var craft_desc = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/DescLabel
@onready var craft_stats = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/StatsLabel
@onready var craft_req_title = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/ReqTitle
@onready var craft_req_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/CraftButton"""

content = content.replace(old_onready, new_onready)

# Hide/show logic
old_hide = """	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
		craft_stats.text = ""
		craft_icon.texture = null
		craft_btn.disabled = true
		return
		
	var item = ItemDB.get_item(recipe_id)"""

new_hide = """	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
		craft_stats.text = ""
		craft_icon.texture = null
		craft_btn.disabled = true
		craft_btn.visible = false
		craft_req_title.visible = false
		return
		
	var item = ItemDB.get_item(recipe_id)
	craft_btn.visible = true
	craft_req_title.visible = true"""

content = content.replace(old_hide, new_hide)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
