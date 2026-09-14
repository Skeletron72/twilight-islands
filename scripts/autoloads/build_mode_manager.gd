extends Node2D

var is_building: bool = false
var building_type: String = ""
var current_orientation: int = 0 # 0=South, 1=East, 2=North, 3=West
var is_valid_location: bool = false
var current_snapped_pos: Vector2 = Vector2.ZERO

var _freecam: Camera2D = null
var _original_cam: Camera2D = null
var _player_ref: Node2D = null
var _target_zoom: Vector2 = Vector2(1.8, 1.8)

# UI Elements
var _hud_layer: CanvasLayer = null
var _status_label: Label = null
var _top_panel: PanelContainer = null
var _bottom_panel: PanelContainer = null

# Ghost Visuals
var _ghost_root: Node2D = null
var _ghost_house: Sprite2D = null
var _ghost_pier: Sprite2D = null

const SFX_CRAFT = preload("res://assets/audio/sfx/player/sfx_craft.mp3")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 4000
	_setup_ghost_preview()
	_setup_hud()

func _setup_ghost_preview() -> void:
	_ghost_root = Node2D.new()
	_ghost_root.name = "BuildGhost"
	_ghost_root.visible = false
	_ghost_root.z_index = 4000
	add_child(_ghost_root)

	var house_tex = preload("res://assets/new_assets/Cute_Fantasy/Buildings/Buildings/Houses/Wood/House_1_Wood_Base_Blue.png")
	_ghost_house = Sprite2D.new()
	_ghost_house.texture = house_tex
	_ghost_house.offset = Vector2(0, -56)
	_ghost_house.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ghost_root.add_child(_ghost_house)

	var bridge_tex = preload("res://assets/new_assets/Cute_Fantasy/Tiles/Bridge/Bridge_Wood_1.png")
	_ghost_pier = Sprite2D.new()
	_ghost_pier.texture = bridge_tex
	_ghost_pier.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_ghost_root.add_child(_ghost_pier)

	_update_ghost_orientation()

func _update_ghost_orientation() -> void:
	if not _ghost_pier: return
	match current_orientation:
		0: # South
			_ghost_pier.position = Vector2(0, 42)
			_ghost_pier.rotation_degrees = 90
		1: # East
			_ghost_pier.position = Vector2(48, 8)
			_ghost_pier.rotation_degrees = 0
		2: # North
			_ghost_pier.position = Vector2(0, -68)
			_ghost_pier.rotation_degrees = 90
		3: # West
			_ghost_pier.position = Vector2(-48, 8)
			_ghost_pier.rotation_degrees = 0

func _setup_hud() -> void:
	_hud_layer = CanvasLayer.new()
	_hud_layer.layer = 120
	add_child(_hud_layer)

	# Root control
	var root_ctrl = Control.new()
	root_ctrl.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_ctrl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_hud_layer.add_child(root_ctrl)

	# Top banner
	_top_panel = PanelContainer.new()
	_top_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_top_panel.offset_top = 10
	_top_panel.offset_left = 60
	_top_panel.offset_right = -60
	_top_panel.offset_bottom = 44
	_top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(_top_panel)

	var top_style = StyleBoxFlat.new()
	top_style.bg_color = Color(0.08, 0.07, 0.12, 0.85)
	top_style.border_color = Color(0.9, 0.8, 0.4, 0.9)
	top_style.set_border_width_all(1)
	top_style.corner_radius_top_left = 6
	top_style.corner_radius_top_right = 6
	top_style.corner_radius_bottom_left = 6
	top_style.corner_radius_bottom_right = 6
	_top_panel.add_theme_stylebox_override("panel", top_style)

	var top_label = Label.new()
	top_label.text = "⚓ РЕЖИМ СВОБОДНОГО СТРОИТЕЛЬСТВА: КОРАБЕЛЬНАЯ МАСТЕРСКАЯ"
	top_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	top_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.5))
	top_label.add_theme_color_override("font_outline_color", Color.BLACK)
	top_label.add_theme_constant_override("outline_size", 2)
	top_label.add_theme_font_size_override("font_size", 11)
	_top_panel.add_child(top_label)

	# Bottom bar
	_bottom_panel = PanelContainer.new()
	_bottom_panel.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_bottom_panel.offset_top = -68
	_bottom_panel.offset_left = 20
	_bottom_panel.offset_right = -20
	_bottom_panel.offset_bottom = -10
	_bottom_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_ctrl.add_child(_bottom_panel)

	var bot_style = StyleBoxFlat.new()
	bot_style.bg_color = Color(0.06, 0.05, 0.09, 0.9)
	bot_style.border_color = Color(0.7, 0.65, 0.5, 0.7)
	bot_style.set_border_width_all(1)
	bot_style.corner_radius_top_left = 6
	bot_style.corner_radius_top_right = 6
	bot_style.corner_radius_bottom_left = 6
	bot_style.corner_radius_bottom_right = 6
	_bottom_panel.add_theme_stylebox_override("panel", bot_style)

	var bot_vbox = VBoxContainer.new()
	bot_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	_bottom_panel.add_child(bot_vbox)

	_status_label = Label.new()
	_status_label.text = "[!] Наведите курсор на побережье (причал должен быть в воде)"
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4))
	_status_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_status_label.add_theme_constant_override("outline_size", 2)
	_status_label.add_theme_font_size_override("font_size", 10)
	bot_vbox.add_child(_status_label)

	var hints_label = Label.new()
	hints_label.text = "[W][A][S][D] / Стрелки — Полет камеры | [Shift] — Ускорить | [Колесико] — Зум | [R] — Повернуть | [ЛКМ] — Построить | [Esc] — Отмена"
	hints_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hints_label.add_theme_color_override("font_color", Color(0.8, 0.82, 0.85))
	hints_label.add_theme_color_override("font_outline_color", Color.BLACK)
	hints_label.add_theme_constant_override("outline_size", 2)
	hints_label.add_theme_font_size_override("font_size", 9)
	bot_vbox.add_child(hints_label)

	_hud_layer.visible = false

func start_freecam_build(p_building_type: String = "shipwright_workshop") -> void:
	if is_building: return
	building_type = p_building_type
	is_building = true
	current_orientation = 0
	_update_ghost_orientation()

	# Find player and camera
	_player_ref = get_tree().get_first_node_in_group("player")
	if _player_ref:
		_player_ref.set_physics_process(false)
		if "is_acting" in _player_ref:
			_player_ref.is_acting = true
		_original_cam = _player_ref.get_node_or_null("Camera2D") as Camera2D

	# Create dedicated FreeCam
	if not _freecam:
		_freecam = Camera2D.new()
		_freecam.name = "BuildModeFreeCam"
		get_tree().current_scene.add_child(_freecam)

	if _player_ref:
		_freecam.global_position = _player_ref.global_position
	elif _original_cam:
		_freecam.global_position = _original_cam.global_position
	else:
		_freecam.global_position = Vector2(200, 200)

	_freecam.zoom = Vector2(1.8, 1.8)
	_target_zoom = Vector2(1.8, 1.8)
	_freecam.make_current()

	_ghost_root.visible = true
	_hud_layer.visible = true

func cancel_freecam_build() -> void:
	if not is_building: return
	is_building = false
	_ghost_root.visible = false
	_hud_layer.visible = false

	# Restore original camera
	if _original_cam and is_instance_valid(_original_cam):
		_original_cam.make_current()

	# Restore player control
	if _player_ref and is_instance_valid(_player_ref):
		_player_ref.set_physics_process(true)
		if "is_acting" in _player_ref:
			_player_ref.is_acting = false

	if ExpeditionManager:
		ExpeditionManager.post_thought("Строительство отложено. Вы можете выбрать место в диалоге с Финном в любой момент.", Color(0.85, 0.85, 0.85))

func confirm_placement() -> void:
	if not is_building or not is_valid_location:
		return

	var place_pos = current_snapped_pos
	var place_rot = current_orientation

	# 1. Update persistent state: start construction
	HomeStateManager.workshop_built = true
	HomeStateManager.workshop_under_construction = true
	HomeStateManager.workshop_start_day = GameStateManager.current_day if GameStateManager else 1
	HomeStateManager.workshop_pos = place_pos
	HomeStateManager.workshop_orientation = place_rot
	HomeStateManager.workshop_level = 1

	# 2. Instantiate workshop scene in construction mode
	var workshop_scene = load("res://scenes/objects/buildings/shipwright_workshop.tscn") as PackedScene
	if workshop_scene:
		var ws = workshop_scene.instantiate() as ShipwrightWorkshop
		ws.global_position = place_pos
		ws.setup_orientation(place_rot)
		ws.set_under_construction(true)
		get_tree().current_scene.add_child(ws)

	# 3. Raft stays at the beach so the player can continue sailing on expeditions!
	# (HomeStateManager.get_workshop_boat_pos() returns beach (40, 160) while under construction)

	# 4. Move Finn to workshop site to work on construction
	var finn = get_tree().get_first_node_in_group("allies")
	if not finn:
		finn = get_tree().current_scene.get_node_or_null("NpcShipwright")
	if finn:
		finn.global_position = HomeStateManager.get_workshop_npc_pos()
		if "home_origin" in finn:
			finn.home_origin = finn.global_position
		if finn.has_method("_play_anim"):
			finn._play_anim("work_active")

	# 5. Play sound and particles
	_play_build_sound()
	_spawn_build_dust(place_pos)

	# 6. Complete build mode
	is_building = false
	_ghost_root.visible = false
	_hud_layer.visible = false

	if _original_cam and is_instance_valid(_original_cam):
		_original_cam.make_current()

	if _player_ref and is_instance_valid(_player_ref):
		_player_ref.set_physics_process(true)
		if "is_acting" in _player_ref:
			_player_ref.is_acting = false

	if ExpeditionManager:
		ExpeditionManager.post_thought("Финн: «Ох-х, закладываю верфь! У меня уйдёт пара дней на работу. Плот ждёт тебя на пляже — плыви в экспедиции!»", Color(1.0, 0.88, 0.45))

func _play_build_sound() -> void:
	if SFX_CRAFT:
		var sfx = AudioStreamPlayer.new()
		sfx.stream = SFX_CRAFT
		sfx.volume_db = 2.0
		sfx.bus = "SFX"
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

func _spawn_build_dust(pos: Vector2) -> void:
	var dust_scene = load("res://scenes/vfx/impact_dust.tscn")
	if dust_scene:
		for offset in [Vector2(-20, 0), Vector2(20, 0), Vector2(0, 20), Vector2(0, -20)]:
			var d = dust_scene.instantiate()
			d.global_position = pos + offset
			get_tree().current_scene.add_child(d)

func _process(delta: float) -> void:
	if not is_building: return

	_process_camera(delta)
	_process_ghost_and_validation()

func _process_camera(delta: float) -> void:
	if not _freecam: return

	# Movement
	var move_dir = Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move_dir.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move_dir.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move_dir.x += 1.0

	if move_dir != Vector2.ZERO:
		var spd = 280.0
		if Input.is_key_pressed(KEY_SHIFT):
			spd = 520.0
		_freecam.global_position += move_dir.normalized() * spd * delta
		# Clamp within bounds
		_freecam.global_position.x = clampf(_freecam.global_position.x, -250.0, 1200.0)
		_freecam.global_position.y = clampf(_freecam.global_position.y, -250.0, 1000.0)

	# Smooth Zoom
	_freecam.zoom = _freecam.zoom.lerp(_target_zoom, 10.0 * delta)

func _process_ghost_and_validation() -> void:
	if not _freecam or not _ghost_root: return

	var mouse_world = _freecam.get_global_mouse_position()
	current_snapped_pos = Vector2(round(mouse_world.x / 16.0) * 16.0, round(mouse_world.y / 16.0) * 16.0)
	_ghost_root.global_position = current_snapped_pos

	# Validate location
	is_valid_location = _check_workshop_location(current_snapped_pos, current_orientation)

	if is_valid_location:
		_ghost_root.modulate = Color(0.4, 1.0, 0.4, 0.8)
		if _status_label:
			_status_label.text = "[✓] Место идеально подходит! Нажмите [ЛКМ], чтобы возвести верфь"
			_status_label.add_theme_color_override("font_color", Color(0.4, 1.0, 0.5))
	else:
		_ghost_root.modulate = Color(1.0, 0.35, 0.35, 0.8)
		if _status_label:
			_status_label.text = "[✕] Причал должен быть в воде, а мастерская — на суше!"
			_status_label.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

func _check_workshop_location(base_pos: Vector2, rot: int) -> bool:
	# 1. House Footprint (must be on land, not water, not void)
	var house_samples = [
		base_pos + Vector2(-32, -24),
		base_pos + Vector2(0, -24),
		base_pos + Vector2(32, -24),
		base_pos + Vector2(-32, -8),
		base_pos + Vector2(0, -8),
		base_pos + Vector2(32, -8)
	]

	for pt in house_samples:
		var info = BiomeService.get_top_tile_info(pt)
		if info["is_water"] == true:
			return false
		if info["layer_name"] == "" or info["biome"] == "void":
			return false

	# 2. Pier Footprint (must be in water)
	var pier_samples: Array[Vector2] = []
	match rot:
		0: # South
			pier_samples = [base_pos + Vector2(0, 24), base_pos + Vector2(0, 42), base_pos + Vector2(0, 58)]
		1: # East
			pier_samples = [base_pos + Vector2(32, 8), base_pos + Vector2(52, 8), base_pos + Vector2(68, 8)]
		2: # North
			pier_samples = [base_pos + Vector2(0, -50), base_pos + Vector2(0, -68), base_pos + Vector2(0, -84)]
		3: # West
			pier_samples = [base_pos + Vector2(-32, 8), base_pos + Vector2(-52, 8), base_pos + Vector2(-68, 8)]

	var water_count = 0
	for pt in pier_samples:
		var info = BiomeService.get_top_tile_info(pt)
		if info["is_water"] == true:
			water_count += 1

	# Require at least 2 of 3 pier sample points to be directly in water
	return water_count >= 2

func _unhandled_input(event: InputEvent) -> void:
	if not is_building: return

	# Rotation
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			current_orientation = (current_orientation + 1) % 4
			_update_ghost_orientation()
			get_viewport().set_input_as_handled()
			return
		elif event.keycode == KEY_ESCAPE:
			cancel_freecam_build()
			get_viewport().set_input_as_handled()
			return

	# Mouse wheel zoom
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_zoom = (_target_zoom + Vector2(0.2, 0.2)).clamp(Vector2(1.0, 1.0), Vector2(2.5, 2.5))
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_zoom = (_target_zoom - Vector2(0.2, 0.2)).clamp(Vector2(1.0, 1.0), Vector2(2.5, 2.5))
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_LEFT:
			if is_valid_location:
				confirm_placement()
			else:
				if ExpeditionManager:
					ExpeditionManager.post_thought("Здесь нельзя построить верфь: причал должен быть в воде, а мастерская — на берегу!", Color(1.0, 0.5, 0.5))
			get_viewport().set_input_as_handled()
			return
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			cancel_freecam_build()
			get_viewport().set_input_as_handled()
			return
