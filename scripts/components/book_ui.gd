extends Control

const InventorySlotScene = preload("res://scenes/ui/inventory_slot.tscn")

@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture

@export var bookmark_active_tex: AtlasTexture
@export var bookmark_inactive_tex: AtlasTexture

@export var icon_inv_active: AtlasTexture
@export var icon_inv_inactive: AtlasTexture
@export var icon_char_active: AtlasTexture
@export var icon_char_inactive: AtlasTexture
@export var icon_craft_active: AtlasTexture
@export var icon_craft_inactive: AtlasTexture
@export var icon_quest_active: AtlasTexture
@export var icon_quest_inactive: AtlasTexture

@onready var book_panel: TextureRect = $DimBackground/CenterContainer/MainVBox/BookPanel

@onready var tabs_container: HBoxContainer = $DimBackground/CenterContainer/MainVBox/Tabs
@onready var pages_container: MarginContainer = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	hide()
	
	# Setup Inventory Grid
	inventory_grid.columns = 4
	char_inv_grid.columns = 4
	for i in range(8):
		var slot = InventorySlotScene.instantiate()
		inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		slot.item_clicked.connect(_show_item_details)
		
		var char_slot = InventorySlotScene.instantiate()
		char_inv_grid.add_child(char_slot)
		char_slot.set_slot_index(i)
		# For character tab, clicking currently equips it (from previous logic)
		char_slot.item_clicked.connect(func(id):
			InventoryManager.equip(id)
			_refresh_character_tab()
		)
		
	# Listen to UI slot changes
	InventoryManager.ui_slots_changed.connect(_on_ui_slots_changed)
	
	# Connect tab buttons
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as BaseButton
		if btn:
			btn.pressed.connect(_switch_tab.bind(btn_idx))
			btn_idx += 1
		
	_switch_tab(0)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		if visible:
			close()
		else:
			open()

var is_animating: bool = false

func open() -> void:
	if is_animating: return
	is_animating = true
	show()
	get_tree().paused = true
	
	pages_container.hide()
	tabs_container.hide()
	book_panel.texture = closed_book_tex
	
	
	await get_tree().create_timer(0.15, true).timeout
	
	book_panel.texture = open_book_tex
	pages_container.show()
	tabs_container.show()
	is_animating = false
	if pages_container.get_child(0).visible:
		_refresh_inventory()

func close() -> void:
	if is_animating: return
	is_animating = true
	
	pages_container.hide()
	tabs_container.hide()
	book_panel.texture = closed_book_tex
	
	await get_tree().create_timer(0.15, true).timeout
	
	hide()
	get_tree().paused = false
	is_animating = false

func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	# Skip the first child of tabs_container because it's our Spacer!
	# The actual buttons are at index + 1
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as TextureButton
		if not btn: continue
		
		btn.texture_normal = bookmark_active_tex if btn_idx == index else bookmark_inactive_tex
		
		# Now update the icon inside the button
		var icon = btn.get_node_or_null("Icon") as TextureRect
		if icon:
			if btn_idx == 0: icon.texture = icon_inv_active if btn_idx == index else icon_inv_inactive
			elif btn_idx == 1: icon.texture = icon_char_active if btn_idx == index else icon_char_inactive
			elif btn_idx == 2: icon.texture = icon_craft_active if btn_idx == index else icon_craft_inactive
			elif btn_idx == 3: icon.texture = icon_quest_active if btn_idx == index else icon_quest_inactive
		
		btn_idx += 1
		
	if index == 0:
		_refresh_inventory()
	elif index == 1:
		_refresh_character_tab()
	elif index == 2:
		_refresh_craft_tab()

# --- TAB 1: INVENTORY LOGIC ---
@onready var inventory_grid: GridContainer = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/RightPage/ScrollContainer/GridContainer
@onready var detail_name: Label = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details/NameLabel
@onready var detail_desc: Label = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details/DescLabel
@onready var detail_icon: TextureRect = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/InventoryTab/HBoxContainer/LeftPage/Details/IconRect

func _refresh_inventory() -> void:
	_show_item_details("")
	for child in inventory_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()

func _show_item_details(item_id: String) -> void:
	if item_id == "":
		detail_name.text = "Выберите предмет"
		detail_desc.text = ""
		detail_icon.texture = null
		return
		
	var item = ItemDB.get_item(item_id)
	if not item.is_empty():
		detail_name.text = item.get("name", "Unknown")
		detail_desc.text = item.get("desc", "")
		detail_icon.texture = ItemDB.get_icon(item_id)

# --- TAB 2: CHARACTER LOGIC ---
@onready var char_equip_grid = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage/EquipGrid
@onready var char_inv_grid = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer/GridContainer

func _refresh_character_tab() -> void:
	# Keep char_inv_grid intact and just refresh its slots
	for child in char_inv_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()
			
	# Update equipment grid (rebuilding is fine for equip slots since we haven't ported them to drag-drop yet)
	for child in char_equip_grid.get_children():
		child.queue_free()
		
	var slots = ["chest", "boots", "weapon"]
	for s in slots:
			var slot_panel = TextureRect.new()
			var atlas = AtlasTexture.new()
			atlas.atlas = preload("res://assets/sprites/ui/inventory/UI.png")
			atlas.region = Rect2(416, 272, 16, 16)
			slot_panel.texture = atlas
			slot_panel.custom_minimum_size = Vector2(42, 42)
			
			var icon = TextureRect.new()
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			icon.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			var eq_id = InventoryManager.equipment.get(s, "")
			if eq_id != "":
				icon.texture = ItemDB.get_icon(eq_id)
				
			slot_panel.add_child(icon)
			
			if eq_id != "":
				slot_panel.mouse_filter = Control.MOUSE_FILTER_STOP
				slot_panel.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
				
				slot_panel.gui_input.connect(func(event: InputEvent):
					if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
						InventoryManager.unequip(s)
						_refresh_character_tab()
				)
				
			char_equip_grid.add_child(slot_panel)


# --- TAB 3: CRAFTING LOGIC ---
@onready var craft_recipe_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/LeftPage/ScrollMargin/ScrollContainer/RecipeList
@onready var craft_icon = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer/IconRect
@onready var craft_name = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/HBoxContainer/NameLabel
@onready var craft_desc = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/DescLabel
@onready var craft_stats = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/StatsLabel
@onready var craft_req_title = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/ReqTitle
@onready var craft_req_list = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/MainVBox/BookPanel/Pages/CraftTab/HBoxContainer/RightPage/DetailsMargin/Details/CraftButton

var current_craft_id: String = ""

func _refresh_craft_tab() -> void:
	_show_recipe_details("")
	
	for child in craft_recipe_list.get_children():
		child.queue_free()
		
	for recipe_id in ItemDB.RECIPES.keys():
		var btn = Button.new()
		var item = ItemDB.get_item(recipe_id)
		btn.text = " " + item.get("name", recipe_id)
		btn.icon = ItemDB.get_icon(recipe_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.clip_text = true
		
		btn.flat = true
		btn.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
		btn.add_theme_font_size_override("font_size", 12)
		btn.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
		btn.add_theme_color_override("font_hover_color", Color(0.4, 0.2, 0.1, 1))
		btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.05, 0.02, 1))
		
		var empty_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.add_theme_stylebox_override("focus", empty_style)
		
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
		craft_icon.visible = false
		craft_btn.disabled = true
		craft_btn.visible = false
		craft_req_title.visible = false
		return
		
	var item = ItemDB.get_item(recipe_id)
	craft_icon.visible = true
	craft_btn.visible = true
	craft_req_title.visible = true
	craft_name.text = item.get("name", "")
	craft_desc.text = item.get("desc", "")
	craft_icon.texture = ItemDB.get_icon(recipe_id)
	
	# Stats
	var stats_parts = []
	if item.has("damage"): stats_parts.append("Урон: %d" % item["damage"])
	if item.has("efficiency"): stats_parts.append("Эфф: %d" % item["efficiency"])
	if item.has("defense"): stats_parts.append("Защита: %d" % item["defense"])
	if item.has("durability"): stats_parts.append("Проч: %d" % item["durability"])
	craft_stats.text = " ".join(stats_parts)
	
	var recipe = ItemDB.RECIPES[recipe_id]
	var can_craft = true
	
	for req_id in recipe:
		var req_amt = recipe[req_id]
		var have_amt = InventoryManager.get_item_amount(req_id)
		
		var req_box = HBoxContainer.new()
		
		var icon = TextureRect.new()
		icon.texture = ItemDB.get_icon(req_id)
		icon.custom_minimum_size = Vector2(16, 16)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		req_box.add_child(icon)
		
		var req_label = Label.new()
		req_label.text = "%s: %d / %d" % [ItemDB.get_item(req_id).get("name", req_id), have_amt, req_amt]
		req_label.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		req_label.add_theme_font_size_override("font_size", 8)
		req_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		req_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		if have_amt < req_amt:
			req_label.add_theme_color_override("font_color", Color(0.8, 0.0, 0.0))
			can_craft = false
		else:
			req_label.add_theme_color_override("font_color", Color(0, 0.4, 0))
			
		req_box.add_child(req_label)
		craft_req_list.add_child(req_box)
		
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

func _on_ui_slots_changed(idx: int) -> void:
	if inventory_grid.get_child_count() > idx:
		var slot = inventory_grid.get_child(idx)
		if slot.has_method("_refresh"):
			slot._refresh()
	if char_inv_grid.get_child_count() > idx:
		var char_slot = char_inv_grid.get_child(idx)
		if char_slot.has_method("_refresh"):
			char_slot._refresh()


func _on_visibility_changed() -> void:
	var hotbar = get_parent().get_node_or_null("HotbarUI")
	if hotbar:
		hotbar.visible = not self.visible
