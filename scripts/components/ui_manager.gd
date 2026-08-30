extends CanvasLayer

@onready var time_icon: TextureRect = $TimeContainer/TimeIcon
@onready var time_label: Label = $TimeContainer/TimeLabel
@onready var day_label: Label = $TimeContainer/DayLabel
@onready var book_ui = $BookUI
@onready var book_btn: TextureButton = $BookToggleContainer/BookToggleBtn
@onready var book_key_lbl: Label = $BookToggleContainer/KeyLabel

func _ready() -> void:

	

	show()
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
