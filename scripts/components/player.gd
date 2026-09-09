extends CharacterBody2D
class_name Player

@export var speed: float = 40.0
@export var hairstyle_index: int = 0 # 0 to 5 for different hairs

@onready var visuals: Node2D = $Visuals
@onready var interaction_area: Area2D = $InteractionArea
@onready var lantern_light: PointLight2D = get_node_or_null("LanternLight")

var current_target: Node2D = null
var hunger_wrapper: Control
var is_acting: bool = false
var is_dead: bool = false

# Combat & Health
var hp_bar: ProgressBar
var hp_bar_hide_timer: float = 0.0

# Overhead Stamina Bar
var stamina_bar: ProgressBar
var stamina_bar_hide_timer: float = 0.0
var stamina_fill_style: StyleBoxFlat
var _stamina_shake_tween: Tween
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
const SFX_HIT_IMPACT = preload("res://assets/audio/sfx/combat/sfx_attack.mp3")
const SFX_PLAYER_DEATH = preload("res://assets/audio/sfx/player/sfx_death.mp3")

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
	"swimming": { "row": 3, "frames": 6 }
}

var current_dir: int = 0 # 0=Down, 1=Right, 2=Up

func _ready() -> void:
	if not footsteps_player:
		footsteps_player = AudioStreamPlayer.new()
		footsteps_player.name = "FootstepsPlayer"
		footsteps_player.bus = &"SFX"
		add_child(footsteps_player)
	# Set up the sprite sheets
	var tex_base = preload("res://assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
	var tex_legs = preload("res://assets/new_assets/Cute_Fantasy/Player/Legs/Farmer_Pants/Farmer_Pants_1_Blue.png")
	var tex_feet = preload("res://assets/new_assets/Cute_Fantasy/Player/Feet/Shoes_1_Brown.png")
	var tex_chest = preload("res://assets/new_assets/Cute_Fantasy/Player/Chest/Farmer_Shirt/Farmer_Shirt_1_Red.png")
	var tex_head = preload("res://assets/new_assets/Cute_Fantasy/Player/Head/Hair_1/Hair_1_Brown.png")
	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	# Preload tools
	var tool_sprite = visuals.get_node_or_null("Tool")
	if tool_sprite:
		tool_sprite.visible = false
	
	for layer_name in LAYERS:
		var sprite = visuals.get_node_or_null(layer_name)
		if sprite:
			sprite.hframes = 9
			sprite.vframes = 56
			if layer_name == "Base": sprite.texture = tex_base
			if layer_name == "Legs": sprite.texture = tex_legs
			if layer_name == "Feet": sprite.texture = tex_feet
			if layer_name == "Chest": sprite.texture = tex_chest
			if layer_name == "Head": sprite.texture = tex_head
			if layer_name == "Hands": sprite.texture = tex_hands

	InventoryManager.equipment_changed.connect(_update_equipment_visuals)
	_update_equipment_visuals()
	GameStateManager.item_consumed.connect(_on_item_consumed)
	GameStateManager.time_changed.connect(_on_time_of_day_changed)
	_on_time_of_day_changed(GameStateManager.current_time)

	_setup_overhead_hp()
	_setup_overhead_stamina()
	GameStateManager.health_changed.connect(_on_health_changed)
	GameStateManager.stamina_changed.connect(_on_stamina_changed)
	GameStateManager.player_hurt.connect(_on_hurt)
	GameStateManager.player_died.connect(_on_died)

	add_to_group("player")

	_play_anim("idle")

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

func _setup_overhead_hp() -> void:
	hp_bar = ProgressBar.new()
	hp_bar.name = "PlayerHPBar"
	hp_bar.position = Vector2(-15, -28)
	hp_bar.custom_minimum_size = Vector2(30, 4)
	hp_bar.show_percentage = false
	hp_bar.z_index = 200
	hp_bar.z_as_relative = false
	
	var hp_bg = StyleBoxFlat.new()
	hp_bg.anti_aliasing = false
	hp_bg.bg_color = Color(0.1, 0.1, 0.12, 0.85)
	hp_bg.border_width_left = 1; hp_bg.border_width_top = 1; hp_bg.border_width_right = 1; hp_bg.border_width_bottom = 1
	hp_bg.border_color = Color(0.02, 0.02, 0.02, 1.0)
	
	var hp_fill = StyleBoxFlat.new()
	hp_fill.anti_aliasing = false
	hp_fill.bg_color = Color(0.9, 0.18, 0.2, 1.0)
	hp_fill.border_width_left = 1; hp_fill.border_width_top = 1; hp_fill.border_width_right = 1; hp_fill.border_width_bottom = 1
	hp_fill.border_color = Color(0, 0, 0, 0)
	
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	hp_bar.max_value = GameStateManager.max_health
	hp_bar.value = GameStateManager.current_health
	hp_bar.modulate.a = 1.0 if GameStateManager.current_health < GameStateManager.max_health else 0.0
	add_child(hp_bar)

func _on_health_changed(curr: float, max_val: float) -> void:
	if not hp_bar: return
	hp_bar.max_value = max_val
	hp_bar.value = curr
	if curr < max_val:
		hp_bar.modulate.a = 1.0
		hp_bar_hide_timer = 3.5
	else:
		hp_bar_hide_timer = 1.5

func _show_overhead_hp() -> void:
	if hp_bar:
		hp_bar.modulate.a = 1.0
		hp_bar_hide_timer = 3.5

func _setup_overhead_stamina() -> void:
	stamina_bar = ProgressBar.new()
	stamina_bar.name = "PlayerStaminaBar"
	stamina_bar.position = Vector2(-15, -23)
	stamina_bar.custom_minimum_size = Vector2(30, 3)
	stamina_bar.show_percentage = false
	stamina_bar.z_index = 200
	stamina_bar.z_as_relative = false
	
	var bg = StyleBoxFlat.new()
	bg.anti_aliasing = false
	bg.bg_color = Color(0.1, 0.1, 0.12, 0.85)
	bg.border_width_left = 1; bg.border_width_top = 1; bg.border_width_right = 1; bg.border_width_bottom = 1
	bg.border_color = Color(0.02, 0.02, 0.02, 1.0)
	
	stamina_fill_style = StyleBoxFlat.new()
	stamina_fill_style.anti_aliasing = false
	stamina_fill_style.bg_color = Color(0.2, 0.85, 0.35, 1.0)
	stamina_fill_style.border_width_left = 1; stamina_fill_style.border_width_top = 1; stamina_fill_style.border_width_right = 1; stamina_fill_style.border_width_bottom = 1
	stamina_fill_style.border_color = Color(0, 0, 0, 0)
	
	stamina_bar.add_theme_stylebox_override("background", bg)
	stamina_bar.add_theme_stylebox_override("fill", stamina_fill_style)
	stamina_bar.max_value = GameStateManager.max_stamina
	stamina_bar.value = GameStateManager.current_stamina
	stamina_bar.modulate.a = 1.0 if GameStateManager.current_stamina < GameStateManager.max_stamina else 0.0
	add_child(stamina_bar)

func _on_stamina_changed(curr: float, max_val: float) -> void:
	if not stamina_bar: return
	stamina_bar.max_value = max_val
	stamina_bar.value = curr
	
	if curr < max_val:
		stamina_bar.modulate.a = 1.0
		stamina_bar_hide_timer = 1.8
	else:
		stamina_bar_hide_timer = 1.0
		
	if GameStateManager.is_exhausted:
		stamina_fill_style.bg_color = Color(0.92, 0.3, 0.2, 1.0)
		_start_stamina_shake()
	else:
		stamina_fill_style.bg_color = Color(0.2, 0.85, 0.35, 1.0)
		_stop_stamina_shake()

func _start_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid() and _stamina_shake_tween.is_running():
		return
	_stamina_shake_tween = create_tween()
	_stamina_shake_tween.set_loops()
	_stamina_shake_tween.tween_property(stamina_bar, "position:x", -13.5, 0.04)
	_stamina_shake_tween.tween_property(stamina_bar, "position:x", -16.5, 0.04)
	_stamina_shake_tween.tween_property(stamina_bar, "position:x", -15.0, 0.04)

func _stop_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid():
		_stamina_shake_tween.kill()
	if stamina_bar:
		stamina_bar.position.x = -15.0

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
	
	GameStateManager.take_damage(amount)

func _on_hurt() -> void:
	if is_dead: return
	_flash_red()
	_play_hurt_sfx()
	shake_camera(3.5, 0.16)
	_show_overhead_hp()
	if current_anim != "attack":
		is_acting = true
		_play_anim("hurt")

func _on_died() -> void:
	is_dead = true
	is_acting = true
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
	_play_temp_sfx(SFX_SWORD_SWING, -2.0, randf_range(0.9, 1.1))

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
		var blink = int(invulnerability_timer * 16.0) % 2 == 0
		visuals.modulate.a = 0.35 if blink else 1.0
		if invulnerability_timer <= 0.0:
			is_invulnerable = false
			visuals.modulate.a = 1.0

	# Overhead HP bar fadeout
	if hp_bar and hp_bar.modulate.a > 0.0:
		if GameStateManager.current_health >= GameStateManager.max_health:
			hp_bar_hide_timer -= delta
			if hp_bar_hide_timer <= 0.0:
				hp_bar.modulate.a = move_toward(hp_bar.modulate.a, 0.0, 2.0 * delta)

	# Overhead Stamina bar fadeout
	if stamina_bar and stamina_bar.modulate.a > 0.0:
		if GameStateManager.current_stamina >= GameStateManager.max_stamina:
			stamina_bar_hide_timer -= delta
			if stamina_bar_hide_timer <= 0.0:
				stamina_bar.modulate.a = move_toward(stamina_bar.modulate.a, 0.0, 2.0 * delta)

	# Decay knockback
	if knockback_velocity.length() > 0.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 520.0 * delta)

	if is_dead:
		velocity = knockback_velocity
		move_and_slide()
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
		
	var in_water = false
	var tile_info = BiomeService.get_top_tile_info(global_position + Vector2(0, -4))
	if tile_info.layer_name != "":
		in_water = tile_info.is_water
		if tile_info.surface != BiomeService.SurfaceType.VOID:
			current_surface = tile_info.surface as SurfaceType
		if tile_info.biome != "" and tile_info.biome != "void":
			current_biome = tile_info.biome

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

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_dir == last_played_dir:
		return
	
	if current_anim != anim_name:
		current_frame = 0
		anim_timer = 0.0
		
	current_anim = anim_name
	last_played_dir = current_dir
	
	# Immediately update sprite frame when changing animation or direction
	_update_sprites()

func get_last_direction() -> int:
	return current_dir

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	var fps_mult = 1.0
	if current_anim == "run": fps_mult = 1.5
	
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
			elif current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame
		var hit_frame = 2 if current_anim == "attack" else 3
		if current_anim in ["axe", "mining", "attack"] and current_frame == hit_frame:
			if current_target and is_instance_valid(current_target):
				if current_target.has_method("interact"):
					current_target.interact(self)
				if current_anim == "attack":
					shake_camera(2.0, 0.1)
					_play_hit_impact_sfx()
		
		var row = ANIM_MAP[current_anim]["row"]
		# For attack (6, 9, 12), we multiply current_dir by 3.
		# For most others, it's just + current_dir
		var actual_row = row
		if current_anim == "attack":
			actual_row = row + (current_dir * 3)
		else:
			actual_row = row + current_dir
			
		_update_sprites()

func _update_sprites() -> void:
	var row = ANIM_MAP[current_anim]["row"]
	var actual_row = row
	if current_anim == "attack":
		actual_row = row + (current_dir * 3)
	else:
		actual_row = row + current_dir
		
	for layer_name in LAYERS:
		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)
			
	var tool_sprite: Sprite2D = visuals.get_node_or_null("Tool")
	if tool_sprite:
		if current_anim in ["attack", "axe", "mining"]:
			tool_sprite.visible = true
			if current_anim == "attack":
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Sword.png")
				tool_sprite.hframes = 4
				tool_sprite.vframes = 9
				# Attack row in player body is 6 + (dir*3). In sword it's 0 + (dir*3).
				var sword_row = actual_row - 6
				tool_sprite.frame_coords = Vector2i(current_frame, sword_row)
			elif current_anim in ["axe", "mining"]:
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Tools.png")
				tool_sprite.hframes = 6
				tool_sprite.vframes = 12
				# Axe row in player body is 32 + dir. In tools it's 0 + dir.
				# Mining row in player body is 35 + dir. In tools it's 3 + dir.
				var tool_row = actual_row - 32
				tool_sprite.frame_coords = Vector2i(current_frame, tool_row)
		else:
			tool_sprite.visible = false

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
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color(1.4, 1.4, 1.4, 1.0)

func _try_interact() -> void:
	if attack_cooldown > 0.0:
		return

	if current_target:
		var dir_to_target = global_position.direction_to(current_target.global_position)
		if dir_to_target.x != 0:
			visuals.scale.x = -1 if dir_to_target.x < 0 else 1
			
		if current_target is Stone and current_target.has_method("is_gatherable") and current_target.is_gatherable():
			current_target.interact(self)
			return
			
		if current_target is BushObject:
			current_target.interact(self)
			return
			
		if current_target is Stone or current_target is EnemySkeleton or current_target is TreeObject or current_target is FallenLog or current_target is FallenLogVertical:
			var has_tool = false
			
			if current_target is EnemySkeleton:
				# Player can fight with sword, tools, or bare hands
				has_tool = true
			elif current_target.get("resource_id") == "wood":
				if InventoryManager.get_item_amount("stone_axe") > 0 or InventoryManager.get_item_amount("wooden_axe") > 0:
					has_tool = true
			else:
				if InventoryManager.get_item_amount("stone_pickaxe") > 0 or InventoryManager.get_item_amount("wooden_pickaxe") > 0:
					has_tool = true
					
			if not has_tool:
				print("Необходим инструмент для этого действия!")
				return
				
			var stamina_cost = 10.0 if current_target is EnemySkeleton else 15.0
			if GameStateManager.consume_stamina(stamina_cost) or current_target is EnemySkeleton:
				is_acting = true
				if current_target is EnemySkeleton:
					attack_cooldown = 0.38
					_play_attack_sfx()
					_play_anim("attack")
					# Micro forward lunge toward enemy
					var lunge = (current_target.global_position - global_position).normalized() * 32.0
					knockback_velocity += lunge
				elif current_target.get("resource_id") == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass
		else:
			# Instant interact (like Boat)
			current_target.interact(self)
	else:
		pass

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
# trigger cache rebuild

func _use_hoe() -> void:
	is_acting = true
	_play_anim("axe")
	var timer = get_tree().create_timer(0.3)
	await timer.timeout
	
	var world_map = get_tree().current_scene.get_node_or_null("WorldMap")
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			var dir_vec = Vector2.ZERO
			if current_dir == 0: dir_vec = Vector2(0, 16)
			elif current_dir == 1: dir_vec = Vector2(16, 0)
			elif current_dir == 2: dir_vec = Vector2(0, -16)
			if visuals.scale.x < 0 and current_dir == 1: dir_vec.x = -16
			
			var target_pos = global_position + dir_vec
			var map_pos = ground.local_to_map(target_pos)
			
			var ts = ground.tile_set
			var farmland_id = -1
			if ts:
				for i in range(ts.get_terrains_count(0)):
					if ts.get_terrain_name(0, i) == "FarmLand":
						farmland_id = i
						break
						
			if farmland_id != -1:
				var cell_data = ground.get_cell_tile_data(map_pos)
				if cell_data and cell_data.get_custom_data("can_hoe") == true:
					ground.set_cells_terrain_connect([map_pos], 0, farmland_id)
				else:
					print("Здесь нельзя копать! Нужна земля.")
				
	is_acting = false
	_play_anim("idle")
