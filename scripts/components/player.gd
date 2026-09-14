@tool
extends CharacterBody2D
class_name Player

@export var speed: float = 40.0
@export var hairstyle_index: int = 0 # 0 to 5 for different hairs

@export_group("Editor Preview (Настройка конуса)")
@export var preview_attack_pose: bool = false: ## Включить предпросмотр удара и конуса прямо в редакторе!
	set(val):
		preview_attack_pose = val
		_apply_editor_preview()

@export_enum("Вниз (Down):0", "Вправо (Right):1", "Вверх (Up):2", "Влево (Left):3") var preview_direction: int = 0: ## Направление взмаха в предпросмотре
	set(val):
		preview_direction = val
		_apply_editor_preview()

@export_group("Combat Tuning")
@export var attack_hit_frame: int = 1: ## Кадр анимации, на котором наносится урон (0..3)
	set(val):
		attack_hit_frame = val
		_apply_editor_preview()

@export var attack_range: float = 24.0: ## Дальность атаки (радиус конуса в пикселях)
	set(val):
		attack_range = val
		_apply_editor_preview()

@export_range(30.0, 360.0, 5.0) var attack_arc_degrees: float = 110.0: ## Угол конуса атаки в градусах
	set(val):
		attack_arc_degrees = val
		_apply_editor_preview()

@export var attack_point_blank_radius: float = 8.0: ## Радиус удара в упор (даже при сильном перекрытии)
	set(val):
		attack_point_blank_radius = val
		_apply_editor_preview()

@export var attack_base_knockback: float = 180.0 ## Базовый импульс отбрасывания
@export var debug_show_attack_cone: bool = false ## Показывать ли сектор атаки визуально при взмахе в игре

var _debug_cone_timer: float = 0.0
var _attack_already_hit: Array[Node2D] = []

@onready var visuals: Node2D = $Visuals
@onready var interaction_area: Area2D = $InteractionArea
@onready var lantern_light: PointLight2D = get_node_or_null("LanternLight")

var current_target: Node2D = null
var hunger_wrapper: Control
var is_acting: bool = false
var is_dead: bool = false

# Dodge Roll state
var is_rolling: bool = false
var roll_direction: Vector2 = Vector2.ZERO
var roll_speed: float = 0.0
var roll_cooldown: float = 0.0
var _ghost_timer: float = 0.0

# Punch combo state (4-hit combo: 1=Strong, 2=Fast, 3=Fast, 4=Lunge finisher)
var punch_combo_step: int = 0
var punch_combo_timer: float = 0.0
const PUNCH_COMBO_WINDOW: float = 0.85
var current_punch_step: int = 0
var _buffered_punch: bool = false

# Sword combo state (3-hit combo: 0=Slash, 1=Reverse Slash, 2=Crosscut Finisher)
var sword_combo_step: int = 0
var sword_combo_timer: float = 0.0
const SWORD_COMBO_WINDOW: float = 0.90
var current_sword_step: int = 0
var _buffered_sword: bool = false

# Paralysis state
var is_paralyzed: bool = false
var paralysis_timer: float = 0.0

func apply_paralysis(duration: float, p_is_twilight: bool = false) -> void:
	if is_dead:
		return
	is_paralyzed = true
	paralysis_timer = max(paralysis_timer, duration)
	is_rolling = false
	is_acting = false
	ParalysisEffect.apply_to(self, duration, p_is_twilight)

# Wet status (капли воды стекают с одежды/тела)
var is_wet: bool = false
var wet_timer: float = 0.0

# Burn status (статус горения, тушится водой)
var is_burning: bool = false
var burn_timer: float = 0.0

func apply_burn(duration: float = 6.0) -> void:
	if is_dead:
		return
	var wm = get_node_or_null("/root/WeatherManager")
	if in_water or is_wet or (wm and wm.has_method("is_precipitation") and wm.is_precipitation()):
		return
	is_burning = true
	burn_timer = max(burn_timer, duration)
	BurnEffect.apply_to(self, duration)

func extinguish_burn() -> void:
	is_burning = false
	burn_timer = 0.0
	var bfx = get_node_or_null("BurnEffect") as BurnEffect
	if bfx:
		bfx.extinguish()

# Combat & Health
var knockback_velocity: Vector2 = Vector2.ZERO
var is_invulnerable: bool = false
var invulnerability_timer: float = 0.0
const I_FRAME_DURATION: float = 0.8
var attack_cooldown: float = 0.0
var _cam_shake_intensity: float = 0.0
var _cam_shake_timer: float = 0.0

@onready var camera: Camera2D = get_node_or_null("Camera2D")

const SFX_CHAR_HURT = preload("res://assets/audio/sfx/player/sfx_char_voice.mp3")
const SFX_SWORD_SWING = preload("res://assets/audio/sfx/combat/sfx_sword_swing.mp3")
const SFX_TOOL_SWISH = preload("res://assets/audio/sfx/tools/sfx_swish.mp3")
const SFX_HIT_IMPACT = preload("res://assets/audio/sfx/combat/sfx_attack.mp3")
const SFX_PLAYER_DEATH = preload("res://assets/audio/sfx/player/sfx_death.mp3")

# Combat VFX Sheets
const VFX_DASH_DUST = preload("res://assets/sprites/vfx/combat/impact_dust_dash_sheet.png")
const VFX_DUST_CLOUD = preload("res://assets/sprites/vfx/combat/impact_dust_cloud_sheet.png")
const VFX_IMPACT_HIT_1 = preload("res://assets/sprites/vfx/combat/impact_hit_1_sheet.png")
const VFX_SLASH_1 = preload("res://assets/sprites/vfx/combat/slash_1_sheet.png")
const VFX_SLASH_V2 = preload("res://assets/sprites/vfx/combat/slash_v2_sheet.png")
const VFX_SLASH_V3 = preload("res://assets/sprites/vfx/combat/slash_v3_sheet.png")
const VFX_SLASH_CROSSCUT = preload("res://assets/sprites/vfx/combat/slash_crosscut_sheet.png")

# Animation State
var current_biome: String = "clearing"
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 6.0
var _eating_cooldown: float = 0.0

# Footsteps & Surface Audio
enum SurfaceType { GRASS, STONE, DIRT, WATER }
var current_surface: SurfaceType = SurfaceType.GRASS
var in_water: bool = false
var _step_timer: float = 0.0

@onready var footsteps_player: AudioStreamPlayer = get_node_or_null("FootstepsPlayer")

const SFX_STEP_GRASS = preload("res://assets/audio/sfx/player/sfx_step_grass.mp3")
const SFX_STEP_DIRT = preload("res://assets/audio/sfx/player/sfx_step_dirt.mp3")
const SFX_STEP_STONE = preload("res://assets/audio/sfx/player/06_step_stone_1.mp3")
const SFX_STEP_WATER = preload("res://assets/audio/sfx/player/sfx_swim.mp3")

# Define paperdoll layers
const LAYERS = ["Base", "Legs", "Feet", "Chest", "Head", "Hands"]

const ANIM_MAP = {
	"idle": { "row": 0, "frames": 6 },
	"walk": { "row": 3, "frames": 6 },
	"run": { "row": 3, "frames": 6 },
	"attack": { "row": 6, "frames": 4 }, # 6 = Sword L->R, 9 = Right L->R, 12 = Up L->R
	"hurt": { "row": 15, "frames": 4 }, # Using Fall Right (15) as hurt/death for now
	"death": { "row": 15, "frames": 4 },
	"axe": { "row": 32, "frames": 6 },
	"mining": { "row": 35, "frames": 6 },
	"swimming": { "row": 3, "frames": 6 },
	"roll": { "row": 17, "frames": 8 }
}

var current_dir: int = 0 # 0=Down, 1=Right, 2=Up

func _ready() -> void:
	if not visuals:
		visuals = get_node_or_null("Visuals")

	# Set up the sprite sheets
	var tex_base = preload("res://assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
	var tex_legs = preload("res://assets/new_assets/Cute_Fantasy/Player/Legs/Farmer_Pants/Farmer_Pants_1_Blue.png")
	var tex_feet = preload("res://assets/new_assets/Cute_Fantasy/Player/Feet/Shoes_1_Brown.png")
	var tex_chest = preload("res://assets/new_assets/Cute_Fantasy/Player/Chest/Farmer_Shirt/Farmer_Shirt_1_Red.png")
	var tex_head = preload("res://assets/new_assets/Cute_Fantasy/Player/Head/Hair_1/Hair_1_Brown.png")
	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	for layer_name in LAYERS:
		var sprite = visuals.get_node_or_null(layer_name) if visuals else null
		if sprite:
			sprite.hframes = 9
			sprite.vframes = 56
			if layer_name == "Base": sprite.texture = tex_base
			if layer_name == "Legs": sprite.texture = tex_legs
			if layer_name == "Feet": sprite.texture = tex_feet
			if layer_name == "Chest": sprite.texture = tex_chest
			if layer_name == "Head": sprite.texture = tex_head
			if layer_name == "Hands": sprite.texture = tex_hands

	# Preload tools
	var tool_sprite = visuals.get_node_or_null("Tool") if visuals else null
	if tool_sprite:
		tool_sprite.visible = false

	if Engine.is_editor_hint():
		_apply_editor_preview()
		return

	if not InputMap.has_action("dodge"):
		InputMap.add_action("dodge")
		var ev_alt = InputEventKey.new()
		ev_alt.physical_keycode = KEY_ALT
		InputMap.action_add_event("dodge", ev_alt)

	if not footsteps_player:
		footsteps_player = AudioStreamPlayer.new()
		footsteps_player.name = "FootstepsPlayer"
		footsteps_player.bus = &"SFX"
		add_child(footsteps_player)

	InventoryManager.equipment_changed.connect(_update_equipment_visuals)
	InventoryManager.active_slot_changed.connect(func(_idx):
		_update_sprites()
	)
	InventoryManager.ui_slots_changed.connect(func(idx):
		if idx == InventoryManager.active_slot_index:
			_update_sprites()
	)
	_update_equipment_visuals()
	GameStateManager.item_consumed.connect(_on_item_consumed)
	GameStateManager.time_changed.connect(_on_time_of_day_changed)
	_on_time_of_day_changed(GameStateManager.current_time)

	GameStateManager.player_hurt.connect(_on_hurt)
	GameStateManager.player_died.connect(_on_died)

	# Ensure fresh state on spawn/respawn
	is_dead = false
	is_acting = false

	var cone_node = get_node_or_null("AttackConeVisualizer")
	if cone_node:
		cone_node.visible = false
	if GameStateManager.current_health <= 0:
		GameStateManager.reset_player_state()

	add_to_group("player")
	WetEffect.attach_to(self)

	if HomeStateManager and HomeStateManager.spawn_on_shore:
		HomeStateManager.spawn_on_shore = false
		call_deferred("_apply_shore_landing")

	_play_anim("idle")

func _apply_shore_landing() -> void:
	var boat = get_node_or_null("../Boat")
	if not boat:
		boat = get_tree().get_first_node_in_group("boat")
		
	if boat:
		global_position = boat.global_position + Vector2(35, 0)
	else:
		global_position = Vector2(75, 160)
		
	current_dir = 1
	if visuals:
		visuals.scale.x = 1
	_play_anim("idle")
	if ExpeditionManager:
		ExpeditionManager.post_thought("Лодка причалила к песчаному берегу Домашнего острова...", Color(0.6, 0.9, 0.75))

func _on_time_of_day_changed(time: int) -> void:
	if not lantern_light: return
	var target_energy = 0.0
	match time:
		GameStateManager.TimeOfDay.MORNING, GameStateManager.TimeOfDay.DAY:
			target_energy = 0.0
		GameStateManager.TimeOfDay.DUSK:
			target_energy = 0.08
		GameStateManager.TimeOfDay.NIGHT:
			target_energy = 0.18
			
	var tween = create_tween()
	tween.tween_property(lantern_light, "energy", target_energy, 2.0)



func take_damage(amount: float, source_pos: Vector2 = Vector2.ZERO) -> void:
	if is_dead or is_invulnerable:
		return
		
	var kb_dir = Vector2.DOWN
	if source_pos != Vector2.ZERO:
		kb_dir = (global_position - source_pos).normalized()
	if kb_dir.length_squared() < 0.001:
		kb_dir = Vector2.DOWN
	knockback_velocity = kb_dir * 135.0
	
	is_invulnerable = true
	invulnerability_timer = I_FRAME_DURATION
	
	if DialogueManager and DialogueManager.is_in_dialogue:
		DialogueManager.end_dialogue()
		if ExpeditionManager:
			ExpeditionManager.post_thought("Нападение прервало разговор!", Color(1.0, 0.4, 0.4))
	
	GameStateManager.take_damage(amount)

func _spawn_vfx(tex: Texture2D, hframes: int, pos: Vector2, rot: float = 0.0, scale_vec: Vector2 = Vector2.ONE, fps_val: float = 20.0, z_idx: int = 50, offset_vec: Vector2 = Vector2.ZERO) -> void:
	if not tex: return
	var vfx_scene = load("res://scenes/vfx/animated_vfx.tscn")
	if vfx_scene:
		var vfx = vfx_scene.instantiate() as AnimatedVFX
		vfx.global_position = pos
		vfx.setup(tex, hframes, fps_val, scale_vec, rot, Color.WHITE, z_idx, offset_vec)
		if get_tree() and get_tree().current_scene:
			get_tree().current_scene.add_child(vfx)

func _spawn_punch_hit_vfx(pos: Vector2) -> void:
	# Randomly alternate between blunt dust cloud (impact_dust_cloud_sheet) and hit impact 1 (impact_hit_1_sheet)
	if randf() < 0.5:
		_spawn_vfx(VFX_DUST_CLOUD, 7, pos, randf_range(-0.35, 0.35), Vector2(0.46, 0.46), 22.0, z_index + 1)
	else:
		_spawn_vfx(VFX_IMPACT_HIT_1, 6, pos, randf_range(-0.35, 0.35), Vector2(0.48, 0.48), 24.0, z_index + 1)

func _spawn_impact_dust(pos: Vector2, force_cloud: bool = false) -> void:
	if force_cloud or randf() < 0.5:
		_spawn_vfx(VFX_DUST_CLOUD, 7, pos, randf_range(-0.35, 0.35), Vector2(0.46, 0.46), 22.0, z_index + 1)
	else:
		var dust_scene = load("res://scenes/vfx/impact_dust.tscn")
		if dust_scene:
			var dust = dust_scene.instantiate()
			dust.global_position = pos
			if get_tree() and get_tree().current_scene:
				get_tree().current_scene.add_child(dust)

func _spawn_dash_dust(pos: Vector2, dir: Vector2) -> void:
	var angle = dir.angle()
	_spawn_vfx(VFX_DASH_DUST, 8, pos + Vector2(0, 4), angle, Vector2(0.48, 0.48), 24.0, z_index - 1, Vector2(-16, 0))

func _spawn_sword_slash(pos: Vector2, facing: Vector2, is_reverse: bool = false) -> void:
	var roll = randi() % 3
	var tex = VFX_SLASH_1
	var hf = 4
	match roll:
		0:
			tex = VFX_SLASH_1
			hf = 4
		1:
			tex = VFX_SLASH_V2
			hf = 4
		2:
			tex = VFX_SLASH_V3
			hf = 5
	var angle = facing.angle()
	var scale_y = -0.55 if is_reverse else 0.55
	_spawn_vfx(tex, hf, pos, angle, Vector2(0.55, scale_y), 24.0, z_index + 2)

func _on_hurt() -> void:
	if is_dead: return
	punch_combo_step = 0
	punch_combo_timer = 0.0
	sword_combo_step = 0
	sword_combo_timer = 0.0
	_buffered_sword = false
	if is_rolling:
		is_rolling = false
		roll_speed = 0.0
	_spawn_impact_dust(global_position + Vector2(0, -6), true)
	_flash_red()
	_play_hurt_sfx()
	shake_camera(3.5, 0.16)
	if current_anim != "attack":
		is_acting = true
		_play_anim("hurt")

func _on_died() -> void:
	is_dead = true
	is_acting = true
	is_rolling = false
	roll_speed = 0.0
	punch_combo_step = 0
	punch_combo_timer = 0.0
	sword_combo_step = 0
	sword_combo_timer = 0.0
	_buffered_sword = false
	is_paralyzed = false
	is_burning = false
	var pfx = get_node_or_null("ParalysisEffect")
	if pfx:
		pfx.queue_free()
	var bfx = get_node_or_null("BurnEffect")
	if bfx:
		bfx.queue_free()
	_play_anim("death")
	_play_death_sfx()
	shake_camera(6.0, 0.4)

func shake_camera(intensity: float = 3.5, duration: float = 0.15) -> void:
	_cam_shake_intensity = intensity
	_cam_shake_timer = duration

func _flash_red() -> void:
	for layer_name in LAYERS:
		var sprite = visuals.get_node_or_null(layer_name)
		if sprite:
			sprite.modulate = Color(2.5, 0.4, 0.4, 1.0)
			var tw = create_tween()
			tw.tween_property(sprite, "modulate", Color.WHITE, 0.22)

func _play_hurt_sfx() -> void:
	_play_temp_sfx(SFX_CHAR_HURT, -2.0, randf_range(0.95, 1.05))

func _play_death_sfx() -> void:
	_play_temp_sfx(SFX_PLAYER_DEATH, 0.0, 1.0)

func _play_attack_sfx() -> void:
	if _has_sword_equipped():
		_play_temp_sfx(SFX_SWORD_SWING, -2.0, randf_range(0.9, 1.1))
	else:
		_play_temp_sfx(SFX_TOOL_SWISH, -4.0, randf_range(1.2, 1.4))

func _play_tool_swish_sfx() -> void:
	_play_temp_sfx(SFX_TOOL_SWISH, -2.0, randf_range(0.95, 1.1))

func _play_hit_impact_sfx() -> void:
	_play_temp_sfx(SFX_HIT_IMPACT, -3.0, randf_range(0.95, 1.1))

func _play_temp_sfx(stream: AudioStream, vol_db: float = 0.0, pitch: float = 1.0) -> void:
	if not stream: return
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = stream
	sfx.volume_db = vol_db
	sfx.pitch_scale = pitch
	sfx.bus = &"SFX"
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return

	# Camera shake
	if _cam_shake_timer > 0.0:
		_cam_shake_timer -= delta
		if camera:
			camera.offset = Vector2(
				randf_range(-_cam_shake_intensity, _cam_shake_intensity),
				randf_range(-_cam_shake_intensity, _cam_shake_intensity)
			)
		if _cam_shake_timer <= 0.0 and camera:
			camera.offset = Vector2.ZERO

	# Attack cooldown
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	# I-frames processing
	if is_invulnerable:
		invulnerability_timer -= delta
		if not is_rolling:
			var blink = int(invulnerability_timer * 16.0) % 2 == 0
			visuals.modulate.a = 0.35 if blink else 1.0
		else:
			visuals.modulate.a = 1.0
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			visuals.modulate.a = 1.0


	# Decay knockback
	if knockback_velocity.length() > 0.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 520.0 * delta)

	# Decay debug cone visualizer
	if _debug_cone_timer > 0.0:
		_debug_cone_timer -= delta
		if _debug_cone_timer <= 0.0:
			_update_cone_visualizer()

	# Combo timer decay (окно между ударами комбо)
	if punch_combo_timer > 0.0:
		punch_combo_timer -= delta
		if punch_combo_timer <= 0.0:
			punch_combo_step = 0

	if not is_acting and sword_combo_timer > 0.0:
		sword_combo_timer -= delta
		if sword_combo_timer <= 0.0:
			sword_combo_step = 0

	if roll_cooldown > 0.0:
		roll_cooldown -= delta

	if is_dead:
		velocity = knockback_velocity
		move_and_slide()
		_process_animation(delta)
		return

	if is_paralyzed:
		paralysis_timer -= delta
		if paralysis_timer <= 0.0:
			is_paralyzed = false
		velocity = knockback_velocity
		move_and_slide()
		_process_animation(delta)
		return

	if is_rolling:
		if current_anim != "roll":
			_end_roll()
		else:
			roll_speed = lerp(roll_speed, 40.0, 4.0 * delta)
			velocity = roll_direction * roll_speed + knockback_velocity
			move_and_slide()
			
			# Softly nudge enemies aside if rolling past them without explosive physics
			var enemies = get_tree().get_nodes_in_group("enemies")
			for enemy in enemies:
				if is_instance_valid(enemy) and not enemy.get("is_dead"):
					var to_enemy = enemy.global_position - global_position
					var dist = to_enemy.length()
					if dist < 14.0 and dist > 0.1:
						var nudge_dir = to_enemy.normalized()
						if enemy.has_method("receive_push"):
							enemy.receive_push(nudge_dir, 35.0, delta)
						elif "knockback_velocity" in enemy:
							enemy.knockback_velocity = nudge_dir * 30.0

			_ghost_timer += delta
			if _ghost_timer >= 0.06:
				_ghost_timer = 0.0
				_spawn_ghost_trail()
			_process_animation(delta)
			return

	if is_acting:
		velocity = knockback_velocity
		move_and_slide()
		_process_animation(delta)
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# Mobile analog override
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.touch_id != -1:
		direction = mobile_controls.output_vector
		is_sprinting = direction.length() > 0.6
		
	in_water = false
	var tile_info = BiomeService.get_top_tile_info(global_position + Vector2(0, -4))
	if tile_info.layer_name != "":
		in_water = tile_info.is_water
		if tile_info.surface != BiomeService.SurfaceType.VOID:
			current_surface = tile_info.surface as SurfaceType
		if tile_info.biome != "" and tile_info.biome != "void":
			current_biome = tile_info.biome

	# Wet status handling (намокание под дождем или в воде)
	var is_raining = WeatherManager and WeatherManager.is_precipitation()
	if is_raining or in_water:
		is_wet = true
		wet_timer = 6.0
	elif wet_timer > 0.0:
		wet_timer -= delta
		if wet_timer <= 0.0:
			is_wet = false

	# Burn status handling (тушение водой при намокании или входе в воду)
	if is_burning:
		if in_water or is_wet or is_raining:
			extinguish_burn()
		else:
			burn_timer -= delta
			if burn_timer <= 0.0:
				is_burning = false

	if direction.length() > 0:
		# 0=Down, 1=Right, 2=Up
		# При диагональной ходьбе вперед (вниз) — предпочитаем боковой спрайт
		# Боковой выбирается если X значим (> половины Y), а не только если X > Y
		if direction.y >= 0 and abs(direction.x) > abs(direction.y) * 0.5:
			current_dir = 1
			visuals.scale.x = -1 if direction.x < 0 else 1
		elif abs(direction.x) > abs(direction.y) and direction.y < 0:
			# При диагонали назад — оставляем старое поведение (X > Y)
			current_dir = 1
			visuals.scale.x = -1 if direction.x < 0 else 1
		elif direction.y > 0:
			current_dir = 0
			visuals.scale.x = 1
		elif direction.y < 0:
			current_dir = 2
			visuals.scale.x = 1
			
		var move_velocity = Vector2.ZERO
		if in_water:
			move_velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted:
			GameStateManager.consume_stamina(10.0 * delta)
			move_velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			move_velocity = direction.normalized() * speed
			_play_anim("walk")
		velocity = move_velocity + knockback_velocity
	else:
		velocity = knockback_velocity
		if in_water:
			_play_anim("swimming")
		else:
			_play_anim("idle")

	_update_auto_target()
		
	if _eating_cooldown > 0.0:
		_eating_cooldown -= delta

	if Input.is_action_just_pressed("interact") and _eating_cooldown <= 0.0:
		_try_interact()

	# Stamina regeneration
	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted):
		GameStateManager.add_stamina(3.5 * delta)
		
	# Физика толкания куриц (ощущение веса и сопротивления)
	if direction.length() > 0.0:
		var chickens = get_tree().get_nodes_in_group("chickens")
		for chk in chickens:
			if is_instance_valid(chk) and chk.has_method("receive_push"):
				var to_chk = chk.global_position - global_position
				var dist = to_chk.length()
				if dist < 16.0 and direction.dot(to_chk) > 0.15:
					chk.receive_push(direction.normalized(), speed, delta)
					velocity *= 0.70
		
	move_and_slide()
	GameStateManager.update_player_position(global_position)
	_process_animation(delta)
	
	# Воспроизведение шагов в зависимости от поверхности
	var is_moving = direction.length() > 0 and not is_acting
	_process_footsteps(delta, is_moving, is_sprinting)

func _process_footsteps(delta: float, is_moving: bool, sprinting: bool) -> void:
	if not is_moving:
		_step_timer = 0.0
		return
		
	var step_interval = 0.26 if sprinting else 0.38
	_step_timer += delta
	if _step_timer >= step_interval:
		_step_timer = 0.0
		_play_footstep_sound()

func _play_footstep_sound() -> void:
	if not footsteps_player: return
	
	var stream: AudioStream = SFX_STEP_GRASS
	var vol = 6.0
	match current_surface:
		SurfaceType.WATER:
			stream = SFX_STEP_WATER
			vol = -3.0
		SurfaceType.STONE:
			stream = SFX_STEP_STONE
			vol = 6.0
		SurfaceType.DIRT:
			stream = SFX_STEP_DIRT
			vol = 4.0
		SurfaceType.GRASS:
			stream = SFX_STEP_GRASS
			vol = 7.0
			
	footsteps_player.stream = stream
	footsteps_player.volume_db = vol
	footsteps_player.pitch_scale = randf_range(0.92, 1.08)
	footsteps_player.play()

var last_played_dir: int = -1

func _play_anim(anim_name: String, force_restart: bool = false) -> void:
	if not force_restart and current_anim == anim_name and current_dir == last_played_dir:
		return
	
	if current_anim != anim_name or force_restart:
		current_frame = 0
		anim_timer = 0.0
		if anim_name != "roll" and is_rolling:
			_end_roll()
		
	current_anim = anim_name
	last_played_dir = current_dir
	
	# Immediately update sprite frame when changing animation or direction
	_update_sprites()

func _end_roll() -> void:
	if is_rolling:
		is_rolling = false
		set_collision_layer_value(1, true)
		roll_speed = 0.0
		is_acting = false
		is_invulnerable = false

func get_last_direction() -> int:
	return current_dir

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	var fps_mult = 1.0
	if current_anim == "run": fps_mult = 1.5
	elif current_anim == "roll": fps_mult = 3.0 # 18 FPS for roll
	elif current_anim == "attack":
		if not _has_sword_equipped():
			if current_punch_step in [1, 2]:
				fps_mult = 1.65 # Удары 2 и 3 заметно быстрее!
			elif current_punch_step == 3:
				fps_mult = 1.25 # Выпад вперед
			else:
				fps_mult = 1.05 # Первый сильный удар
		else:
			if current_sword_step == 2:
				fps_mult = 1.85 # 3-я атака: быстрое комбо "туда-сюда"
			else:
				fps_mult = 1.0 # Первые 2 атаки бьют в обычном темпе как раньше!
	
	anim_timer += delta
	var frame_dur = 1.0 / (fps * fps_mult)
	
	if anim_timer >= frame_dur:
		anim_timer -= frame_dur
		var frames = ANIM_MAP[current_anim]["frames"]
		current_frame += 1
		
		# Handle animation end
		if current_frame >= frames:
			if current_anim == "death":
				current_frame = frames - 1 # Зависаем на последнем кадре смерти
			elif current_anim == "roll":
				_end_roll()
				current_frame = 0
				_play_anim("idle")
			elif current_anim in ["axe", "mining", "attack", "hurt"]:
				var was_sword_attack = (current_anim == "attack" and _has_sword_equipped())
				is_acting = false
				current_frame = 0
				_play_anim("idle")
				if was_sword_attack and _buffered_sword and sword_combo_step > 0:
					_buffered_sword = false
					_perform_sword_attack()
					return
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame / events
		if current_anim == "attack":
			if current_frame in [attack_hit_frame, attack_hit_frame + 1]:
				_execute_sword_attack_hit()
				if not _has_sword_equipped() and _buffered_punch:
					_buffered_punch = false
					_perform_punch_attack()
					return
		elif current_anim in ["axe", "mining"] and current_frame == 3:
			if current_target and is_instance_valid(current_target):
				if current_target.has_method("interact"):
					current_target.interact(self)
		
		var row = ANIM_MAP[current_anim]["row"]
		# For attack (6, 9, 12), we multiply current_dir by 3.
		# For roll, row 17 is Down, 18 is Side, 19 is Up
		# For most others, it's just + current_dir
		var actual_row = row
		if current_anim == "attack":
			if _has_sword_equipped():
				var sword_sub_row = current_sword_step % 3
				actual_row = row + (current_dir * 3) + sword_sub_row
			else:
				var punch_sub_row = current_punch_step % 3
				actual_row = row + (current_dir * 3) + punch_sub_row
		elif current_anim == "roll":
			match current_dir:
				0: actual_row = 17
				1: actual_row = 18
				2: actual_row = 19
				_: actual_row = 17
		else:
			actual_row = row + current_dir
			
		_update_sprites()

func _update_sprites() -> void:
	if not visuals:
		visuals = get_node_or_null("Visuals")
	if not visuals:
		return
	if current_anim == "" or not ANIM_MAP.has(current_anim):
		return

	var row = ANIM_MAP[current_anim]["row"]
	var actual_row = row
	if current_anim == "attack":
		if _has_sword_equipped():
			var sword_sub_row = current_sword_step % 3
			actual_row = row + (current_dir * 3) + sword_sub_row
		else:
			var punch_sub_row = current_punch_step % 3
			actual_row = row + (current_dir * 3) + punch_sub_row
	elif current_anim == "roll":
		match current_dir:
			0: actual_row = 17
			1: actual_row = 18
			2: actual_row = 19
			_: actual_row = 17
	else:
		actual_row = row + current_dir
		
	for layer_name in LAYERS:
		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)
			
	var tool_sprite: Sprite2D = visuals.get_node_or_null("Tool")
	if tool_sprite:
		if current_anim == "attack":
			if _has_sword_equipped() or (Engine.is_editor_hint() and preview_attack_pose):
				tool_sprite.visible = true
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Sword.png")
				tool_sprite.hframes = 4
				tool_sprite.vframes = 9
				# Attack row in player body is 6 + (dir*3). In sword it's 0 + (dir*3).
				var sword_row = actual_row - 6
				tool_sprite.frame_coords = Vector2i(current_frame, sword_row)
			else:
				tool_sprite.visible = false
		elif current_anim in ["axe", "mining"]:
			tool_sprite.visible = true
			tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Tools.png")
			tool_sprite.hframes = 6
			tool_sprite.vframes = 12
			# Axe row in player body is 32 + dir. In tools it's 0 + dir.
			# Mining row in player body is 35 + dir. In tools it's 3 + dir.
			var tool_row = actual_row - 32
			tool_sprite.frame_coords = Vector2i(current_frame, tool_row)
		else:
			tool_sprite.visible = false

func _has_sword_equipped() -> bool:
	var active_id = InventoryManager.get_active_item_id()
	return active_id in ["sword", "stone_sword"]

func _unhandled_input(event: InputEvent) -> void:
	if Engine.is_editor_hint() or is_dead or is_paralyzed:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ALT or event.physical_keycode == KEY_ALT or event.is_action_pressed("dodge"):
			_perform_dodge()
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not PlacementManager.is_placing and _eating_cooldown <= 0.0:
			# Turn toward mouse click direction if clicking to attack
			var mouse_pos = get_global_mouse_position()
			var to_mouse = mouse_pos - global_position
			if to_mouse.length_squared() > 16.0:
				if abs(to_mouse.x) > abs(to_mouse.y) * 0.5:
					current_dir = 1
					visuals.scale.x = -1 if to_mouse.x < 0 else 1
				elif to_mouse.y > 0:
					current_dir = 0
					visuals.scale.x = 1
				elif to_mouse.y < 0:
					current_dir = 2
					visuals.scale.x = 1
			_try_interact()

func get_facing_direction() -> Vector2:
	if not visuals:
		visuals = get_node_or_null("Visuals")
	match current_dir:
		0: return Vector2.DOWN
		1: return Vector2.LEFT if (visuals and visuals.scale.x < 0) else Vector2.RIGHT
		2: return Vector2.UP
	return Vector2.DOWN

func _perform_dodge() -> void:
	if is_dead or is_rolling or in_water:
		return
	if roll_cooldown > 0.0:
		return
	if not GameStateManager.consume_stamina(12.0):
		return

	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.touch_id != -1 and mobile_controls.output_vector.length() > 0.1:
		input_dir = mobile_controls.output_vector

	if input_dir.length() > 0.1:
		roll_direction = input_dir.normalized()
		# 0=Down (Row 18), 1=Side (Row 19), 2=Up (Row 20)
		if abs(roll_direction.x) > abs(roll_direction.y) * 0.5:
			current_dir = 1
			visuals.scale.x = -1.0 if roll_direction.x < 0 else 1.0
		elif roll_direction.y > 0:
			current_dir = 0
			visuals.scale.x = 1.0
		elif roll_direction.y < 0:
			current_dir = 2
			visuals.scale.x = 1.0
	else:
		roll_direction = get_facing_direction()

	is_rolling = true
	set_collision_layer_value(1, false)
	is_acting = true
	_buffered_punch = false
	punch_combo_step = 0
	punch_combo_timer = 0.0
	_buffered_sword = false
	sword_combo_step = 0
	sword_combo_timer = 0.0
	is_invulnerable = true
	invulnerability_timer = 0.35
	roll_speed = 170.0
	roll_cooldown = 0.18
	_ghost_timer = 0.0

	_play_temp_sfx(SFX_TOOL_SWISH, -1.0, randf_range(1.25, 1.4))
	_spawn_dash_dust(global_position, roll_direction)
	_spawn_ghost_trail()
	_play_anim("roll")

func _spawn_ghost_trail() -> void:
	if not visuals: return
	var ghost = Node2D.new()
	ghost.global_position = visuals.global_position
	ghost.scale = visuals.scale
	ghost.z_index = z_index - 1
	
	for layer_name in LAYERS:
		var sp = visuals.get_node_or_null(layer_name) as Sprite2D
		if sp and sp.visible and sp.texture:
			var copy = Sprite2D.new()
			copy.texture = sp.texture
			copy.hframes = sp.hframes
			copy.vframes = sp.vframes
			copy.frame_coords = sp.frame_coords
			copy.position = sp.position
			copy.offset = sp.offset
			copy.modulate = Color(0.7, 0.9, 1.3, 0.45) # Soft ethereal glow
			ghost.add_child(copy)
			
	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(ghost)
		var tween = ghost.create_tween()
		tween.tween_property(ghost, "modulate:a", 0.0, 0.22)
		tween.tween_callback(ghost.queue_free)

func _perform_attack() -> void:
	if _has_sword_equipped():
		_perform_sword_attack()
	else:
		_perform_punch_attack()

func _perform_sword_attack() -> void:
	if attack_cooldown > 0.0 or is_acting:
		return

	var stamina_cost = 6.0
	if sword_combo_step == 2:
		stamina_cost = 8.0 # Finisher

	if not GameStateManager.consume_stamina(stamina_cost):
		return

	is_acting = true
	current_sword_step = sword_combo_step
	_attack_already_hit.clear()
	_buffered_sword = false

	var facing = get_facing_direction()
	var slash_pos = global_position + facing * 16.0 + Vector2(0, -6)

	match current_sword_step:
		0:
			# Удар 1: Обычный взмах как раньше
			attack_cooldown = 0.35
			knockback_velocity += facing * 24.0
			_play_temp_sfx(SFX_SWORD_SWING, -1.0, randf_range(0.95, 1.1))
			sword_combo_step = 1
			sword_combo_timer = SWORD_COMBO_WINDOW
		1:
			# Удар 2: Второй взмах как раньше (реверсивный)
			attack_cooldown = 0.35
			knockback_velocity += facing * 24.0
			_play_temp_sfx(SFX_SWORD_SWING, 0.0, randf_range(1.1, 1.25))
			sword_combo_step = 2
			sword_combo_timer = SWORD_COMBO_WINDOW
		2:
			# Удар 3: Быстрое комбо "туда-сюда" с перекрёстным ударом (Crosscut)
			# Меньше урона (не имба) и ТОЛЬКО В ОДНОГО ВРАГА ВПЕРЕДИ!
			attack_cooldown = 0.40
			knockback_velocity += facing * 36.0
			_play_temp_sfx(SFX_SWORD_SWING, 1.5, randf_range(1.3, 1.45))
			# Всегда показываем перекрёстный разрез при финишном комбо
			_spawn_vfx(VFX_SLASH_CROSSCUT, 5, slash_pos + facing * 4.0, 0.0, Vector2(1.2, 1.2), 16.0, z_index + 2)
			sword_combo_step = 0
			sword_combo_timer = 0.0

	_play_anim("attack", true)
	
	if debug_show_attack_cone:
		_debug_cone_timer = 0.25
		_update_cone_visualizer()

func _perform_punch_attack() -> void:
	if _has_sword_equipped():
		return

	# Если мы уже в фазе удара/восстановления (кадр >= 1) — позволяем отменить задержку и продолжить комбо
	if is_acting:
		if current_anim == "attack" and current_frame >= 1:
			is_acting = false
			attack_cooldown = 0.0
		else:
			return
			
	if attack_cooldown > 0.0:
		return

	# Расход стамины на удары кулаками (быстрые удары по 4 стамины, мощные/финишер 6-8)
	var stamina_cost = 4.0
	if punch_combo_step == 3:
		stamina_cost = 7.0
	elif punch_combo_step == 0:
		stamina_cost = 5.0

	if not GameStateManager.consume_stamina(stamina_cost):
		return

	is_acting = true
	current_punch_step = punch_combo_step
	_attack_already_hit.clear()
	_buffered_punch = false
	
	var facing = get_facing_direction()
	
	match current_punch_step:
		0:
			# Удар 1: Прямой силовой удар (1-2 урона)
			attack_cooldown = 0.25
			knockback_velocity += facing * 22.0
			_play_temp_sfx(SFX_HIT_IMPACT, -2.0, randf_range(0.95, 1.05))
		1:
			# Удар 2: Быстрый хук слева (1-2 урона)
			attack_cooldown = 0.18
			knockback_velocity += facing * 14.0
			_play_temp_sfx(preload("res://assets/audio/ui/sfx_pop.mp3"), 0.5, randf_range(1.25, 1.4))
		2:
			# Удар 3: Быстрый хук справа (1-2 урона)
			attack_cooldown = 0.18
			knockback_velocity += facing * 18.0
			_play_temp_sfx(preload("res://assets/audio/ui/sfx_pop.mp3"), 1.0, randf_range(1.35, 1.5))
		3:
			# Удар 4: Финальный выпад вперед с рывком (3-4 урона)
			attack_cooldown = 0.42
			knockback_velocity += facing * 155.0 # Мощный выпад/рывок вперед
			_spawn_impact_dust(global_position + Vector2(0, -4))
			_play_temp_sfx(SFX_SWORD_SWING, 1.2, randf_range(1.15, 1.3))
			_play_temp_sfx(SFX_HIT_IMPACT, 1.2, randf_range(0.85, 0.95))
			
	_play_anim("attack", true)
	
	# Продвигаем комбо на следующий шаг
	punch_combo_step = (punch_combo_step + 1) % 4
	punch_combo_timer = PUNCH_COMBO_WINDOW

func _get_enemy_hit_info(enemy: Node2D) -> Dictionary:
	var hurtbox = enemy.get_node_or_null("Hurtbox")
	if hurtbox:
		var cs = hurtbox.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if cs and cs.shape is CircleShape2D:
			return {
				"center": cs.global_position,
				"radius": (cs.shape as CircleShape2D).radius
			}
	var col = enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if col and col.shape is CircleShape2D:
		return {
			"center": col.global_position,
			"radius": (col.shape as CircleShape2D).radius
		}
	return {
		"center": enemy.global_position + Vector2(0, -6),
		"radius": 10.0
	}

func _execute_sword_attack_hit() -> void:
	var center = global_position + Vector2(0, -6)
	var facing = get_facing_direction()
	var has_sword = _has_sword_equipped()
	
	var base_dmg = 12
	var crit_chance = 0.20
	var base_kb = attack_base_knockback
	var shake_power = 2.2
	var is_single_target = false
	
	if has_sword:
		match current_sword_step:
			0:
				base_dmg = 12
				base_kb = 180.0
				crit_chance = 0.18
				shake_power = 2.0
				is_single_target = false
			1:
				base_dmg = 12
				base_kb = 180.0
				crit_chance = 0.18
				shake_power = 2.0
				is_single_target = false
			2:
				# Финальный перекрёстный удар:
				# Меньше урона (не имба), только в одного врага впереди!
				base_dmg = 7
				base_kb = 165.0
				crit_chance = 0.25
				shake_power = 2.4
				is_single_target = true
	else:
		match current_punch_step:
			0:
				base_dmg = 2
				base_kb = 110.0
				crit_chance = 0.10
				shake_power = 1.6
			1:
				base_dmg = 1
				base_kb = 60.0
				crit_chance = 0.10
				shake_power = 1.1
			2:
				base_dmg = 2
				base_kb = 75.0
				crit_chance = 0.10
				shake_power = 1.3
			3:
				base_dmg = 3
				base_kb = 210.0
				crit_chance = 0.25
				shake_power = 2.8
	
	var min_dot = cos(deg_to_rad(attack_arc_degrees * 0.5))
	var enemies = get_tree().get_nodes_in_group("enemies")
	var hit_count = 0
	var has_crit_hit = false

	if is_single_target:
		# Перекрёстный удар: поражает ТОЛЬКО ОДНОГО ближайшего врага прямо по курсу
		var best_enemy: Node2D = null
		var best_dist: float = INF
		var best_hit_dir: Vector2 = facing

		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.get("is_dead") == true or enemy in _attack_already_hit:
				continue
			var hit_info = _get_enemy_hit_info(enemy)
			var to_enemy = hit_info["center"] - center
			var dist = to_enemy.length()
			var effective_dist = max(0.0, dist - float(hit_info["radius"]))
			if effective_dist <= (attack_range + 6.0):
				var to_dir = to_enemy.normalized() if dist > 0.001 else facing
				if effective_dist <= attack_point_blank_radius or facing.dot(to_dir) >= min_dot:
					if dist < best_dist:
						best_dist = dist
						best_enemy = enemy
						best_hit_dir = to_dir

		if best_enemy:
			_attack_already_hit.append(best_enemy)
			hit_count += 1
			var is_crit = randf() < crit_chance
			if is_crit:
				has_crit_hit = true
			var raw_dmg = round(float(base_dmg) * randf_range(0.9, 1.15))
			if is_crit:
				raw_dmg = round(raw_dmg * 2.0)
			var dmg = int(max(1.0, raw_dmg))
			var kb_impulse = (best_hit_dir * 0.7 + facing * 0.3).normalized() * (base_kb * (1.3 if is_crit else 1.0))
			if best_enemy.has_method("take_damage"):
				best_enemy.take_damage(dmg, kb_impulse, is_crit)
			elif best_enemy.has_method("interact"):
				best_enemy.interact(self)
			# Sword combo finisher: Crosscut 2x bigger (1.2 scale) centered on hit enemy! No dust cloud.
			_spawn_vfx(VFX_SLASH_CROSSCUT, 5, best_enemy.global_position + Vector2(0, -6), 0.0, Vector2(1.2, 1.2), 24.0, z_index + 2)
	else:
		# Сплэш атака: поражает всех врагов в конусе
		for enemy in enemies:
			if not is_instance_valid(enemy) or enemy.get("is_dead") == true or enemy in _attack_already_hit:
				continue
				
			var hit_info = _get_enemy_hit_info(enemy)
			var enemy_center: Vector2 = hit_info["center"]
			var to_enemy = enemy_center - center
			var dist = to_enemy.length()
			var enemy_radius: float = hit_info["radius"]
			var effective_dist = max(0.0, dist - enemy_radius)
			
			var extra_reach = 8.0 if (not has_sword and current_punch_step == 3) else 0.0
			if effective_dist <= (attack_range + extra_reach):
				var in_arc = false
				if effective_dist <= attack_point_blank_radius:
					in_arc = true
				else:
					var to_dir = to_enemy.normalized() if dist > 0.001 else facing
					var dot = facing.dot(to_dir)
					if dot >= min_dot:
						in_arc = true
						
				if in_arc:
					_attack_already_hit.append(enemy)
					hit_count += 1
					var hit_dir = to_enemy.normalized() if dist > 1.0 else facing
					var is_crit = randf() < crit_chance
					if is_crit:
						has_crit_hit = true
					
					var dmg_variance = randf_range(0.85, 1.20)
					var raw_dmg = round(float(base_dmg) * dmg_variance)
					if is_crit:
						raw_dmg = round(raw_dmg * 2.0)
					var dmg = int(max(1.0, raw_dmg))
					
					var kb_mult = 1.35 if is_crit else 1.0
					var kb_impulse = (hit_dir * 0.7 + facing * 0.3).normalized() * (base_kb * kb_mult)
					
					if enemy.has_method("take_damage"):
						enemy.take_damage(dmg, kb_impulse, is_crit)
					elif enemy.has_method("interact"):
						enemy.interact(self)
					
					if has_sword:
						# Sword slashes only appear on enemy hit! No dust cloud.
						_spawn_sword_slash(enemy_center, facing, current_sword_step == 1)
					else:
						# Punch hits: alternate between dust cloud and impact hit 1
						_spawn_punch_hit_vfx(enemy_center)
					
	if hit_count > 0:
		if has_crit_hit:
			shake_camera(shake_power * 1.5, 0.18)
			_play_temp_sfx(SFX_HIT_IMPACT, 1.5, randf_range(1.25, 1.4))
		else:
			shake_camera(shake_power, 0.12)
			if has_sword:
				_play_hit_impact_sfx()
			else:
				if current_punch_step == 3:
					_play_temp_sfx(SFX_HIT_IMPACT, 1.2, randf_range(0.9, 1.05))
					_spawn_punch_hit_vfx(global_position + facing * 10.0)
				elif current_punch_step in [1, 2]:
					_play_temp_sfx(preload("res://assets/audio/ui/sfx_pop.mp3"), 1.0, randf_range(1.2, 1.4))
				else:
					_play_temp_sfx(SFX_HIT_IMPACT, -2.0, randf_range(1.0, 1.15))

func _update_auto_target() -> void:
	var interactables: Array[Node2D] = []
	for a in interaction_area.get_overlapping_areas(): interactables.append(a)
	for b in interaction_area.get_overlapping_bodies(): interactables.append(b)
	var closest_target = null
	var closest_dist: float = INF
	
	for node in interactables:
		if node == self: continue
		var target_candidate: Node2D = node
		if not target_candidate.has_method("interact") and target_candidate.get_parent() and target_candidate.get_parent().has_method("interact"):
			target_candidate = target_candidate.get_parent()
		if target_candidate.has_method("interact"):
			# Exclude invisible entities or enemies from auto-target and highlight
			if not target_candidate.is_visible_in_tree():
				continue
			if target_candidate.is_in_group("enemies") or target_candidate is EnemySkeleton or target_candidate is SlimeEnemy:
				continue
			var dist = global_position.distance_to(target_candidate.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = target_candidate
				
	# Reset old target modulate
	if current_target and is_instance_valid(current_target):
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color.WHITE
		
	current_target = closest_target
	
	# Highlight new target
	if current_target and is_instance_valid(current_target):
		if not current_target.get("no_highlight"):
			var sprite = current_target.get_node_or_null("Sprite2D")
			if sprite: sprite.modulate = Color(1.4, 1.4, 1.4, 1.0)

func _try_interact() -> void:
	# Если сейчас выполняется атака (мечом или кулаками) — продолжаем комбо или буферизуем ввод
	if _has_sword_equipped() and current_anim == "attack":
		if current_frame >= 1:
			_perform_sword_attack()
			return
		else:
			_buffered_sword = true
			return
	elif not _has_sword_equipped() and current_anim == "attack":
		if current_frame >= 1:
			_perform_punch_attack()
			return
		else:
			_buffered_punch = true
			return

	if attack_cooldown > 0.0 or is_acting:
		return

	# If an enemy is in melee range in front, combat takes defense priority
	var enemies = get_tree().get_nodes_in_group("enemies")
	var facing = get_facing_direction()
	var center = global_position + Vector2(0, -6)
	var enemy_in_front = false
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.get("is_dead"):
			var hit_info = _get_enemy_hit_info(enemy)
			var to_enemy: Vector2 = hit_info["center"] - center
			var dist = to_enemy.length()
			var effective_dist = max(0.0, dist - float(hit_info["radius"]))
			if effective_dist <= 34.0:
				var to_dir = to_enemy.normalized() if dist > 0.001 else facing
				if effective_dist <= 14.0 or facing.dot(to_dir) > 0.15:
					enemy_in_front = true
					break

	if enemy_in_front:
		_perform_attack()
		return

	if current_target and is_instance_valid(current_target):
		var dir_to_target = global_position.direction_to(current_target.global_position)
		if dir_to_target.x != 0:
			visuals.scale.x = -1 if dir_to_target.x < 0 else 1
			
		if current_target is Stone and current_target.has_method("is_gatherable") and current_target.is_gatherable():
			current_target.interact(self)
			return
			
		if current_target is BushObject:
			current_target.interact(self)
			return
			
		if current_target is Stone or current_target is TreeObject or current_target is FallenLog or current_target is FallenLogVertical:
			var active_tool = InventoryManager.get_active_item_id()
			var has_tool = false
			if current_target.get("resource_id") == "wood":
				if active_tool in ["axe", "stone_axe", "wooden_axe"]:
					has_tool = true
				else:
					print("Для рубки выберите топор в панели быстрого доступа!")
					return
			else:
				if active_tool in ["pickaxe", "stone_pickaxe", "wooden_pickaxe"]:
					has_tool = true
				else:
					print("Для добычи выберите кирку в панели быстрого доступа!")
					return
					
			if not has_tool:
				return
				
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target.get("resource_id") == "wood":
					_play_tool_swish_sfx()
					_play_anim("axe")
				else:
					_play_tool_swish_sfx()
					_play_anim("mining")
			return
		else:
			# Instant interact (like Boat)
			current_target.interact(self)
			return
	else:
		if InventoryManager.get_active_item_id() == "hoe":
			_use_hoe()
		else:
			_perform_attack()

func _update_equipment_visuals() -> void:
	var chest_sprite = visuals.get_node_or_null("Chest")
	var feet_sprite = visuals.get_node_or_null("Feet")
	
	if chest_sprite:
		chest_sprite.visible = (InventoryManager.equipment.get("chest", "") != "")
	if feet_sprite:
		feet_sprite.visible = (InventoryManager.equipment.get("boots", "") != "")

func _on_item_consumed(item_id: String, p_color: Color) -> void:
	_eating_cooldown = 0.35
	_play_eat_sfx()
	var particle_scene = load("res://scenes/vfx/eat_particles.tscn")
	if particle_scene:
		var inst = particle_scene.instantiate()
		if inst.has_method("setup"):
			inst.setup(item_id, p_color)
		# Set at player's head/mouth height
		inst.position = Vector2(0, -10)
		add_child(inst)

func _play_eat_sfx() -> void:
	var sfx = AudioStreamPlayer2D.new()
	sfx.stream = load("res://assets/audio/ui/sfx_pop.mp3")
	sfx.pitch_scale = randf_range(1.25, 1.45)
	sfx.volume_db = -4.0
	sfx.bus = &"SFX"
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

func _use_hoe() -> void:
	is_acting = true
	_play_tool_swish_sfx()
	_play_anim("axe")
	var timer = get_tree().create_timer(0.3)
	await timer.timeout

	var world_map = get_tree().current_scene.get_node_or_null("WorldMap")
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			# Определяем тайл перед игроком (по направлению взгляда)
			var dir_vec = Vector2.ZERO
			if current_dir == 0: dir_vec = Vector2(0, 16)
			elif current_dir == 1: dir_vec = Vector2(16, 0)
			elif current_dir == 2: dir_vec = Vector2(0, -16)
			if visuals.scale.x < 0 and current_dir == 1: dir_vec.x = -16

			var target_pos = global_position + dir_vec
			var map_pos = ground.local_to_map(target_pos)

			var ts = ground.tile_set
			if not ts:
				is_acting = false
				_play_anim("idle")
				return

			# Ищем ID terrain-а FarmLand
			var farmland_id = -1
			for i in range(ts.get_terrains_count(0)):
				if ts.get_terrain_name(0, i) == "FarmLand":
					farmland_id = i
					break

			if farmland_id == -1:
				is_acting = false
				_play_anim("idle")
				return

			# Проверяем что тайл — трава (terrain_set 0, terrain 0/6/7/8)
			# Terrain 0 = Базовая трава, 6 = Лесная, 7 = Сухая, 8 = Волшебная
			const GRASS_TERRAIN_IDS := [0, 6, 7, 8]
			var cell_data = ground.get_cell_tile_data(map_pos)
			var is_grass = false
			if cell_data:
				var t_set = cell_data.terrain_set
				var t_id  = cell_data.terrain
				if t_set == 0 and t_id in GRASS_TERRAIN_IDS:
					is_grass = true

			if is_grass:
				# Вспахиваем — заменяем тайл на FarmLand с автосвязью terrain
				ground.set_cells_terrain_connect([map_pos], 0, farmland_id)
				# Пыль от вспашки
				_spawn_impact_dust(ground.map_to_local(map_pos) + world_map.global_position, true)
			else:
				# Нельзя тяпать — нет травы
				print("[Hoe] Нельзя вспахать — здесь нет травы.")

	is_acting = false
	_play_anim("idle")

func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		if what == NOTIFICATION_EDITOR_PRE_SAVE:
			if preview_attack_pose:
				preview_attack_pose = false
				_apply_editor_preview()

func _update_cone_visualizer() -> void:
	var cone_node = get_node_or_null("AttackConeVisualizer") as Polygon2D
	if not cone_node:
		cone_node = Polygon2D.new()
		cone_node.name = "AttackConeVisualizer"
		cone_node.color = Color(1.0, 0.8, 0.2, 0.4)
		cone_node.z_index = 10
		add_child(cone_node)
		
	var facing = get_facing_direction()
	var base_angle = facing.angle()
	var half_angle = deg_to_rad(attack_arc_degrees * 0.5)
	var center_offset = Vector2(0, -6)
	
	var points = PackedVector2Array([center_offset])
	var segments = 24
	for i in range(segments + 1):
		var a = base_angle - half_angle + (half_angle * 2.0 * i / float(segments))
		points.append(center_offset + Vector2(cos(a), sin(a)) * attack_range)
	points.append(center_offset)
	cone_node.polygon = points
	
	var line = cone_node.get_node_or_null("Border") as Line2D
	if not line:
		line = Line2D.new()
		line.name = "Border"
		line.width = 1.5
		line.default_color = Color(1.0, 0.3, 0.1, 0.9)
		cone_node.add_child(line)
	line.points = points
	
	var pb_circle = cone_node.get_node_or_null("PointBlank") as Line2D
	if not pb_circle:
		pb_circle = Line2D.new()
		pb_circle.name = "PointBlank"
		pb_circle.width = 1.0
		pb_circle.default_color = Color(1.0, 0.2, 0.2, 0.6)
		cone_node.add_child(pb_circle)
	var pb_pts = PackedVector2Array()
	for i in range(17):
		var a = i * (TAU / 16.0)
		pb_pts.append(center_offset + Vector2(cos(a), sin(a)) * attack_point_blank_radius)
	pb_circle.points = pb_pts
	
	if Engine.is_editor_hint():
		cone_node.visible = preview_attack_pose
	else:
		cone_node.visible = (debug_show_attack_cone and _debug_cone_timer > 0.0)

func _apply_editor_preview() -> void:
	if not Engine.is_editor_hint():
		return
	if not visuals:
		visuals = get_node_or_null("Visuals")
	if not visuals:
		return
		
	var tool_sprite: Sprite2D = visuals.get_node_or_null("Tool")
	
	if not preview_attack_pose:
		current_anim = "idle"
		current_dir = 0
		current_frame = 0
		visuals.scale.x = 1.0
		if tool_sprite:
			tool_sprite.visible = false
		_update_sprites()
		_update_cone_visualizer()
		return

	# Show attack pose
	current_anim = "attack"
	current_frame = attack_hit_frame
	
	if preview_direction == 3: # Left
		current_dir = 1
		visuals.scale.x = -1.0
	else:
		current_dir = preview_direction
		visuals.scale.x = 1.0
		
	_update_sprites()
	_update_cone_visualizer()
