extends Interactable
class_name BushObject

@export var bush_type: String = "berry_bush" # "berry_bush", "plain_bush", "desert_fern"
@export var berry_type: String = "none"       # "none", "red", "purple"
@export var has_berries: bool = false
@export var bush_size: int = 0               # 0=Large, 1=Medium, 2=Small2, 3=Small1, -1=Random
@export var max_hp: int = 2
@export var drop_item_id: String = "stick"
@export var drop_amount_min: int = 1
@export var drop_amount_max: int = 2
@export var regrows_berries: bool = true
@export var regrowth_time_sec: float = 180.0

var current_hp: int = 2
var is_dead: bool = false
var _is_rustling: bool = false
var _rustle_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sfx: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

var overlapping_characters: Array[Node2D] = []

# Текстуры для лесных и ягодных кустов
const OUTDOOR_DECOR_TEX = "res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor.png"
const BERRIES_TEX = "res://assets/new_assets/Cute_Fantasy/Crops/Berries.png"

const EMPTY_BUSH_REGIONS = [
	Rect2(48, 144, 16, 16),  # Большой куст
	Rect2(80, 144, 16, 16),  # Средний куст
	Rect2(96, 144, 16, 16),  # Маленький куст 2
	Rect2(112, 144, 16, 16), # Маленький куст 1
]

func _ready() -> void:
	super._ready()
	add_to_group("interactable")
	y_sort_enabled = true
	collision_layer = 2
	collision_mask = 1
	monitoring = true
	monitorable = true
	
	var current_scene = get_tree().current_scene
	var is_home = (current_scene and current_scene.name == "HomeIsland")
	if is_home and HomeStateManager and HomeStateManager.is_destroyed(get_path()):
		queue_free()
		return
	
	current_hp = max_hp
	
	if bush_size < 0:
		bush_size = randi() % 4
	elif bush_size > 3:
		bush_size = 0
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	_update_visuals()

func _update_visuals() -> void:
	if has_berries and berry_type != "none":
		prompt_text = "Собрать ягоды"
	else:
		prompt_text = "Собрать ветки"
		
	if not sprite: return
	
	# Если это пустынный папоротник со своей текстурой — не трогаем
	if "fern" in bush_type or name.to_lower().contains("fern") or (sprite.texture and "fern" in sprite.texture.resource_path.to_lower()):
		return
		
	var atlas = AtlasTexture.new()
	if has_berries and berry_type != "none":
		atlas.atlas = load(BERRIES_TEX)
		var col_x = 0.0 if berry_type == "red" else 32.0
		var row_y = float(bush_size * 16)
		atlas.region = Rect2(col_x, row_y, 16, 16)
	else:
		atlas.atlas = load(OUTDOOR_DECOR_TEX)
		var idx = clamp(bush_size, 0, 3)
		atlas.region = EMPTY_BUSH_REGIONS[idx]
		
	sprite.texture = atlas
	sprite.offset = Vector2(0, -8)
	
	var light = get_node_or_null("PointLight2D")
	if light:
		light.visible = (has_berries and berry_type == "purple")

func _physics_process(delta: float) -> void:
	if is_dead: return
	
	if _rustle_cooldown > 0.0:
		_rustle_cooldown -= delta
		
	# Пока персонаж движется сквозь куст — куст покачивается
	if _rustle_cooldown <= 0.0 and not overlapping_characters.is_empty():
		for ch in overlapping_characters:
			if is_instance_valid(ch):
				var speed = 0.0
				var move_x = 0.0
				if "velocity" in ch:
					speed = ch.velocity.length()
					move_x = ch.velocity.x
				elif "direction" in ch:
					speed = ch.direction.length() * 100.0
					move_x = ch.direction.x
					
				if speed > 8.0:
					_trigger_rustle(move_x)
					break

func _on_body_entered(body: Node2D) -> void:
	if is_dead: return
	if body.is_in_group("player") or body is CharacterBody2D:
		if not overlapping_characters.has(body):
			overlapping_characters.append(body)
		
		var move_x = body.velocity.x if "velocity" in body else 0.0
		if abs(move_x) < 0.1:
			move_x = body.global_position.x - global_position.x
		_trigger_rustle(move_x)

func _on_body_exited(body: Node2D) -> void:
	overlapping_characters.erase(body)

func _trigger_rustle(move_dir_x: float) -> void:
	if is_dead or _is_rustling: return
	_is_rustling = true
	_rustle_cooldown = 0.25
	
	_play_sfx(randf_range(0.9, 1.15))
	_spawn_leaf_particles(randi_range(1, 3), 15.0)
	
	# Наклон в сторону движения с отскоком
	var lean_dir = 1.0 if move_dir_x >= 0 else -1.0
	var tween = create_tween()
	tween.tween_property(sprite, "rotation", lean_dir * 0.2, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "rotation", -lean_dir * 0.12, 0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "rotation", lean_dir * 0.06, 0.06).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "rotation", 0.0, 0.06).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): _is_rustling = false)

func interact(player: Node2D) -> void:
	if is_dead: return
	
	# Если на кусте есть спелые ягоды — собираем ягоды!
	if has_berries and berry_type != "none":
		_harvest_berries()
		return
		
	# Если ягод нет — собираем куст руками на ветки!
	_gather_bush(player)

func _harvest_berries() -> void:
	has_berries = false
	GameStateManager.register_bush_harvested()
	_play_sfx(randf_range(1.3, 1.6))
	
	# Пружинистый сбор
	var pop_tween = create_tween()
	pop_tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	pop_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Высыпаем ягоды
	var berry_item = "red_berry" if berry_type == "red" else "purple_berry"
	var count = randi_range(2, 3)
	_spawn_drops_specific(berry_item, count)
	
	_update_visuals()
	
	# Запускаем таймер отрастания ягод
	if regrows_berries:
		var t = get_tree().create_timer(regrowth_time_sec)
		t.timeout.connect(func():
			if is_instance_valid(self) and not is_dead:
				has_berries = true
				_update_visuals()
				# Легкий поп при созревании
				var regrow_tween = create_tween()
				regrow_tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
				regrow_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
		)

func _gather_bush(player: Node2D) -> void:
	is_dead = true
	monitoring = false
	monitorable = false
	
	var audio_mgr = player.get_node_or_null("/root/AudioManager") if player else get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_sfx"):
		audio_mgr.play_sfx(preload("res://assets/audio/sfx/player/sfx_item_pickup.mp3"), randf_range(1.0, 1.15), 0.0)
		
	_play_sfx(1.4)
	_spawn_leaf_particles(randi_range(8, 12), 40.0)
	_spawn_drops()
	GameStateManager.add_stat("items_gathered", 1)
	
	# Mark collected in HomeStateManager if on HomeIsland
	var current_scene = get_tree().current_scene
	var is_home = (current_scene and current_scene.name == "HomeIsland")
	if is_home and HomeStateManager:
		HomeStateManager.mark_destroyed(get_path())
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.25, 0.5), 0.06)
	tween.chain().tween_property(sprite, "scale", Vector2.ZERO, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.12)
	tween.chain().tween_callback(queue_free)

func _spawn_leaf_particles(count: int, vel: float) -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.lifetime = 0.7
	particles.amount = count
	
	var tex_path = "res://assets/new_assets/Cute_Fantasy_Desert/Props/Fallen_Palm_Leaves.png"
	particles.texture = load(tex_path)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(6, 4)
	particles.position = Vector2(0, -6)
	
	particles.gravity = Vector2(0, 40.0)
	particles.direction = Vector2(0, -1)
	particles.spread = 160.0
	particles.initial_velocity_min = vel * 0.5
	particles.initial_velocity_max = vel
	
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	particles.scale_amount_min = 0.12
	particles.scale_amount_max = 0.22
	
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.5, 1))
	curve.add_point(Vector2(1, 0))
	particles.scale_amount_curve = curve
	
	add_child(particles)
	particles.emitting = true
	get_tree().create_timer(1.2).timeout.connect(particles.queue_free)

func _spawn_drops() -> void:
	_spawn_drops_specific(drop_item_id, randi_range(drop_amount_min, drop_amount_max))

func _spawn_drops_specific(item_id: String, count: int) -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	for i in range(count):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-4, 4))
		drop.setup(item_id, 1)
		get_tree().current_scene.add_child(drop)

func _play_sfx(pitch: float) -> void:
	if sfx and sfx.stream:
		sfx.pitch_scale = pitch
		sfx.play()
