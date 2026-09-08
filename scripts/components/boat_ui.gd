extends Control

@onready var title_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/TitleLabel
@onready var tier_name_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/TierNameLabel
@onready var status_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/StatusLabel
@onready var desc_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/DescLabel
@onready var perks_container = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/PerksContainer

@onready var upgrade_title_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/UpgradeTitleLabel
@onready var next_tier_label = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/NextTierLabel
@onready var requirements_container = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/RequirementsContainer
@onready var action_button = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ActionButton
@onready var sail_button = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/SailButton
@onready var close_button = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/CloseButton

var current_boat_node: Node2D = null

func _ready() -> void:
	visible = false
	if action_button:
		action_button.pressed.connect(_on_action_button_pressed)
	if sail_button:
		sail_button.pressed.connect(_on_sail_button_pressed)
	if close_button:
		close_button.pressed.connect(close)
	
	if GameStateManager.has_signal("boat_upgraded"):
		GameStateManager.boat_upgraded.connect(_on_boat_upgraded)
	if InventoryManager.has_signal("inventory_changed"):
		InventoryManager.inventory_changed.connect(_on_inventory_changed)

func _input(event: InputEvent) -> void:
	if visible:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory") or (event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE):
			close()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("ui_accept") or (event is InputEventKey and event.pressed and (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE)):
			if action_button and action_button.visible and not action_button.disabled:
				_on_action_button_pressed()
				get_viewport().set_input_as_handled()
			elif sail_button and sail_button.visible and not sail_button.disabled:
				_on_sail_button_pressed()
				get_viewport().set_input_as_handled()
		elif event is InputEventKey and event.pressed and (event.keycode == KEY_E or event.keycode == KEY_S):
			if sail_button and sail_button.visible and not sail_button.disabled:
				_on_sail_button_pressed()
				get_viewport().set_input_as_handled()

func open(boat_node: Node2D = null) -> void:
	current_boat_node = boat_node
	visible = true
	get_tree().paused = true
	_refresh_ui()

func close() -> void:
	visible = false
	current_boat_node = null
	get_tree().paused = false

func _on_boat_upgraded(_new_level: int) -> void:
	if visible:
		_refresh_ui()

func _on_inventory_changed(_item_id: String = "", _new_amount: int = 0) -> void:
	if visible:
		_refresh_ui()

func _on_action_button_pressed() -> void:
	if GameStateManager.can_upgrade_boat():
		var success = GameStateManager.upgrade_boat()
		if success:
			# Play craft SFX
			var audio_mgr = get_node_or_null("/root/AudioManager")
			if audio_mgr and audio_mgr.has_method("play_sfx"):
				audio_mgr.play_sfx(preload("res://assets/audio/sfx/player/sfx_craft.mp3"))
			_refresh_ui()

func _on_sail_button_pressed() -> void:
	if GameStateManager.boat_level <= 0:
		return
	close()
	if current_boat_node and current_boat_node.has_method("start_departure"):
		current_boat_node.start_departure()
	elif current_boat_node and current_boat_node.has_method("extract"):
		current_boat_node.extract()
	else:
		TransitionManager.transition_to("res://scenes/levels/raid_island.tscn", "Отплываем в экспедицию...")

func _refresh_ui() -> void:
	var cur_tier = GameStateManager.get_current_boat_tier()
	var next_tier = GameStateManager.get_next_boat_tier()
	var b_level = GameStateManager.boat_level
	var is_broken = cur_tier.get("is_broken", false)

	# Left page: Current Status
	tier_name_label.text = "%s (Ур. %d)" % [cur_tier.get("name", "Лодка"), b_level]
	
	if is_broken:
		status_label.text = "● СЛОМАНА — ТРЕБУЕТСЯ РЕМОНТ"
		status_label.add_theme_color_override("font_color", Color(0.85, 0.2, 0.2))
	else:
		status_label.text = "● ГОТОВА К ПЛАВАНИЮ"
		status_label.add_theme_color_override("font_color", Color(0.2, 0.7, 0.2))

	desc_label.text = cur_tier.get("desc", "")

	# Clear perks
	for c in perks_container.get_children():
		c.queue_free()

	for perk in cur_tier.get("perks", []):
		var p_lbl = Label.new()
		p_lbl.text = "• " + perk
		p_lbl.add_theme_font_size_override("font_size", 10)
		p_lbl.add_theme_color_override("font_color", Color(0.25, 0.18, 0.12))
		p_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		perks_container.add_child(p_lbl)

	# Right page: Repair / Upgrade
	for c in requirements_container.get_children():
		c.queue_free()

	var cost = cur_tier.get("repair_cost", {})
	if cost.is_empty():
		# Max tier reached
		upgrade_title_label.text = "МАКСИМАЛЬНЫЙ РАНГ"
		next_tier_label.text = "Судно улучшено до предела!"
		action_button.visible = false
	else:
		if is_broken:
			upgrade_title_label.text = "РЕМОНТ КОРПУСА"
			next_tier_label.text = "Для восстановления необходимо:"
			action_button.text = "🔨 Починить лодку"
		else:
			upgrade_title_label.text = "МОДЕРНИЗАЦИЯ СУДНА"
			next_tier_label.text = "Следующий ранг: %s" % next_tier.get("name", "")
			action_button.text = "🛠 " + cur_tier.get("action_title", "Улучшить")
		
		action_button.visible = true
		var can_upgrade = true

		for item_id in cost.keys():
			var req_amount: int = cost[item_id]
			var cur_amount: int = InventoryManager.get_item_amount(item_id)
			var item_data = ItemDB.get_item(item_id)
			var item_name: String = item_data.get("name", item_id)
			
			var row = HBoxContainer.new()
			row.custom_minimum_size = Vector2(0, 20)
			
			var icon_tex = ItemDB.get_icon(item_id)
			if icon_tex:
				var icon_rect = TextureRect.new()
				icon_rect.custom_minimum_size = Vector2(16, 16)
				icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				icon_rect.texture = icon_tex
				row.add_child(icon_rect)

			var lbl = Label.new()
			lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			lbl.add_theme_font_size_override("font_size", 11)
			
			if cur_amount >= req_amount:
				lbl.text = "%s: %d/%d" % [item_name, cur_amount, req_amount]
				lbl.add_theme_color_override("font_color", Color(0.1, 0.55, 0.1))
			else:
				lbl.text = "%s: %d/%d" % [item_name, cur_amount, req_amount]
				lbl.add_theme_color_override("font_color", Color(0.75, 0.15, 0.15))
				can_upgrade = false

			row.add_child(lbl)
			requirements_container.add_child(row)

		action_button.disabled = not can_upgrade

	# Sail button visibility & state
	if is_broken:
		sail_button.visible = false
	else:
		sail_button.visible = true
		sail_button.text = "⛵ Отплыть на Сумеречный Остров"
