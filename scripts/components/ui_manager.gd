extends CanvasLayer

@onready var time_icon: TextureRect = $TimeIcon
@onready var time_label: Label = $TimeContainer/TimeLabel
@onready var day_label: Label = $TimeContainer/DayLabel
@onready var weather_label: Label = $TimeContainer/WeatherLabel
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
var stamina_fill_style: StyleBoxTexture
var _stamina_shake_tween: Tween

var hunger_container: HBoxContainer
var hunger_bar: ProgressBar
var hunger_label: Label
var hunger_icon: TextureRect
var hunger_fill_style: StyleBoxTexture

const UI_BARS_TEX = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Bars.png")

static func create_player_bar_bg() -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	sb.texture = UI_BARS_TEX
	sb.region_rect = Rect2(82, 33, 12, 6)
	sb.texture_margin_left = 1.0
	sb.texture_margin_right = 1.0
	sb.texture_margin_top = 1.0
	sb.texture_margin_bottom = 1.0
	sb.content_margin_left = 1.0
	sb.content_margin_right = 1.0
	sb.content_margin_top = 1.0
	sb.content_margin_bottom = 1.0
	return sb

static func create_player_bar_fill(tint: Color) -> StyleBoxTexture:
	var sb = StyleBoxTexture.new()
	sb.texture = UI_BARS_TEX
	sb.region_rect = Rect2(83, 42, 10, 4)
	sb.texture_margin_left = 1.0
	sb.texture_margin_right = 1.0
	sb.texture_margin_top = 1.0
	sb.texture_margin_bottom = 1.0
	sb.content_margin_left = -1.0
	sb.content_margin_right = -1.0
	sb.content_margin_top = -1.0
	sb.content_margin_bottom = -1.0
	sb.modulate_color = tint
	return sb

func _ready() -> void:
	show()
	_setup_stats_hud()
	GameStateManager.time_changed.connect(_on_time_changed)
	GameStateManager.day_changed.connect(_on_day_changed)
	if GameStateManager.has_signal("clock_ticked"):
		GameStateManager.clock_ticked.connect(_on_clock_ticked)
	if GameStateManager.has_signal("day_of_week_changed"):
		GameStateManager.day_of_week_changed.connect(func(_dname, _idx): _update_time_text())
	if WeatherManager:
		WeatherManager.weather_changed.connect(func(_w, _info): _update_time_text())
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

func _on_clock_ticked(_h: int, _m: int) -> void:
	if time_label:
		time_label.text = GameStateManager.get_time_of_day_name()

func _on_time_changed(_new_time: int) -> void:
	_update_time_text()

func _on_day_changed(_new_day: int) -> void:
	_update_time_text()

func _update_time_text() -> void:
	var icon_tex = null
	match GameStateManager.current_time:
		GameStateManager.TimeOfDay.MORNING:
			icon_tex = tex_morning
		GameStateManager.TimeOfDay.DAY:
			icon_tex = tex_day
		GameStateManager.TimeOfDay.DUSK:
			icon_tex = tex_evening
		GameStateManager.TimeOfDay.NIGHT:
			icon_tex = tex_night
	
	if time_icon: time_icon.texture = icon_tex
	if time_label:
		time_label.text = GameStateManager.get_time_of_day_name()
	if day_label:
		day_label.text = "%s, День %d" % [GameStateManager.get_day_of_week(), GameStateManager.current_day]
	if weather_label and WeatherManager:
		weather_label.text = "Погода: %s" % WeatherManager.get_weather_name()
		weather_label.add_theme_color_override("font_color", WeatherManager.get_ui_color())

func _process(_delta: float) -> void:
	pass

func _on_player_died() -> void:
	print("Player died! Lost raid loot.")
	
	# Ждем 2 секунды, чтобы проигралась анимация смерти
	await get_tree().create_timer(2.0).timeout
	
	InventoryManager.clear_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	# Reset stats and exhaustion for next run
	GameStateManager.reset_player_state()
	if DungeonManager:
		DungeonManager.spawn_at_ladder_down = false
	if AudioManager:
		AudioManager.set_interior(false)
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
	var font_res = preload("res://assets/fonts/WarmPixel.ttf")

	# --- HEALTH BAR ---
	health_container = HBoxContainer.new()
	health_container.name = "HealthContainer"
	health_container.position = Vector2(70, 16)
	health_container.custom_minimum_size = Vector2(130, 16)
	health_container.add_theme_constant_override("separation", 6)
	health_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	heart_icon = TextureRect.new()
	heart_icon.name = "HeartIcon"
	heart_icon.custom_minimum_size = Vector2(12, 12)
	heart_icon.pivot_offset = Vector2(6, 6)
	heart_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	heart_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var heart_tex = AtlasTexture.new()
	heart_tex.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
	heart_tex.region = Rect2(0, 0, 16, 16)
	heart_icon.texture = heart_tex
	health_container.add_child(heart_icon)
	
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	health_bar.custom_minimum_size = Vector2(64, 6)
	health_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	health_bar.show_percentage = false
	health_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	health_bar.add_theme_stylebox_override("background", create_player_bar_bg())
	health_bar.add_theme_stylebox_override("fill", create_player_bar_fill(Color(0.92, 0.20, 0.22, 1.0)))
	health_bar.max_value = GameStateManager.max_health
	health_bar.value = GameStateManager.current_health
	health_container.add_child(health_bar)
	
	add_child(health_container)
	GameStateManager.health_changed.connect(_on_health_changed)
	GameStateManager.player_hurt.connect(_on_player_hurt_hud)

	# --- STAMINA BAR ---
	stamina_container = HBoxContainer.new()
	stamina_container.name = "StaminaContainer"
	stamina_container.position = Vector2(70, 28)
	stamina_container.custom_minimum_size = Vector2(130, 16)
	stamina_container.add_theme_constant_override("separation", 6)
	stamina_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	stamina_icon = TextureRect.new()
	stamina_icon.name = "StaminaIcon"
	stamina_icon.custom_minimum_size = Vector2(12, 12)
	stamina_icon.pivot_offset = Vector2(6, 6)
	stamina_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	stamina_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var st_tex = AtlasTexture.new()
	st_tex.atlas = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
	st_tex.region = Rect2(144, 0, 16, 16)
	stamina_icon.texture = st_tex
	stamina_container.add_child(stamina_icon)
	
	stamina_bar = ProgressBar.new()
	stamina_bar.name = "StaminaBar"
	stamina_bar.custom_minimum_size = Vector2(64, 6)
	stamina_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	stamina_bar.show_percentage = false
	stamina_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	stamina_fill_style = create_player_bar_fill(Color(0.25, 0.85, 0.35, 1.0))
	stamina_bar.add_theme_stylebox_override("background", create_player_bar_bg())
	stamina_bar.add_theme_stylebox_override("fill", stamina_fill_style)
	stamina_bar.max_value = GameStateManager.max_stamina
	stamina_bar.value = GameStateManager.current_stamina
	stamina_container.add_child(stamina_bar)
	
	add_child(stamina_container)
	GameStateManager.stamina_changed.connect(_on_stamina_changed_hud)
	GameStateManager.stamina_depleted.connect(_on_stamina_depleted_hud)

	# --- HUNGER BAR ---
	hunger_container = HBoxContainer.new()
	hunger_container.name = "HungerContainer"
	hunger_container.position = Vector2(70, 40)
	hunger_container.custom_minimum_size = Vector2(130, 16)
	hunger_container.add_theme_constant_override("separation", 6)
	hunger_container.alignment = BoxContainer.ALIGNMENT_BEGIN
	
	hunger_icon = TextureRect.new()
	hunger_icon.name = "HungerIcon"
	hunger_icon.custom_minimum_size = Vector2(12, 12)
	hunger_icon.pivot_offset = Vector2(6, 6)
	hunger_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	hunger_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var hg_tex = AtlasTexture.new()
	hg_tex.atlas = preload("res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png")
	hg_tex.region = Rect2(0, 16, 16, 16)
	hunger_icon.texture = hg_tex
	hunger_container.add_child(hunger_icon)
	
	hunger_bar = ProgressBar.new()
	hunger_bar.name = "HungerBar"
	hunger_bar.custom_minimum_size = Vector2(64, 6)
	hunger_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hunger_bar.show_percentage = false
	hunger_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	hunger_fill_style = create_player_bar_fill(Color(0.95, 0.62, 0.18, 1.0))
	hunger_bar.add_theme_stylebox_override("background", create_player_bar_bg())
	hunger_bar.add_theme_stylebox_override("fill", hunger_fill_style)
	hunger_bar.max_value = GameStateManager.max_hunger
	hunger_bar.value = GameStateManager.current_hunger
	hunger_container.add_child(hunger_bar)
	
	add_child(hunger_container)
	GameStateManager.hunger_changed.connect(_on_hunger_changed_hud)

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

func _on_stamina_changed_hud(new_val: float, max_val: float) -> void:
	if stamina_bar:
		stamina_bar.max_value = max_val
		var tw = create_tween()
		tw.tween_property(stamina_bar, "value", new_val, 0.1)
	if stamina_label:
		stamina_label.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]
	if stamina_fill_style:
		if GameStateManager.is_exhausted:
			stamina_fill_style.modulate_color = Color(0.92, 0.3, 0.2, 1.0)
			_start_stamina_shake()
		else:
			stamina_fill_style.modulate_color = Color(0.25, 0.85, 0.35, 1.0)
			_stop_stamina_shake()
	if stamina_icon:
		var tw_s = create_tween()
		tw_s.tween_property(stamina_icon, "scale", Vector2(1.2, 1.2), 0.06)
		tw_s.tween_property(stamina_icon, "scale", Vector2(1.0, 1.0), 0.1)

func _start_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid() and _stamina_shake_tween.is_running():
		return
	if not stamina_container: return
	_stamina_shake_tween = create_tween()
	_stamina_shake_tween.set_loops()
	_stamina_shake_tween.tween_property(stamina_container, "position:x", 67.0, 0.04)
	_stamina_shake_tween.tween_property(stamina_container, "position:x", 73.0, 0.04)
	_stamina_shake_tween.tween_property(stamina_container, "position:x", 70.0, 0.04)

func _stop_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid():
		_stamina_shake_tween.kill()
	if stamina_container:
		stamina_container.position.x = 70.0

func _on_stamina_depleted_hud() -> void:
	if stamina_container:
		var tw = create_tween()
		tw.tween_property(stamina_container, "position:x", 66.0, 0.04)
		tw.tween_property(stamina_container, "position:x", 74.0, 0.04)
		tw.tween_property(stamina_container, "position:x", 67.0, 0.04)
		tw.tween_property(stamina_container, "position:x", 73.0, 0.04)
		tw.tween_property(stamina_container, "position:x", 70.0, 0.04)
	if stamina_fill_style and not GameStateManager.is_exhausted:
		stamina_fill_style.modulate_color = Color(0.92, 0.3, 0.2, 1.0)
		var t = get_tree().create_timer(0.3)
		t.timeout.connect(func():
			if not GameStateManager.is_exhausted and stamina_fill_style:
				stamina_fill_style.modulate_color = Color(0.25, 0.85, 0.35, 1.0)
		)

func _on_player_hurt_hud() -> void:
	if health_container:
		var tw = create_tween()
		tw.tween_property(health_container, "position:x", 67.0, 0.03)
		tw.tween_property(health_container, "position:x", 73.0, 0.04)
		tw.tween_property(health_container, "position:x", 70.0, 0.03)

func _on_hunger_changed_hud(new_val: float, max_val: float) -> void:
	if hunger_bar:
		hunger_bar.max_value = max_val
		var tw = create_tween()
		tw.tween_property(hunger_bar, "value", new_val, 0.15)
	if hunger_label:
		hunger_label.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]
	if hunger_fill_style:
		if new_val <= 20.0:
			# Предупреждающий цвет при сильном голоде
			hunger_fill_style.modulate_color = Color(0.9, 0.25, 0.2, 1.0)
		elif new_val <= 50.0:
			hunger_fill_style.modulate_color = Color(0.95, 0.55, 0.15, 1.0)
		else:
			hunger_fill_style.modulate_color = Color(0.95, 0.65, 0.18, 1.0)
	if hunger_icon:
		var tw_i = create_tween()
		tw_i.tween_property(hunger_icon, "scale", Vector2(1.2, 1.2), 0.06)
		tw_i.tween_property(hunger_icon, "scale", Vector2(1.0, 1.0), 0.1)
