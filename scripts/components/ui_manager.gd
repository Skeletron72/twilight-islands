extends CanvasLayer

@onready var time_icon: TextureRect = $TimeContainer/TimeIcon
@onready var time_label: Label = $TimeContainer/TimeLabel
@onready var day_label: Label = $TimeContainer/DayLabel
@onready var book_ui = $BookUI
@onready var book_btn: TextureButton = $BookToggleContainer/BookToggleBtn
@onready var book_key_lbl: Label = $BookToggleContainer/KeyLabel

var health_container: HBoxContainer
var health_bar: ProgressBar
var health_label: Label
var heart_icon: TextureRect

var stamina_container: HBoxContainer
var stamina_bar: ProgressBar
var stamina_label: Label
var stamina_icon: TextureRect
var stamina_fill_style: StyleBoxFlat

func _ready() -> void:
	show()
	_setup_stats_hud()
	GameStateManager.time_changed.connect(_on_time_changed)
	GameStateManager.day_changed.connect(_on_day_changed)
	GameStateManager.player_died.connect(_on_player_died)
	

	
	_init_time_textures()
	_update_time_text()
	_init_book_textures()
	_update_book_btn_textures()
	book_ui.visibility_changed.connect(_update_book_btn_textures)
	
	if book_btn:
		book_btn.pressed.connect(func():
			if book_ui.visible:
				book_ui.close()
			else:
				book_ui.open()
		)
		
	if book_key_lbl:
		var events = InputMap.action_get_events("inventory")
		if events.size() > 0:
			var event = events[0]
			if event is InputEventKey:
				var key_name = OS.get_keycode_string(event.physical_keycode)
				if key_name == "": key_name = OS.get_keycode_string(event.keycode)
				book_key_lbl.text = "[" + key_name + "]"
			else:
				book_key_lbl.text = "[Tab]"
		else:
			book_key_lbl.text = "[Tab]"


func _on_time_changed(new_time: int) -> void:
	_update_time_text()

func _on_day_changed(new_day: int) -> void:
	_update_time_text()

func _update_time_text() -> void:
	var time_str = ""
	var icon_tex = null
	match GameStateManager.current_time:
		GameStateManager.TimeOfDay.MORNING:
			time_str = "Утро"
			icon_tex = tex_morning
		GameStateManager.TimeOfDay.DAY:
			time_str = "День"
			icon_tex = tex_day
		GameStateManager.TimeOfDay.DUSK:
			time_str = "Вечер"
			icon_tex = tex_evening
		GameStateManager.TimeOfDay.NIGHT:
			time_str = "Ночь"
			icon_tex = tex_night
	
	if time_label: time_label.text = time_str
	if time_icon: time_icon.texture = icon_tex
	if day_label: day_label.text = "День %d" % GameStateManager.current_day

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"): # Press Space to advance time for testing
		GameStateManager.advance_time()

func _on_player_died() -> void:
	print("Player died! Lost raid loot.")
	
	# Ждем 2 секунды, чтобы проигралась анимация смерти
	await get_tree().create_timer(2.0).timeout
	
	InventoryManager.clear_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	# Reset stats for next run
	GameStateManager.current_health = GameStateManager.max_health
	GameStateManager.current_stamina = GameStateManager.max_stamina
	var tm = get_node_or_null("/root/TransitionManager")
	if tm:
		tm.transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")
	else:
		get_tree().change_scene_to_file("res://scenes/levels/home_island.tscn")


var ui_tex = preload("res://assets/sprites/ui/inventory/UI.png")
var tex_closed: AtlasTexture
var tex_closed_hover: AtlasTexture
var tex_open: AtlasTexture
var tex_open_hover: AtlasTexture
var tex_morning: AtlasTexture
var tex_day: AtlasTexture
var tex_evening: AtlasTexture
var tex_night: AtlasTexture

func _init_time_textures() -> void:
	tex_morning = AtlasTexture.new()
	tex_morning.atlas = ui_tex
	tex_morning.region = Rect2(1056, 16, 48, 48)
	
	tex_day = AtlasTexture.new()
	tex_day.atlas = ui_tex
	tex_day.region = Rect2(1104, 16, 48, 48)
	
	tex_evening = AtlasTexture.new()
	tex_evening.atlas = ui_tex
	tex_evening.region = Rect2(1056, 64, 48, 48)
	
	tex_night = AtlasTexture.new()
	tex_night.atlas = ui_tex
	tex_night.region = Rect2(1104, 64, 48, 48)

func _init_book_textures() -> void:
	tex_closed = AtlasTexture.new()
	tex_closed.atlas = ui_tex
	tex_closed.region = Rect2(928, 256, 16, 16)
	
	tex_closed_hover = AtlasTexture.new()
	tex_closed_hover.atlas = ui_tex
	tex_closed_hover.region = Rect2(992, 256, 16, 16)
	
	tex_open = AtlasTexture.new()
	tex_open.atlas = ui_tex
	tex_open.region = Rect2(944, 256, 16, 16)
	
	tex_open_hover = AtlasTexture.new()
	tex_open_hover.atlas = ui_tex
	tex_open_hover.region = Rect2(1008, 256, 16, 16)

func _update_book_btn_textures() -> void:
	if not book_btn: return
	if book_ui.visible:
		book_btn.texture_normal = tex_open
		book_btn.texture_hover = tex_open_hover
	else:
		book_btn.texture_normal = tex_closed
		book_btn.texture_hover = tex_closed_hover

func _setup_stats_hud() -> void:
	# --- HEALTH BAR ---
	health_container = HBoxContainer.new()
	health_container.name = "HealthContainer"
	health_container.position = Vector2(70, 18)
	health_container.custom_minimum_size = Vector2(130, 16)
	health_container.add_theme_constant_override("separation", 6)
	health_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	heart_icon = TextureRect.new()
	heart_icon.name = "HeartIcon"
	heart_icon.custom_minimum_size = Vector2(16, 16)
	heart_icon.pivot_offset = Vector2(8, 8)
	heart_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	heart_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var heart_tex = AtlasTexture.new()
	heart_tex.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
	heart_tex.region = Rect2(0, 0, 16, 16)
	heart_icon.texture = heart_tex
	health_container.add_child(heart_icon)
	
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.custom_minimum_size = Vector2(64, 7)
	health_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	health_bar.show_percentage = false
	
	var hp_bg = StyleBoxFlat.new()
	hp_bg.anti_aliasing = false
	hp_bg.bg_color = Color(0.1, 0.1, 0.12, 0.9)
	hp_bg.border_width_left = 1; hp_bg.border_width_top = 1; hp_bg.border_width_right = 1; hp_bg.border_width_bottom = 1
	hp_bg.border_color = Color(0.02, 0.02, 0.02, 1.0)
	
	var hp_fill = StyleBoxFlat.new()
	hp_fill.anti_aliasing = false
	hp_fill.bg_color = Color(0.9, 0.18, 0.22, 1.0)
	hp_fill.border_width_left = 1; hp_fill.border_width_top = 1; hp_fill.border_width_right = 1; hp_fill.border_width_bottom = 1
	hp_fill.border_color = Color(0, 0, 0, 0)
	
	health_bar.add_theme_stylebox_override("background", hp_bg)
	health_bar.add_theme_stylebox_override("fill", hp_fill)
	health_bar.max_value = GameStateManager.max_health
	health_bar.value = GameStateManager.current_health
	health_container.add_child(health_bar)
	
	health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var lbl_settings = LabelSettings.new()
	lbl_settings.font = preload("res://assets/fonts/WarmPixel.ttf")
	lbl_settings.font_size = 11
	lbl_settings.font_color = Color(1, 1, 1, 1)
	lbl_settings.outline_size = 3
	lbl_settings.outline_color = Color(0, 0, 0, 1)
	health_label.label_settings = lbl_settings
	health_label.text = "%d/%d" % [int(ceil(GameStateManager.current_health)), int(GameStateManager.max_health)]
	health_container.add_child(health_label)
	
	add_child(health_container)
	GameStateManager.health_changed.connect(_on_health_changed)
	GameStateManager.player_hurt.connect(_on_player_hurt_hud)

	# --- STAMINA BAR ---
	stamina_container = HBoxContainer.new()
	stamina_container.name = "StaminaContainer"
	stamina_container.position = Vector2(70, 36)
	stamina_container.custom_minimum_size = Vector2(130, 16)
	stamina_container.add_theme_constant_override("separation", 6)
	stamina_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	stamina_icon = TextureRect.new()
	stamina_icon.name = "StaminaIcon"
	stamina_icon.custom_minimum_size = Vector2(16, 16)
	stamina_icon.pivot_offset = Vector2(8, 8)
	stamina_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stamina_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sta_tex = AtlasTexture.new()
	sta_tex.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
	sta_tex.region = Rect2(144, 0, 16, 16)
	stamina_icon.texture = sta_tex
	stamina_container.add_child(stamina_icon)
	
	stamina_bar = ProgressBar.new()
	stamina_bar.name = "StaminaBar"
	stamina_bar.custom_minimum_size = Vector2(64, 7)
	stamina_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stamina_bar.show_percentage = false
	
	var sta_bg = StyleBoxFlat.new()
	sta_bg.anti_aliasing = false
	sta_bg.bg_color = Color(0.1, 0.1, 0.12, 0.9)
	sta_bg.border_width_left = 1; sta_bg.border_width_top = 1; sta_bg.border_width_right = 1; sta_bg.border_width_bottom = 1
	sta_bg.border_color = Color(0.02, 0.02, 0.02, 1.0)
	
	stamina_fill_style = StyleBoxFlat.new()
	stamina_fill_style.anti_aliasing = false
	stamina_fill_style.bg_color = Color(0.2, 0.85, 0.35, 1.0)
	stamina_fill_style.border_width_left = 1; stamina_fill_style.border_width_top = 1; stamina_fill_style.border_width_right = 1; stamina_fill_style.border_width_bottom = 1
	stamina_fill_style.border_color = Color(0, 0, 0, 0)
	
	stamina_bar.add_theme_stylebox_override("background", sta_bg)
	stamina_bar.add_theme_stylebox_override("fill", stamina_fill_style)
	stamina_bar.max_value = GameStateManager.max_stamina
	stamina_bar.value = GameStateManager.current_stamina
	stamina_container.add_child(stamina_bar)
	
	stamina_label = Label.new()
	stamina_label.name = "StaminaLabel"
	stamina_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	var sta_lbl_settings = LabelSettings.new()
	sta_lbl_settings.font = preload("res://assets/fonts/WarmPixel.ttf")
	sta_lbl_settings.font_size = 11
	sta_lbl_settings.font_color = Color(1, 1, 1, 1)
	sta_lbl_settings.outline_size = 3
	sta_lbl_settings.outline_color = Color(0, 0, 0, 1)
	stamina_label.label_settings = sta_lbl_settings
	stamina_label.text = "%d/%d" % [int(ceil(GameStateManager.current_stamina)), int(GameStateManager.max_stamina)]
	stamina_container.add_child(stamina_label)
	
	add_child(stamina_container)
	GameStateManager.stamina_changed.connect(_on_stamina_changed_hud)

func _on_health_changed(new_val: float, max_val: float) -> void:
	if health_bar:
		health_bar.max_value = max_val
		var tw = create_tween()
		tw.tween_property(health_bar, "value", new_val, 0.2)
	if health_label:
		health_label.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]
	if heart_icon:
		var tw_h = create_tween()
		tw_h.tween_property(heart_icon, "scale", Vector2(1.3, 1.3), 0.08)
		tw_h.tween_property(heart_icon, "scale", Vector2(1.0, 1.0), 0.12)

func _on_player_hurt_hud() -> void:
	if health_container:
		var tw = create_tween()
		tw.tween_property(health_container, "position:x", 67.0, 0.03)
		tw.tween_property(health_container, "position:x", 73.0, 0.04)
		tw.tween_property(health_container, "position:x", 70.0, 0.03)

func _on_stamina_changed_hud(new_val: float, max_val: float) -> void:
	if stamina_bar:
		stamina_bar.max_value = max_val
		var tw = create_tween()
		tw.tween_property(stamina_bar, "value", new_val, 0.12)
	if stamina_label:
		stamina_label.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]
	if stamina_fill_style:
		if GameStateManager.is_exhausted:
			stamina_fill_style.bg_color = Color(0.92, 0.35, 0.2, 1.0)
			if stamina_container:
				var tw_s = create_tween()
				tw_s.tween_property(stamina_container, "position:x", 67.0, 0.03)
				tw_s.tween_property(stamina_container, "position:x", 73.0, 0.04)
				tw_s.tween_property(stamina_container, "position:x", 70.0, 0.03)
		else:
			stamina_fill_style.bg_color = Color(0.2, 0.85, 0.35, 1.0)
	if stamina_icon:
		var tw_i = create_tween()
		tw_i.tween_property(stamina_icon, "scale", Vector2(1.2, 1.2), 0.06)
		tw_i.tween_property(stamina_icon, "scale", Vector2(1.0, 1.0), 0.1)
