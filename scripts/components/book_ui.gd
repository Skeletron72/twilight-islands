extends Control

const InventorySlotScene = preload("res://scenes/ui/inventory_slot.tscn")

const UI_ICONS_PATH = "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png"
const ICONS = {
	"heart_full": Rect2(0, 0, 16, 16),
	"heart_half": Rect2(16, 0, 16, 16),
	"heart_empty": Rect2(32, 0, 16, 16),
	"stamina_full": Rect2(144, 0, 16, 16),
	"stamina_half": Rect2(160, 0, 16, 16),
	"stamina_empty": Rect2(176, 0, 16, 16),
	"shield_full": Rect2(192, 0, 16, 16),
	"shield_half": Rect2(208, 0, 16, 16),
	"shield_empty": Rect2(224, 0, 16, 16),
	"sword": Rect2(96, 16, 16, 16),
	"gift": Rect2(128, 16, 16, 16),
	"mana_full": Rect2(144, 48, 16, 16),
	"mana_half": Rect2(160, 48, 16, 16),
	"mana_empty": Rect2(176, 48, 16, 16),
	"money": Rect2(208, 48, 16, 16),
	"trash": Rect2(224, 48, 16, 16),
	"minus_red": Rect2(96, 64, 16, 16),
	"plus_green": Rect2(96, 96, 16, 16),
}

@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture

@export var bookmark_active_tex: AtlasTexture
@export var bookmark_inactive_tex: AtlasTexture

@onready var book_panel: TextureRect = $DimBackground/CenterContainer/BookContainer/BookPanel
@onready var btn_save: TextureButton = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/BtnSave")

@onready var tabs_container: HBoxContainer = $DimBackground/CenterContainer/BookContainer/Tabs
@onready var pages_container: Control = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)

	hide()
	
	# Setup Inventory Grid
	inventory_grid.columns = 4
	char_inv_grid.columns = 4
	
	# Trim any excess children if present
	while inventory_grid.get_child_count() > 8:
		var c = inventory_grid.get_child(inventory_grid.get_child_count() - 1)
		inventory_grid.remove_child(c)
		c.queue_free()
	while char_inv_grid.get_child_count() > 8:
		var c = char_inv_grid.get_child(char_inv_grid.get_child_count() - 1)
		char_inv_grid.remove_child(c)
		c.queue_free()

	for i in range(8):
		var slot: Control
		if i < inventory_grid.get_child_count():
			slot = inventory_grid.get_child(i)
		else:
			slot = InventorySlotScene.instantiate()
			inventory_grid.add_child(slot)
		slot.set_slot_index(i)
		if not slot.has_meta("click_connected"):
			slot.set_meta("click_connected", true)
			slot.item_clicked.connect(_on_inventory_slot_clicked.bind(slot))
		
		var char_slot: Control
		if i < char_inv_grid.get_child_count():
			char_slot = char_inv_grid.get_child(i)
		else:
			char_slot = InventorySlotScene.instantiate()
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
			
	if btn_save:
		btn_save.pressed.connect(_on_save_pressed)
	if btn_trash:
		btn_trash.pressed.connect(_on_trash_pressed)
		
	_setup_quest_categories()
	_setup_achieve_search()
	_setup_settings_tab()
		
	_switch_tab(0)

func _on_save_pressed() -> void:
	AudioManager.play_sfx(preload("res://assets/audio/ui/sfx_ui_button.mp3"))
	print("Игра сохранена!")

var _book_tween: Tween
var _is_closing: bool = false

@onready var dim_background: ColorRect = $DimBackground
@onready var center_container: CenterContainer = $DimBackground/CenterContainer
@onready var book_container: Control = $DimBackground/CenterContainer/BookContainer

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory"):
		if visible and not _is_closing:
			if achieve_detail_view and achieve_detail_view.visible:
				_show_stats_view()
			else:
				close()
		elif not visible:
			open()
		return
		
	if visible and not _is_closing and event is InputEventKey and event.pressed and not event.echo:
		if achieve_search_edit and achieve_search_edit.has_focus():
			return
		if event.keycode >= KEY_1 and event.keycode <= KEY_7:
			_switch_tab(event.keycode - KEY_1)

func open() -> void:
	_is_closing = false
	if _book_tween and _book_tween.is_valid():
		_book_tween.kill()
		
	show()
	get_tree().paused = true
	
	book_panel.texture = open_book_tex
	pages_container.show()
	tabs_container.show()
	if pages_container.get_child(0).visible:
		_refresh_inventory()

	AudioManager.play_sfx(preload("res://assets/audio/ui/paper_1.mp3"))
	
	var vp_size = get_viewport_rect().size
	var target_y = (vp_size.y - book_container.size.y) / 2.0
	if target_y <= 0:
		target_y = 216.0
		
	book_container.position.y = vp_size.y + 40.0
	dim_background.modulate.a = 0.0
	
	_book_tween = create_tween().set_parallel(true)
	_book_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_book_tween.tween_property(book_container, "position:y", target_y, 0.35)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_book_tween.tween_property(dim_background, "modulate:a", 1.0, 0.22)

func close() -> void:
	if _is_closing:
		return
	_is_closing = true
	
	if selected_inventory_slot and selected_inventory_slot.has_method("set_selected"):
		selected_inventory_slot.set_selected(false)
	selected_inventory_slot = null
	
	if _book_tween and _book_tween.is_valid():
		_book_tween.kill()
		
	var vp_size = get_viewport_rect().size
	var exit_y = vp_size.y + 40.0
	
	_book_tween = create_tween().set_parallel(true)
	_book_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_book_tween.tween_property(book_container, "position:y", exit_y, 0.22)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	_book_tween.tween_property(dim_background, "modulate:a", 0.0, 0.2)
	
	await _book_tween.finished
	if _is_closing:
		hide()
		dim_background.modulate.a = 1.0
		_is_closing = false
		get_tree().paused = false

func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as TextureButton
		if not btn: continue
		
		var is_active = (btn_idx == index)
		btn.texture_normal = bookmark_active_tex if is_active else bookmark_inactive_tex
		# Active tab: bright and 100% visible, Inactive tabs: slightly dimmed tucked behind
		if is_active:
			btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			var icon = btn.get_node_or_null("Icon") as CanvasItem
			if icon: icon.modulate = Color(1.0, 1.0, 1.0, 1.0)
		else:
			btn.modulate = Color(0.72, 0.72, 0.76, 0.85)
			var icon = btn.get_node_or_null("Icon") as CanvasItem
			if icon: icon.modulate = Color(0.75, 0.75, 0.75, 0.8)
			
		btn_idx += 1
		
	if index == 0:
		_refresh_inventory()
	elif index == 1:
		_refresh_character_tab()
	elif index == 2:
		_refresh_craft_tab()
	elif index == 3:
		_refresh_quest_tab()
	elif index == 4:
		_refresh_social_tab()
	elif index == 5:
		_refresh_achieve_tab()

# --- TAB 1: INVENTORY LOGIC ---
@onready var inventory_grid: GridContainer = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/RightPage/GridContainer
@onready var detail_name: Label = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/NameLabel
@onready var detail_desc: Label = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/DescScroll/DescLabel
@onready var detail_icon: TextureRect = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/IconRect
@onready var stats_scroll: ScrollContainer = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/StatsScroll")
@onready var stats_list: Control = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/StatsScroll/StatsList")
@onready var btn_trash: TextureButton = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/InventoryTab/LeftPage/BtnTrash")

var selected_inventory_slot: Control = null
var current_selected_item_id: String = ""

func _on_inventory_slot_clicked(item_id: String, slot: Control) -> void:
	if selected_inventory_slot and selected_inventory_slot != slot:
		if selected_inventory_slot.has_method("set_selected"):
			selected_inventory_slot.set_selected(false)
			
	selected_inventory_slot = slot
	if selected_inventory_slot and selected_inventory_slot.has_method("set_selected"):
		selected_inventory_slot.set_selected(true)
		
	_show_item_details(item_id)

func _refresh_inventory() -> void:
	if selected_inventory_slot and selected_inventory_slot.has_method("set_selected"):
		selected_inventory_slot.set_selected(false)
	selected_inventory_slot = null
	_show_item_details("")
	for child in inventory_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()

func _show_item_details(item_id: String) -> void:
	current_selected_item_id = item_id
	if btn_trash:
		btn_trash.visible = (item_id != "")
		
	if item_id == "":
		if selected_inventory_slot and selected_inventory_slot.has_method("set_selected"):
			selected_inventory_slot.set_selected(false)
		selected_inventory_slot = null
		detail_name.text = "Выберите предмет"
		detail_desc.text = ""
		detail_icon.texture = null
		if stats_scroll:
			stats_scroll.hide()
		return
		
	var item = ItemDB.get_item(item_id)
	if not item.is_empty():
		detail_name.text = item.get("name", "Unknown")
		detail_desc.text = item.get("desc", "")
		detail_icon.texture = ItemDB.get_icon(item_id)
		_update_item_stats(item)

func _update_item_stats(item: Dictionary) -> void:
	if not stats_scroll or not stats_list:
		return
	for c in stats_list.get_children():
		c.queue_free()
		
	var has_stats = false
	var stat_configs = [
		{"key": "hunger_restore", "prefix": "+", "suffix": " Сытость", "atlas": preload("res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png"), "region": Rect2(0, 16, 16, 16), "color": Color(0.15, 0.5, 0.1, 1)},
		{"key": "health_restore", "prefix": "+", "suffix": " Здоровье", "atlas": preload(UI_ICONS_PATH), "region": ICONS["heart_full"], "color": Color(0.85, 0.2, 0.2, 1)},
		{"key": "stamina_restore", "prefix": "+", "suffix": " Энергия", "atlas": preload(UI_ICONS_PATH), "region": ICONS["stamina_full"], "color": Color(0.85, 0.65, 0.1, 1)},
		{"key": "mana_restore", "prefix": "+", "suffix": " Мана", "atlas": preload(UI_ICONS_PATH), "region": ICONS["mana_full"], "color": Color(0.2, 0.45, 0.9, 1)},
		{"key": "damage", "prefix": "+", "suffix": " Урон", "atlas": preload(UI_ICONS_PATH), "region": ICONS["sword"], "color": Color(0.8, 0.25, 0.15, 1)},
		{"key": "defense", "prefix": "+", "suffix": " Защита", "atlas": preload(UI_ICONS_PATH), "region": ICONS["shield_full"], "color": Color(0.2, 0.55, 0.8, 1)},
		{"key": "efficiency", "prefix": "+", "suffix": " Эфф.", "atlas": preload(UI_ICONS_PATH), "region": ICONS["plus_green"], "color": Color(0.15, 0.6, 0.25, 1)},
		{"key": "durability", "prefix": "", "suffix": " Проч.", "region": ICONS["shield_half"], "atlas": preload(UI_ICONS_PATH), "color": Color(0.4, 0.35, 0.3, 1)},
		{"key": "value", "prefix": "", "suffix": " Монет", "atlas": preload(UI_ICONS_PATH), "region": ICONS["money"], "color": Color(0.85, 0.65, 0.1, 1)},
	]
	
	for cfg in stat_configs:
		if item.has(cfg.key) and item[cfg.key] > 0:
			has_stats = true
			var row = HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_theme_constant_override("separation", 3)
			
			var icon = TextureRect.new()
			icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			icon.custom_minimum_size = Vector2(14, 14)
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var tex = AtlasTexture.new()
			tex.atlas = cfg.atlas
			tex.region = cfg.region
			icon.texture = tex
			row.add_child(icon)
			
			var lbl = Label.new()
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.add_theme_color_override("font_color", cfg.color)
			lbl.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			lbl.add_theme_font_size_override("font_size", 8)
			lbl.text = "%s%d%s" % [cfg.prefix, int(item[cfg.key]), cfg.suffix]
			row.add_child(lbl)
			
			stats_list.add_child(row)
			
	stats_scroll.visible = has_stats

func _on_trash_pressed() -> void:
	if current_selected_item_id == "":
		return
	if InventoryManager.get_item_amount(current_selected_item_id) <= 0:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if player and player.get_parent():
		var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
		var drop = dropped_scene.instantiate()
		drop.item_id = current_selected_item_id
		drop.global_position = player.global_position + Vector2(randf_range(-10, 10), 12)
		player.get_parent().add_child(drop)
		
	InventoryManager.remove_item(current_selected_item_id, 1)
	
	var sfx = preload("res://assets/audio/sfx/player/sfx_item_pickup.mp3")
	var asp = AudioStreamPlayer.new()
	asp.stream = sfx
	asp.bus = "Master"
	add_child(asp)
	asp.play()
	asp.finished.connect(asp.queue_free)
	
	var rem_amount = InventoryManager.get_item_amount(current_selected_item_id)
	_refresh_inventory()
	if rem_amount > 0:
		_show_item_details(current_selected_item_id)
	else:
		_show_item_details("")

# --- TAB 2: CHARACTER LOGIC ---
@onready var char_equip_grid = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/EquipGrid
@onready var char_inv_grid = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/RightPage/GridContainer

@onready var stat_hp_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatHp/Label")
@onready var stat_def_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatDef/Label")
@onready var stat_sta_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatStamina/Label")
@onready var stat_atk_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatAtk/Label")
@onready var stat_mana_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatMana/Label")
@onready var stat_money_label: Label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CharacterTab/LeftPage/StatsGrid/StatMoney/Label")

const EQUIP_SLOT_MAP = {
	"SlotHead": "head",
	"SlotAccessory": "accessory",
	"SlotChest": "chest",
	"SlotArtifact": "artifact",
	"SlotBoots": "boots"
}

const EQUIP_DEFAULT_TIPS = {
	"head": "Головной убор",
	"accessory": "Аксессуар",
	"chest": "Одежда",
	"artifact": "Артефакт",
	"boots": "Ноги"
}

func _refresh_character_tab() -> void:
	# Keep char_inv_grid intact and just refresh its slots
	for child in char_inv_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()
			
	# Update equipment slots
	for slot_name in EQUIP_SLOT_MAP.keys():
		var slot_node = char_equip_grid.get_node_or_null(slot_name)
		if not slot_node: continue
		var slot_key = EQUIP_SLOT_MAP[slot_name]
		var icon_rect = slot_node.get_node_or_null("Icon") as TextureRect
		var eq_id = InventoryManager.equipment.get(slot_key, "")
		if icon_rect:
			if eq_id != "":
				icon_rect.texture = ItemDB.get_icon(eq_id)
				icon_rect.show()
				slot_node.tooltip_text = ItemDB.get_item(eq_id).get("name", eq_id)
			else:
				icon_rect.texture = null
				icon_rect.hide()
				slot_node.tooltip_text = EQUIP_DEFAULT_TIPS.get(slot_key, "")
		
		if not slot_node.has_meta("connected"):
			slot_node.set_meta("connected", true)
			slot_node.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					if InventoryManager.equipment.get(slot_key, "") != "":
						InventoryManager.unequip(slot_key)
						_refresh_character_tab()
			)

	# Update live character stats
	if stat_hp_label:
		stat_hp_label.text = "%d/%d" % [int(GameStateManager.current_health), int(GameStateManager.max_health)]
	if stat_sta_label:
		stat_sta_label.text = "%d/%d" % [int(GameStateManager.current_stamina), int(GameStateManager.max_stamina)]
	if stat_mana_label:
		stat_mana_label.text = "50/50"
		
	var total_defense = 0
	for slot_key in InventoryManager.equipment.keys():
		var eq_id = InventoryManager.equipment[slot_key]
		if eq_id != "":
			var item = ItemDB.get_item(eq_id)
			total_defense += item.get("defense", 0)
	if stat_def_label:
		stat_def_label.text = "+%d" % total_defense
		
	var best_dmg = 1
	for slot_item in InventoryManager.ui_slots:
		if slot_item != "":
			var item = ItemDB.get_item(slot_item)
			if item.has("damage") and item["damage"] > best_dmg:
				best_dmg = item["damage"]
	if stat_atk_label:
		stat_atk_label.text = "%d" % best_dmg
		
	if stat_money_label:
		stat_money_label.text = "%d" % InventoryManager.get_item_amount("coin")


# --- TAB 3: CRAFTING LOGIC ---
@onready var craft_recipe_list = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/LeftPage/ScrollContainer/RecipeList
@onready var craft_icon = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/IconRect
@onready var craft_name = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/NameLabel
@onready var craft_desc = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/DescLabel
@onready var craft_stats_box = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/StatsBox
@onready var craft_req_title = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/ReqTitle
@onready var craft_req_list = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/ReqList
@onready var craft_btn = $DimBackground/CenterContainer/BookContainer/BookPanel/Pages/CraftTab/RightPage/CraftButton

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
	
	# Clear old reqs and stats
	for child in craft_req_list.get_children():
		child.queue_free()
	for child in craft_stats_box.get_children():
		child.queue_free()
		
	# Disconnect old signals
	if craft_btn.pressed.is_connected(_on_craft_pressed):
		craft_btn.pressed.disconnect(_on_craft_pressed)
		
	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
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
	
	# Stats with icons
	var craft_stat_configs = [
		{"key": "damage", "prefix": "+", "suffix": " Урон", "region": ICONS["sword"], "color": Color(0.8, 0.25, 0.15, 1)},
		{"key": "defense", "prefix": "+", "suffix": " Защита", "region": ICONS["shield_full"], "color": Color(0.2, 0.55, 0.8, 1)},
		{"key": "efficiency", "prefix": "+", "suffix": " Эфф.", "region": ICONS["plus_green"], "color": Color(0.15, 0.6, 0.25, 1)},
		{"key": "durability", "prefix": "", "suffix": " Проч.", "region": ICONS["shield_half"], "color": Color(0.4, 0.35, 0.3, 1)},
	]
	
	for cfg in craft_stat_configs:
		if item.has(cfg.key) and item[cfg.key] > 0:
			var stat_item = HBoxContainer.new()
			stat_item.add_theme_constant_override("separation", 3)
			
			var s_icon = TextureRect.new()
			s_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			s_icon.custom_minimum_size = Vector2(14, 14)
			s_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			s_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			var s_tex = AtlasTexture.new()
			s_tex.atlas = preload(UI_ICONS_PATH)
			s_tex.region = cfg.region
			s_icon.texture = s_tex
			stat_item.add_child(s_icon)
			
			var s_lbl = Label.new()
			s_lbl.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			s_lbl.add_theme_font_size_override("font_size", 8)
			s_lbl.add_theme_color_override("font_color", cfg.color)
			s_lbl.text = "%s%d%s" % [cfg.prefix, int(item[cfg.key]), cfg.suffix]
			stat_item.add_child(s_lbl)
			
			craft_stats_box.add_child(stat_item)
	
	var recipe = ItemDB.RECIPES[recipe_id]
	var can_craft = true
	
	for req_id in recipe:
		var req_amt = recipe[req_id]
		var have_amt = InventoryManager.get_item_amount(req_id)
		
		var req_box = HBoxContainer.new()
		req_box.add_theme_constant_override("separation", 4)
		
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
	InventoryManager.add_item(current_craft_id, 1)
	GameStateManager.register_item_crafted(current_craft_id)
	
	# Notify QuestManager of crafted item
	if QuestManager:
		QuestManager.report_craft(current_craft_id, 1)
	
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

# ==============================================================================
# --- TAB 4: QUEST TAB LOGIC ---
# ==============================================================================
@onready var quest_list_container = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/LeftPage/ScrollContainer/QuestList")
@onready var quest_icon_rect = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/HeaderBox/PortraitFrame/QuestIcon")
@onready var quest_title_label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/HeaderBox/TitleBox/QuestTitle")
@onready var quest_category_label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/HeaderBox/TitleBox/QuestCategory")
@onready var quest_desc_label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/QuestDesc")
@onready var quest_obj_list = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/ObjList")
@onready var quest_reward_box = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/RewardBox")
@onready var quest_claim_btn = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/RightPage/ClaimButton")

@onready var btn_cat_main = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/LeftPage/Categories/BtnCatMain")
@onready var btn_cat_side = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/LeftPage/Categories/BtnCatSide")
@onready var btn_cat_explore = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/LeftPage/Categories/BtnCatExplore")
@onready var btn_cat_completed = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/QuestTab/LeftPage/Categories/BtnCatCompleted")

var current_quest_cat: String = "main"
var current_selected_quest_id: String = ""

func _setup_quest_categories() -> void:
	if btn_cat_main:
		btn_cat_main.pressed.connect(func(): _set_quest_category("main"))
	if btn_cat_side:
		btn_cat_side.pressed.connect(func(): _set_quest_category("side"))
	if btn_cat_explore:
		btn_cat_explore.pressed.connect(func(): _set_quest_category("explore"))
	if btn_cat_completed:
		btn_cat_completed.pressed.connect(func(): _set_quest_category("completed"))
	if quest_claim_btn:
		quest_claim_btn.pressed.connect(_on_quest_claim_pressed)
		
	if QuestManager:
		if not QuestManager.quest_updated.is_connected(_on_quest_manager_updated):
			QuestManager.quest_updated.connect(_on_quest_manager_updated)
		if not QuestManager.quest_completed.is_connected(_on_quest_manager_updated):
			QuestManager.quest_completed.connect(_on_quest_manager_updated)
		if not QuestManager.quest_claimed.is_connected(_on_quest_manager_updated):
			QuestManager.quest_claimed.connect(_on_quest_manager_updated)

func _set_quest_category(cat: String) -> void:
	current_quest_cat = cat
	_refresh_quest_category_buttons()
	_refresh_quest_list()

func _refresh_quest_category_buttons() -> void:
	var active_color = Color(1.0, 0.45, 0.1, 1.0)
	var normal_color = Color(0.85, 0.8, 0.75, 1.0)
	if btn_cat_main:
		btn_cat_main.modulate = active_color if current_quest_cat == "main" else normal_color
	if btn_cat_side:
		btn_cat_side.modulate = active_color if current_quest_cat == "side" else normal_color
	if btn_cat_explore:
		btn_cat_explore.modulate = active_color if current_quest_cat == "explore" else normal_color
	if btn_cat_completed:
		var unclaimed = QuestManager.get_unclaimed_completed_count() if QuestManager else 0
		btn_cat_completed.text = "Готово (%d)" % unclaimed if unclaimed > 0 else "Готово"
		btn_cat_completed.modulate = active_color if current_quest_cat == "completed" else normal_color

func _refresh_quest_tab() -> void:
	if QuestManager:
		QuestManager.evaluate_all_quests()
	_refresh_quest_category_buttons()
	_refresh_quest_list()

func _refresh_quest_list() -> void:
	if not quest_list_container: return
	for child in quest_list_container.get_children():
		child.queue_free()

	if not QuestManager:
		_show_quest_details("")
		return

	var category_quests = QuestManager.get_quests_by_category(current_quest_cat)
	var first_id = ""
	var has_current_selected = false

	for q in category_quests:
		var q_id = q.get("id", "")
		if first_id == "":
			first_id = q_id
		if q_id == current_selected_quest_id:
			has_current_selected = true

		var btn = Button.new()
		var q_status = q.get("status", "active")
		
		# Text and font color based on status
		if q_status == "claimed":
			btn.text = " " + q.get("title", "") + " (Выполнено)"
			btn.add_theme_color_override("font_color", Color(0.45, 0.4, 0.35, 0.8))
			btn.add_theme_color_override("font_hover_color", Color(0.35, 0.3, 0.25, 1.0))
		elif q_status == "completed":
			btn.text = " " + q.get("title", "") + " [Готово!]"
			btn.add_theme_color_override("font_color", Color(0.08, 0.45, 0.1, 1.0))
			btn.add_theme_color_override("font_hover_color", Color(0.12, 0.6, 0.15, 1.0))
		else:
			btn.text = " " + q.get("title", "")
			btn.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
			btn.add_theme_color_override("font_hover_color", Color(0.4, 0.2, 0.1, 1))

		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.clip_text = true
		btn.flat = true
		btn.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
		btn.add_theme_font_size_override("font_size", 11)
		btn.add_theme_color_override("font_pressed_color", Color(0.1, 0.05, 0.02, 1))

		var empty_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("hover", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)
		btn.add_theme_stylebox_override("focus", empty_style)

		# Icon based on status or category
		var icon_atlas = AtlasTexture.new()
		icon_atlas.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
		if q_status == "completed" or q_status == "claimed":
			icon_atlas.region = ICONS["plus_green"]
		else:
			if current_quest_cat == "main":
				icon_atlas.region = Rect2(192, 32, 16, 16)
			elif current_quest_cat == "side":
				icon_atlas.region = Rect2(304, 32, 16, 16)
			else:
				icon_atlas.region = Rect2(272, 32, 16, 16)
		btn.icon = icon_atlas

		btn.pressed.connect(func(): _show_quest_details(q_id))
		quest_list_container.add_child(btn)

	if has_current_selected:
		_show_quest_details(current_selected_quest_id)
	elif first_id != "":
		_show_quest_details(first_id)
	else:
		_show_quest_details("")

func _show_quest_details(quest_id: String) -> void:
	current_selected_quest_id = quest_id
	if not quest_title_label: return

	if quest_id == "" or not QuestManager or not QuestManager.quests.has(quest_id):
		quest_title_label.text = "Нет заданий"
		if quest_category_label: quest_category_label.text = ""
		if quest_icon_rect: quest_icon_rect.texture = null
		if quest_desc_label: quest_desc_label.text = "В этой категории пока нет заданий."
		if quest_obj_list:
			for c in quest_obj_list.get_children(): c.queue_free()
		if quest_reward_box:
			for c in quest_reward_box.get_children(): c.queue_free()
		if quest_claim_btn:
			quest_claim_btn.disabled = true
			quest_claim_btn.text = "Забрать награду"
			quest_claim_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
		return

	var q = QuestManager.get_quest(quest_id)
	quest_title_label.text = q.get("title", "")
	
	if quest_category_label:
		var cat = q.get("category", "")
		if cat == "main":
			quest_category_label.text = "Основное задание"
		elif cat == "side":
			quest_category_label.text = "Дополнительное задание"
		else:
			quest_category_label.text = "Исследование"

	if quest_icon_rect:
		var icon_atlas = AtlasTexture.new()
		icon_atlas.atlas = load(q.get("icon_atlas", "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png"))
		icon_atlas.region = q.get("icon_region", Rect2(192, 32, 16, 16))
		quest_icon_rect.texture = icon_atlas

	if quest_desc_label:
		quest_desc_label.text = q.get("desc", "")

	# Objectives list with live counters
	if quest_obj_list:
		for c in quest_obj_list.get_children(): c.queue_free()
		for obj in q.get("objectives", []):
			var obj_row = HBoxContainer.new()
			obj_row.add_theme_constant_override("separation", 4)
			
			var chk = TextureRect.new()
			var chk_tex = AtlasTexture.new()
			chk_tex.atlas = preload(UI_ICONS_PATH)
			var is_done = obj.get("is_done", false)
			chk_tex.region = ICONS["plus_green"] if is_done else ICONS["minus_red"]
			chk.texture = chk_tex
			chk.custom_minimum_size = Vector2(10, 10)
			chk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			chk.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			obj_row.add_child(chk)
			
			var l = Label.new()
			var cur_amt = obj.get("current_amount", 0)
			var tgt_amt = obj.get("target_amount", 1)
			l.text = "%s (%d/%d)" % [obj.get("text", ""), cur_amt, tgt_amt]
			l.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			l.add_theme_font_size_override("font_size", 8)
			l.add_theme_color_override("font_color", Color(0.05, 0.45, 0.05, 1) if is_done else Color(0.3, 0.25, 0.2, 1))
			obj_row.add_child(l)
			quest_obj_list.add_child(obj_row)

	# Rewards list with real icons
	if quest_reward_box:
		for c in quest_reward_box.get_children(): c.queue_free()
		for rew in q.get("rewards", []):
			var rew_card = HBoxContainer.new()
			rew_card.add_theme_constant_override("separation", 3)
			var icon_rect = TextureRect.new()
			var rew_item = rew.get("item_id", "")
			if rew_item == "coin" or rew.get("type", "") == "coin":
				var m_tex = AtlasTexture.new()
				m_tex.atlas = preload(UI_ICONS_PATH)
				m_tex.region = ICONS["money"]
				icon_rect.texture = m_tex
			else:
				icon_rect.texture = ItemDB.get_icon(rew_item)
			icon_rect.custom_minimum_size = Vector2(16, 16)
			icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			rew_card.add_child(icon_rect)

			var rew_label = Label.new()
			if rew_item == "coin" or rew.get("type", "") == "coin":
				rew_label.text = "%d Монет" % rew.get("amount", 1)
			else:
				rew_label.text = "%s (x%d)" % [rew.get("name", ""), rew.get("amount", 1)]
			rew_label.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			rew_label.add_theme_font_size_override("font_size", 8)
			rew_label.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
			rew_card.add_child(rew_label)
			quest_reward_box.add_child(rew_card)

	# Interactive Claim Button
	if quest_claim_btn:
		var q_status = q.get("status", "active")
		if q_status == "completed":
			quest_claim_btn.disabled = false
			quest_claim_btn.text = "Забрать награду!"
			quest_claim_btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
			quest_claim_btn.add_theme_color_override("font_color", Color(0.1, 0.55, 0.15, 1.0))
			quest_claim_btn.add_theme_color_override("font_hover_color", Color(0.15, 0.7, 0.2, 1.0))
		elif q_status == "claimed":
			quest_claim_btn.disabled = true
			quest_claim_btn.text = "Выполнено"
			quest_claim_btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
			quest_claim_btn.add_theme_color_override("font_color", Color(0.35, 0.35, 0.35, 1.0))
		else:
			quest_claim_btn.disabled = true
			quest_claim_btn.text = "В процессе"
			quest_claim_btn.modulate = Color(0.7, 0.7, 0.7, 0.8)
			quest_claim_btn.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3, 1.0))

func _on_quest_claim_pressed() -> void:
	if current_selected_quest_id == "" or not QuestManager:
		return
	if QuestManager.claim_reward(current_selected_quest_id):
		_refresh_quest_list()
		_show_quest_details(current_selected_quest_id)

func _on_quest_manager_updated(_quest_id: String) -> void:
	if visible:
		_refresh_quest_list()
		if current_selected_quest_id != "":
			_show_quest_details(current_selected_quest_id)

# ==============================================================================
# --- TAB 5: SOCIAL TAB LOGIC ---
# ==============================================================================
@onready var social_npc_list = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/LeftPage/ScrollContainer/NpcList")
@onready var social_portrait = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/HeaderBox/PortraitFrame/Portrait")
@onready var social_name_label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/HeaderBox/NpcName")
@onready var social_hearts_box = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/HeaderBox/HeartContainer")
@onready var social_desc_label = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/SocialDesc")
@onready var social_fav_box = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/FavGiftsBox")
@onready var social_dis_box = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SocialTab/RightPage/DisGiftsBox")

const NPC_DATA = {
	"finn": {
		"name": "Рыбак Финн",
		"portrait": "res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Fisherman_Fin.png",
		"hearts": 4.0,
		"quote": "«Всегда рад хорошим товарам с дальних берегов! Если поможешь с древесиной, сделаю скидку на снасти.»",
		"fav_gifts": ["purple_berry", "red_berry"],
		"dis_gifts": ["stone", "twilight_ore"]
	},
	"elias": {
		"name": "Староста Элиас",
		"portrait": "res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Farmer_Bob.png",
		"hearts": 2.5,
		"quote": "«Остров полон тайн и опасностей. Держись ближе к очагу, когда опускается туман, путник.»",
		"fav_gifts": ["campfire", "cloth_basic"],
		"dis_gifts": ["stick"]
	},
	"lily": {
		"name": "Травница Лили",
		"portrait": "res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Chef_Chloe.png",
		"hearts": 5.0,
		"quote": "«Здешние грибы и ягоды обладают целебной силой. Береги природу острова, и она спасет тебя в трудную минуту!»",
		"fav_gifts": ["red_mushroom", "blue_mushroom", "purple_mushroom"],
		"dis_gifts": ["wooden_axe", "stone_axe"]
	}
}

func _refresh_social_tab() -> void:
	if not social_npc_list: return
	for child in social_npc_list.get_children():
		child.queue_free()

	for npc_id in NPC_DATA.keys():
		var npc = NPC_DATA[npc_id]
		var card = Button.new()
		card.custom_minimum_size = Vector2(170, 36)
		card.flat = true

		var empty_style = StyleBoxEmpty.new()
		card.add_theme_stylebox_override("normal", empty_style)
		card.add_theme_stylebox_override("hover", empty_style)
		card.add_theme_stylebox_override("pressed", empty_style)
		card.add_theme_stylebox_override("focus", empty_style)

		var hbox = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 6)
		hbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var p_tex = TextureRect.new()
		if npc.has("portrait"):
			p_tex.texture = load(npc["portrait"])
		else:
			p_tex.texture = preload("res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Fisherman_Fin.png")
		p_tex.custom_minimum_size = Vector2(24, 28)
		p_tex.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		p_tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(p_tex)

		var vbox = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 2)
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var name_lbl = Label.new()
		name_lbl.text = npc.get("name", "")
		name_lbl.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
		name_lbl.add_theme_font_size_override("font_size", 11)
		name_lbl.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
		vbox.add_child(name_lbl)

		var heart_h = HBoxContainer.new()
		heart_h.add_theme_constant_override("separation", 1)
		var h_count = float(npc.get("hearts", 0.0))
		for h_i in range(5):
			var h_icon = TextureRect.new()
			var h_atlas = AtlasTexture.new()
			h_atlas.atlas = preload(UI_ICONS_PATH)
			if (h_i + 1.0) <= h_count:
				h_atlas.region = ICONS["heart_full"]
			elif (h_i + 0.5) <= h_count:
				h_atlas.region = ICONS["heart_half"]
			else:
				h_atlas.region = ICONS["heart_empty"]
			h_icon.texture = h_atlas
			h_icon.custom_minimum_size = Vector2(10, 10)
			h_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			h_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			heart_h.add_child(h_icon)
		vbox.add_child(heart_h)

		hbox.add_child(vbox)
		card.add_child(hbox)
		card.pressed.connect(func(): _show_npc_details(npc_id))
		social_npc_list.add_child(card)

	_show_npc_details("finn")

func _show_npc_details(npc_id: String) -> void:
	if not NPC_DATA.has(npc_id): return
	var npc = NPC_DATA[npc_id]

	if social_portrait and npc.has("portrait"):
		social_portrait.texture = load(npc["portrait"])
	if social_name_label: social_name_label.text = npc.get("name", "")
	if social_desc_label: social_desc_label.text = npc.get("quote", "")

	if social_hearts_box:
		for c in social_hearts_box.get_children(): c.queue_free()
		var h_count = float(npc.get("hearts", 0.0))
		for h_i in range(5):
			var h_icon = TextureRect.new()
			var h_atlas = AtlasTexture.new()
			h_atlas.atlas = preload(UI_ICONS_PATH)
			if (h_i + 1.0) <= h_count:
				h_atlas.region = ICONS["heart_full"]
			elif (h_i + 0.5) <= h_count:
				h_atlas.region = ICONS["heart_half"]
			else:
				h_atlas.region = ICONS["heart_empty"]
			h_icon.texture = h_atlas
			h_icon.custom_minimum_size = Vector2(14, 14)
			h_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			h_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			social_hearts_box.add_child(h_icon)

	if social_fav_box:
		for c in social_fav_box.get_children(): c.queue_free()
		for item_id in npc.get("fav_gifts", []):
			social_fav_box.add_child(_create_gift_slot(item_id))

	if social_dis_box:
		for c in social_dis_box.get_children(): c.queue_free()
		for item_id in npc.get("dis_gifts", []):
			social_dis_box.add_child(_create_gift_slot(item_id))

func _create_gift_slot(item_id: String) -> Control:
	var slot = TextureRect.new()
	var frame_atlas = AtlasTexture.new()
	frame_atlas.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Frames.png")
	frame_atlas.region = Rect2(1022, 158, 20, 20)
	slot.texture = frame_atlas
	slot.custom_minimum_size = Vector2(26, 26)
	slot.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	slot.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	var icon = TextureRect.new()
	icon.texture = ItemDB.get_icon(item_id)
	icon.custom_minimum_size = Vector2(18, 18)
	icon.anchors_preset = Control.PRESET_CENTER
	icon.anchor_left = 0.5
	icon.anchor_top = 0.5
	icon.anchor_right = 0.5
	icon.anchor_bottom = 0.5
	icon.offset_left = -9
	icon.offset_top = -9
	icon.offset_right = 9
	icon.offset_bottom = 9
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(icon)
	slot.tooltip_text = ItemDB.get_item(item_id).get("name", item_id)
	return slot

# ==============================================================================
# --- TAB 6: ACHIEVEMENTS TAB LOGIC ---
# ==============================================================================
@onready var achieve_search_edit = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/LeftPage/SearchEdit")
@onready var achieve_list_container = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/LeftPage/ScrollContainer/AchieveList")
@onready var achieve_stats_view = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/StatsView")
@onready var achieve_stats_list = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/StatsView/StatsScroll/StatsList")
@onready var achieve_detail_view = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView")
@onready var achieve_detail_icon = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/HeaderBox/IconFrame/AchieveIcon")
@onready var achieve_detail_name = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/HeaderBox/AchieveName")
@onready var achieve_detail_desc = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/AchieveDesc")
@onready var achieve_detail_progress_bar = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/ProgressBar")
@onready var achieve_detail_date = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/DateObtained")
@onready var achieve_detail_reward = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/AchieveRewardBox")
@onready var btn_back_to_stats = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/AchieveTab/RightPage/DetailView/BtnBackToStats")

func _get_time_of_day_name() -> String:
	match GameStateManager.current_time:
		GameStateManager.TimeOfDay.MORNING: return "Утро"
		GameStateManager.TimeOfDay.DAY: return "День"
		GameStateManager.TimeOfDay.DUSK: return "Сумерки"
		GameStateManager.TimeOfDay.NIGHT: return "Ночь"
	return "День"

# Scalable statistics categories with live real-time getters
var stat_categories: Array = [
	{
		"title": "Время и выживание",
		"icon_region": Rect2(208, 96, 16, 16),
		"color": Color(0.2, 0.45, 0.7, 1),
		"items": [
			{"label": "Дней на острове", "getter": func(): return "%d дн." % GameStateManager.current_day},
			{"label": "Время суток", "getter": func(): return _get_time_of_day_name()},
			{"label": "Здоровье", "getter": func(): return "%d / %d" % [int(ceil(GameStateManager.current_health)), int(GameStateManager.max_health)]},
			{"label": "Сытость", "getter": func(): return "%d%%" % int(round(GameStateManager.current_hunger))},
			{"label": "Выносливость", "getter": func(): return "%d / %d" % [int(ceil(GameStateManager.current_stamina)), int(GameStateManager.max_stamina)]}
		]
	},
	{
		"title": "Исследования и мир",
		"icon_region": Rect2(160, 32, 16, 16),
		"color": Color(0.2, 0.55, 0.35, 1),
		"items": [
			{"label": "Пройдено пешком", "getter": func(): return GameStateManager.get_distance_display()},
			{"label": "Уровень судна", "getter": func(): var t = GameStateManager.get_current_boat_tier(); return "%s (Ур. %d)" % [t.get("name", "Лодка"), GameStateManager.boat_level]},
			{"label": "Открыто сундуков", "getter": func(): return "%d шт." % GameStateManager.stat_chests_opened},
			{"label": "Зажжено костров", "getter": func(): return "%d раз" % GameStateManager.stat_campfires_lit}
		]
	},
	{
		"title": "Ресурсы и ремесло",
		"icon_region": Rect2(48, 16, 16, 16),
		"color": Color(0.65, 0.4, 0.15, 1),
		"items": [
			{"label": "Срублено деревьев", "getter": func(): return "%d шт." % GameStateManager.stat_trees_chopped},
			{"label": "Разбито камней", "getter": func(): return "%d шт." % GameStateManager.stat_stones_mined},
			{"label": "Собрано ягод и кустов", "getter": func(): return "%d шт." % GameStateManager.stat_bushes_harvested},
			{"label": "Собрано предметов", "getter": func(): return "%d шт." % GameStateManager.stat_items_gathered},
			{"label": "Создано предметов", "getter": func(): return "%d шт." % GameStateManager.stat_items_crafted},
			{"label": "Изучено рецептов", "getter": func(): return "%d из %d" % [GameStateManager.get_known_recipes_count(), GameStateManager.get_total_recipes_count()]}
		]
	},
	{
		"title": "Островные подвиги",
		"icon_region": Rect2(96, 16, 16, 16),
		"color": Color(0.7, 0.25, 0.2, 1),
		"items": [
			{"label": "Побеждено чудовищ", "getter": func(): return "%d" % GameStateManager.stat_monsters_killed},
			{"label": "Выполнено заданий", "getter": func(): return "%d из %d" % [GameStateManager.get_completed_quests_count(), GameStateManager.get_total_quests_count()]},
			{"label": "Поймано рыбы", "getter": func(): return "%d шт." % GameStateManager.stat_fish_caught}
		]
	}
]

# Scalable real achievements catalog
const ACHIEVEMENTS_CONFIG: Array[Dictionary] = [
	{
		"id": "fire_starter",
		"title": "Первый костер",
		"desc": "Разжечь костер на острове, чтобы спастись от ночного холода и мрака.",
		"stat_key": "campfires_lit",
		"target": 1,
		"unit": "раз",
		"icon_region": Rect2(80, 16, 16, 16),
		"reward": "Рубиника x5"
	},
	{
		"id": "woodcutter_1",
		"title": "Лесоруб I",
		"desc": "Срубить 10 деревьев или распилить брёвна топором.",
		"stat_key": "trees_chopped",
		"target": 10,
		"unit": "шт.",
		"icon_region": Rect2(48, 16, 16, 16),
		"reward": "Древесина x10"
	},
	{
		"id": "woodcutter_2",
		"title": "Лесоруб II",
		"desc": "Заготовить много древесины: срубить 50 деревьев.",
		"stat_key": "trees_chopped",
		"target": 50,
		"unit": "шт.",
		"icon_region": Rect2(48, 16, 16, 16),
		"reward": "Каменный топор x1"
	},
	{
		"id": "miner_1",
		"title": "Шахтер",
		"desc": "Расколоть 10 каменных валунов или залежей киркой.",
		"stat_key": "stones_mined",
		"target": 10,
		"unit": "шт.",
		"icon_region": Rect2(48, 16, 16, 16),
		"reward": "Камень x10"
	},
	{
		"id": "crafter_1",
		"title": "Умелые руки",
		"desc": "Создать 5 полезных предметов или инструментов по чертежам.",
		"stat_key": "items_crafted",
		"target": 5,
		"unit": "шт.",
		"icon_region": Rect2(48, 16, 16, 16),
		"reward": "Палка x10"
	},
	{
		"id": "crafter_2",
		"title": "Мастер на все руки",
		"desc": "Создать 20 полезных предметов или инструментов.",
		"stat_key": "items_crafted",
		"target": 20,
		"unit": "шт.",
		"icon_region": Rect2(48, 16, 16, 16),
		"reward": "Деревянный сундук x1"
	},
	{
		"id": "island_walker_1",
		"title": "Следопыт",
		"desc": "Пройти пешком более 500 метров по таинственным тропам острова.",
		"stat_key": "distance_meters",
		"target": 500,
		"unit": "м",
		"icon_region": Rect2(208, 96, 16, 16),
		"reward": "Сумеречница x5"
	},
	{
		"id": "island_walker_2",
		"title": "Первооткрыватель",
		"desc": "Преодолеть долгий путь в 2 километра по берегам архипелага.",
		"stat_key": "distance_km",
		"target": 2.0,
		"unit": "км",
		"icon_region": Rect2(208, 96, 16, 16),
		"reward": "Кожаные сапоги x1"
	},
	{
		"id": "gatherer_1",
		"title": "Запасливый собиратель",
		"desc": "Подобрать и собрать 30 любых ресурсов или предметов.",
		"stat_key": "items_gathered",
		"target": 30,
		"unit": "шт.",
		"icon_region": Rect2(160, 32, 16, 16),
		"reward": "Монеты x50"
	},
	{
		"id": "monster_slayer",
		"title": "Храбрый защитник",
		"desc": "Одолеть 3 опасных порождений острова в бою.",
		"stat_key": "monsters_killed",
		"target": 3,
		"unit": "врагов",
		"icon_region": Rect2(96, 16, 16, 16),
		"reward": "Каменный меч x1"
	},
	{
		"id": "quest_novice",
		"title": "Первое поручение",
		"desc": "Выполнить хотя бы 1 задание на острове.",
		"stat_key": "quests_completed",
		"target": 1,
		"unit": "задание",
		"icon_region": Rect2(192, 32, 16, 16),
		"reward": "Монеты x100"
	},
	{
		"id": "survivor_3",
		"title": "Бывалый островитянин",
		"desc": "Прожить на острове 3 полных дня и ночи.",
		"stat_key": "current_day",
		"target": 3,
		"unit": "дней",
		"icon_region": Rect2(80, 16, 16, 16),
		"reward": "Монеты x150"
	},
	{
		"id": "boat_repair",
		"title": "Морской первопроходец",
		"desc": "Починить разбитый остов лодки на причале и открыть путь к экспедициям.",
		"stat_key": "boat_level",
		"target": 1,
		"unit": "ур.",
		"icon_region": Rect2(160, 32, 16, 16),
		"reward": "Монеты x100"
	}
]

func _get_achievement_state(ach: Dictionary) -> Dictionary:
	var stat_key = ach.get("stat_key", "")
	var target = ach.get("target", 1)
	var raw_val = GameStateManager.get_stat_value(stat_key)
	var current_val: float = float(raw_val)
	var is_completed: bool = (current_val >= float(target))
	var progress_pct: float = clampf(current_val / float(target), 0.0, 1.0)
	
	var ach_id = ach.get("id", "")
	if is_completed and not GameStateManager.unlocked_achievements.has(ach_id):
		var day_str = "День %d" % GameStateManager.current_day
		GameStateManager.unlocked_achievements[ach_id] = day_str
		
		# SFX on unlock
		var sfx_res = load("res://assets/audio/ui/Achievement_unlock_–_#1-1766766517076.mp3")
		if sfx_res and AudioManager:
			AudioManager.play_sfx(sfx_res, 1.0, 0.0)
	
	var date_str = GameStateManager.unlocked_achievements.get(ach_id, "В процессе")
	var unit = ach.get("unit", "")
	var progress_str = ""
	if typeof(target) == TYPE_FLOAT:
		progress_str = "%.1f / %.1f %s" % [min(current_val, float(target)), float(target), unit]
	else:
		progress_str = "%d / %d %s" % [int(min(current_val, float(target))), int(target), unit]
		
	return {
		"completed": is_completed,
		"current_val": current_val,
		"target": target,
		"progress_pct": progress_pct,
		"progress_str": progress_str,
		"date": date_str
	}

func _setup_achieve_search() -> void:
	if achieve_search_edit:
		achieve_search_edit.text_changed.connect(func(_text): _refresh_achieve_list())
	if btn_back_to_stats:
		btn_back_to_stats.pressed.connect(_show_stats_view)

func _refresh_achieve_tab() -> void:
	_refresh_achieve_list()
	_refresh_stats_list()
	_show_stats_view()

func _refresh_stats_list() -> void:
	if not achieve_stats_list: return
	for c in achieve_stats_list.get_children(): c.queue_free()

	for cat in stat_categories:
		# Category Header
		var cat_box = HBoxContainer.new()
		cat_box.add_theme_constant_override("separation", 4)
		
		var cat_icon = TextureRect.new()
		cat_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		cat_icon.custom_minimum_size = Vector2(12, 12)
		cat_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		cat_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		var icon_tex = AtlasTexture.new()
		icon_tex.atlas = preload(UI_ICONS_PATH)
		icon_tex.region = cat.get("icon_region", Rect2(80, 16, 16, 16))
		cat_icon.texture = icon_tex
		cat_box.add_child(cat_icon)
		
		var cat_title = Label.new()
		cat_title.text = cat.get("title", "")
		cat_title.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		cat_title.add_theme_font_size_override("font_size", 9)
		cat_title.add_theme_color_override("font_color", cat.get("color", Color(0.2, 0.1, 0.05, 1)))
		cat_box.add_child(cat_title)
		achieve_stats_list.add_child(cat_box)
		
		# Category Items
		for item in cat.get("items", []):
			var row = HBoxContainer.new()
			row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var lbl_name = Label.new()
			lbl_name.text = " • " + item.get("label", "") + ":"
			lbl_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl_name.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			lbl_name.add_theme_font_size_override("font_size", 8)
			lbl_name.add_theme_color_override("font_color", Color(0.3, 0.25, 0.2, 1))
			row.add_child(lbl_name)
			
			var getter_fn = item.get("getter")
			var val_str = getter_fn.call() if getter_fn is Callable else str(getter_fn)
			
			var lbl_val = Label.new()
			lbl_val.text = val_str
			lbl_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			lbl_val.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
			lbl_val.add_theme_font_size_override("font_size", 8)
			lbl_val.add_theme_color_override("font_color", Color(0.12, 0.1, 0.08, 1))
			row.add_child(lbl_val)
			
			achieve_stats_list.add_child(row)
			
		# Spacer after category
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 4)
		achieve_stats_list.add_child(spacer)

func _refresh_achieve_list() -> void:
	if not achieve_list_container: return
	for child in achieve_list_container.get_children(): child.queue_free()

	var query = achieve_search_edit.text.to_lower().strip_edges() if achieve_search_edit else ""

	for ach in ACHIEVEMENTS_CONFIG:
		var ach_id = ach.get("id", "")
		var title = ach.get("title", "")
		var desc = ach.get("desc", "")
		if query != "" and not title.to_lower().contains(query) and not desc.to_lower().contains(query):
			continue

		var state = _get_achievement_state(ach)

		var btn = Button.new()
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.flat = true
		btn.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		btn.clip_text = true

		var empty_style = StyleBoxEmpty.new()
		btn.add_theme_stylebox_override("normal", empty_style)
		btn.add_theme_stylebox_override("pressed", empty_style)

		var hover_style = StyleBoxFlat.new()
		hover_style.bg_color = Color(0.4, 0.3, 0.2, 0.15)
		hover_style.corner_radius_top_left = 2
		hover_style.corner_radius_top_right = 2
		hover_style.corner_radius_bottom_left = 2
		hover_style.corner_radius_bottom_right = 2
		btn.add_theme_stylebox_override("hover", hover_style)
		btn.add_theme_stylebox_override("focus", hover_style)

		var icon_atlas = AtlasTexture.new()
		icon_atlas.atlas = preload(UI_ICONS_PATH)
		icon_atlas.region = ach.get("icon_region", Rect2(80, 16, 16, 16))
		btn.icon = icon_atlas

		var suffix = " (✓)" if state.completed else " (%s)" % state.progress_str
		btn.text = " " + title + suffix
		btn.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		btn.add_theme_font_size_override("font_size", 9)
		btn.add_theme_color_override("font_color", Color(0, 0.45, 0.1, 1) if state.completed else Color(0.25, 0.18, 0.12, 1))
		btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

		btn.pressed.connect(_show_achieve_detail.bind(ach_id))
		achieve_list_container.add_child(btn)

func _show_stats_view() -> void:
	if achieve_stats_view: achieve_stats_view.show()
	if achieve_detail_view: achieve_detail_view.hide()

func _show_achieve_detail(ach_id: String) -> void:
	var ach: Dictionary = {}
	for a in ACHIEVEMENTS_CONFIG:
		if a.get("id") == ach_id:
			ach = a
			break
	if ach.is_empty(): return

	var state = _get_achievement_state(ach)

	if achieve_stats_view: achieve_stats_view.hide()
	if achieve_detail_view: achieve_detail_view.show()

	if achieve_detail_name: achieve_detail_name.text = ach.get("title", "")
	if achieve_detail_desc: achieve_detail_desc.text = ach.get("desc", "")
	
	if achieve_detail_icon:
		var icon_tex = AtlasTexture.new()
		icon_tex.atlas = preload(UI_ICONS_PATH)
		icon_tex.region = ach.get("icon_region", Rect2(80, 16, 16, 16))
		achieve_detail_icon.texture = icon_tex
		
	if achieve_detail_progress_bar:
		var bg_sb = StyleBoxFlat.new()
		bg_sb.bg_color = Color(0.78, 0.72, 0.62, 0.7)
		bg_sb.corner_radius_top_left = 3; bg_sb.corner_radius_top_right = 3
		bg_sb.corner_radius_bottom_left = 3; bg_sb.corner_radius_bottom_right = 3
		
		var fill_sb = StyleBoxFlat.new()
		fill_sb.bg_color = Color(0.2, 0.55, 0.22, 1.0) if state.completed else Color(0.72, 0.48, 0.15, 1.0)
		fill_sb.corner_radius_top_left = 3; fill_sb.corner_radius_top_right = 3
		fill_sb.corner_radius_bottom_left = 3; fill_sb.corner_radius_bottom_right = 3
		
		achieve_detail_progress_bar.add_theme_stylebox_override("background", bg_sb)
		achieve_detail_progress_bar.add_theme_stylebox_override("fill", fill_sb)
		achieve_detail_progress_bar.max_value = 100.0
		achieve_detail_progress_bar.value = state.progress_pct * 100.0

	if achieve_detail_date:
		if state.completed:
			achieve_detail_date.text = "Статус: Выполнено (%s)" % state.date
			achieve_detail_date.add_theme_color_override("font_color", Color(0, 0.48, 0.12, 1))
		else:
			achieve_detail_date.text = "Прогресс: %s (%.0f%%)" % [state.progress_str, state.progress_pct * 100.0]
			achieve_detail_date.add_theme_color_override("font_color", Color(0.65, 0.42, 0.1, 1))

	if achieve_detail_reward:
		for c in achieve_detail_reward.get_children(): c.queue_free()
		var r_lbl = Label.new()
		r_lbl.text = "• " + ach.get("reward", "")
		r_lbl.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
		r_lbl.add_theme_font_size_override("font_size", 8)
		r_lbl.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
		achieve_detail_reward.add_child(r_lbl)

# --- TAB 7: SETTINGS TAB LOGIC ---
@onready var master_slider = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/MasterSlider")
@onready var master_val = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/MasterHeader/MasterVal")
@onready var music_slider = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/MusicSlider")
@onready var music_val = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/MusicHeader/MusicVal")
@onready var sfx_slider = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/SfxSlider")
@onready var sfx_val = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/SfxHeader/SfxVal")
@onready var btn_fullscreen = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/BtnFullscreen")
@onready var btn_vsync = get_node_or_null("DimBackground/CenterContainer/BookContainer/BookPanel/Pages/SettingsTab/LeftPage/AudioVideoContainer/BtnVsync")

func _setup_settings_tab() -> void:
	if master_slider:
		var bus_idx = AudioServer.get_bus_index("Master")
		if bus_idx >= 0:
			var db = AudioServer.get_bus_volume_db(bus_idx)
			var vol_pct = int(round(db_to_linear(db) * 100.0))
			master_slider.value = vol_pct
			if master_val: master_val.text = "%d%%" % vol_pct
		master_slider.value_changed.connect(_on_master_volume_changed)

	if music_slider:
		var bus_idx = AudioServer.get_bus_index("Music")
		if bus_idx >= 0:
			var db = AudioServer.get_bus_volume_db(bus_idx)
			var vol_pct = int(round(db_to_linear(db) * 100.0))
			music_slider.value = vol_pct
			if music_val: music_val.text = "%d%%" % vol_pct
		music_slider.value_changed.connect(_on_music_volume_changed)

	if sfx_slider:
		var bus_idx = AudioServer.get_bus_index("SFX")
		if bus_idx >= 0:
			var db = AudioServer.get_bus_volume_db(bus_idx)
			var vol_pct = int(round(db_to_linear(db) * 100.0))
			sfx_slider.value = vol_pct
			if sfx_val: sfx_val.text = "%d%%" % vol_pct
		sfx_slider.value_changed.connect(_on_sfx_volume_changed)

	if btn_fullscreen:
		_update_fullscreen_btn_text()
		btn_fullscreen.pressed.connect(_on_fullscreen_pressed)

	if btn_vsync:
		_update_vsync_btn_text()
		btn_vsync.pressed.connect(_on_vsync_pressed)

func _on_master_volume_changed(val: float) -> void:
	if master_val: master_val.text = "%d%%" % int(val)
	_apply_bus_volume("Master", val)

func _on_music_volume_changed(val: float) -> void:
	if music_val: music_val.text = "%d%%" % int(val)
	_apply_bus_volume("Music", val)

func _on_sfx_volume_changed(val: float) -> void:
	if sfx_val: sfx_val.text = "%d%%" % int(val)
	_apply_bus_volume("SFX", val)

func _apply_bus_volume(bus_name: String, pct: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx < 0: return
	if pct <= 0.0:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(pct / 100.0))

func _update_fullscreen_btn_text() -> void:
	if not btn_fullscreen: return
	var mode = DisplayServer.window_get_mode()
	var is_fs = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	btn_fullscreen.text = "Экран: [ Полный ]" if is_fs else "Экран: [ Окно ]"

func _on_fullscreen_pressed() -> void:
	var mode = DisplayServer.window_get_mode()
	var is_fs = (mode == DisplayServer.WINDOW_MODE_FULLSCREEN or mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	if is_fs:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	_update_fullscreen_btn_text()

func _update_vsync_btn_text() -> void:
	if not btn_vsync: return
	var mode = DisplayServer.window_get_vsync_mode()
	var is_on = (mode != DisplayServer.VSYNC_DISABLED)
	btn_vsync.text = "V-Sync: [ Вкл ]" if is_on else "V-Sync: [ Выкл ]"

func _on_vsync_pressed() -> void:
	var mode = DisplayServer.window_get_vsync_mode()
	var new_mode = DisplayServer.VSYNC_DISABLED if mode != DisplayServer.VSYNC_DISABLED else DisplayServer.VSYNC_ENABLED
	DisplayServer.window_set_vsync_mode(new_mode)
	_update_vsync_btn_text()
