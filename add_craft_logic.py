import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

new_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	if index == 0:
		_refresh_inventory()
	elif index == 1:
		_refresh_character_tab()
	elif index == 2:
		_refresh_craft_tab()"""

content = content.replace("""func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	if index == 0:
		_refresh_inventory()
	elif index == 1:
		_refresh_character_tab()""", new_switch)


craft_logic = """
# --- TAB 3: CRAFT LOGIC ---
@onready var craft_recipe_list = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollContainer/RecipeList
@onready var craft_icon = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer/IconRect
@onready var craft_name = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/HBoxContainer/NameLabel
@onready var craft_desc = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/DescLabel
@onready var craft_stats = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/StatsLabel
@onready var craft_req_list = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/Details/CraftButton

var current_craft_id = ""

func _refresh_craft_tab() -> void:
	_show_recipe_details("")
	
	for child in craft_recipe_list.get_children():
		child.queue_free()
		
	for recipe_id in ItemDB.RECIPES.keys():
		var btn = Button.new()
		var item = ItemDB.get_item(recipe_id)
		btn.text = item.get("name", recipe_id)
		btn.icon = ItemDB.get_icon(recipe_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func(): _show_recipe_details(recipe_id))
		craft_recipe_list.add_child(btn)

func _show_recipe_details(recipe_id: String) -> void:
	current_craft_id = recipe_id
	
	# Clear old reqs
	for child in craft_req_list.get_children():
		child.queue_free()
		
	# Disconnect old signals
	if craft_btn.pressed.is_connected(_on_craft_pressed):
		craft_btn.pressed.disconnect(_on_craft_pressed)
		
	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
		craft_stats.text = ""
		craft_icon.texture = null
		craft_btn.disabled = true
		return
		
	var item = ItemDB.get_item(recipe_id)
	craft_name.text = item.get("name", "")
	craft_desc.text = item.get("desc", "")
	craft_icon.texture = ItemDB.get_icon(recipe_id)
	
	# Stats
	var stats_text = ""
	if item.has("damage"): stats_text += "Урон: %d  " % item["damage"]
	if item.has("efficiency"): stats_text += "Эффективность: %d  " % item["efficiency"]
	if item.has("defense"): stats_text += "Защита: %d  " % item["defense"]
	if item.has("durability"): stats_text += "Прочность: %d" % item["durability"]
	craft_stats.text = stats_text
	
	var recipe = ItemDB.RECIPES[recipe_id]
	var can_craft = true
	
	for req_id in recipe:
		var req_amt = recipe[req_id]
		var have_amt = InventoryManager.get_item_amount(req_id)
		
		var req_label = Label.new()
		req_label.text = "- %s: %d / %d" % [ItemDB.get_item(req_id).get("name", req_id), have_amt, req_amt]
		
		if have_amt < req_amt:
			req_label.add_theme_color_override("font_color", Color.RED)
			can_craft = false
		else:
			req_label.add_theme_color_override("font_color", Color(0, 0.4, 0))
			
		craft_req_list.add_child(req_label)
		
	craft_btn.disabled = not can_craft
	if can_craft:
		craft_btn.pressed.connect(_on_craft_pressed)

func _on_craft_pressed() -> void:
	if current_craft_id == "": return
	var recipe = ItemDB.RECIPES[current_craft_id]
	
	# Remove ingredients
	for req_id in recipe:
		InventoryManager.remove_item(req_id, recipe[req_id])
		
	# Add crafted item (to safe inventory if we are home, or temp if we are in raid)
	# Wait, add_item automatically handles Mode.SAFE / Mode.RAID!
	InventoryManager.add_item(current_craft_id, 1)
	
	# Refresh UI
	_show_recipe_details(current_craft_id)
"""

content += craft_logic

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
