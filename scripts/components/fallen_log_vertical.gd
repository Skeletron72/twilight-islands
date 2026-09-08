extends Interactable
class_name FallenLogVertical

enum Variant {
	NO_BRANCHES = 0,     # 32 176 32 16 (Без веток)
	ONE_BRANCH = 1,      # 0 176 32 16 (1 ветка)
	BLUE_MUSHROOM = 2,   # 64 160 32 16 (Синий гриб)
	RED_MUSHROOM = 3,    # 32 160 32 16 (Красный гриб)
	PURPLE_MUSHROOM = 4  # 0 160 32 16 (Фиолетовый гриб)
}

# -1 = случайно при спавне
@export var variant: int = -1
@export var max_hp: int = 3

var current_hp: int = 3
var is_broken: bool = false
var _is_shaking: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

const DECOR_TEX = "res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor.png"

const LOG_REGIONS = [
	Rect2(32, 176, 32, 16), # 0: Без веток
	Rect2(0, 176, 32, 16),  # 1: 1 ветка
	Rect2(64, 160, 32, 16), # 2: Синий гриб
	Rect2(32, 160, 32, 16), # 3: Красный гриб
	Rect2(0, 160, 32, 16)   # 4: Фиолетовый гриб
]

func _ready() -> void:
	super._ready()
	collision_layer = 2
	collision_mask = 0
	
	if variant < 0 or variant >= LOG_REGIONS.size():
		variant = randi() % LOG_REGIONS.size()
		
	current_hp = max_hp
	_apply_visuals()

func _apply_visuals() -> void:
	if not sprite: return
	var atlas = AtlasTexture.new()
	atlas.atlas = load(DECOR_TEX)
	atlas.region = LOG_REGIONS[variant]
	sprite.texture = atlas
	sprite.offset = Vector2(0, -8)
	
	# Грибные брёвна мягко светятся в темноте
	var mushroom_colors = {
		Variant.BLUE_MUSHROOM: Color(0.25, 0.65, 1.0, 0.75),   # Синий гриб
		Variant.RED_MUSHROOM: Color(1.0, 0.35, 0.25, 0.75),     # Красный гриб
		Variant.PURPLE_MUSHROOM: Color(0.75, 0.35, 0.95, 0.75)  # Фиолетовый гриб
	}
	
	if variant in mushroom_colors:
		var light = get_node_or_null("PointLight2D")
		if not light:
			light = PointLight2D.new()
			light.name = "PointLight2D"
			light.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			light.color = mushroom_colors[variant]
			light.energy = 0.22
			light.scale = Vector2(1.8, 1.8)
			light.position = Vector2(4, -6)
			
			var grad = Gradient.new()
			grad.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT
			grad.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
			grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(0.4, 0.4, 0.4, 1), Color(0, 0, 0, 1)])
			
			var tex = GradientTexture2D.new()
			tex.gradient = grad
			tex.fill = GradientTexture2D.FILL_RADIAL
			tex.fill_from = Vector2(0.5, 0.5)
			tex.fill_to = Vector2(0.85, 0.85)
			tex.width = 24
			tex.height = 24
			light.texture = tex
			add_child(light)

var resource_id: String = "wood"

func interact(player: Node2D) -> void:
	if is_broken: return
	
	# Разрубается только топором!
	var has_axe = InventoryManager.get_item_amount("stone_axe") > 0 or InventoryManager.get_item_amount("wooden_axe") > 0
	if not has_axe:
		print("Поваленное бревно можно разрубить только топором!")
		return
		
	current_hp -= 1
	_play_hit_sfx()
	_play_shake()
	_spawn_hit_particles()
	
	if current_hp <= 0:
		_break_log()

func _play_hit_sfx() -> void:
	if not sfx: return
	sfx.stream = load("res://assets/audio/sfx/tools/sfx_wood_hit.mp3")
	sfx.pitch_scale = randf_range(0.9, 1.2)
	sfx.volume_db = -4.0
	sfx.play()

func _play_shake() -> void:
	if _is_shaking or not sprite: return
	_is_shaking = true
	var orig_rot = sprite.rotation
	var shake_dir = 1.0 if randf() > 0.5 else -1.0
	var tween = create_tween()
	tween.tween_property(sprite, "rotation", orig_rot + shake_dir * 0.08, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "rotation", orig_rot - shake_dir * 0.05, 0.05).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sprite, "rotation", orig_rot, 0.04).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func(): _is_shaking = false)

func _spawn_hit_particles() -> void:
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.85
	p.lifetime = 0.5
	p.amount = 6
	p.direction = Vector2(0, -1)
	p.spread = 60.0
	p.initial_velocity_min = 35.0
	p.initial_velocity_max = 65.0
	p.gravity = Vector2(0, 150)
	p.scale_amount_min = 1.5
	p.scale_amount_max = 2.5
	p.color = Color(0.68, 0.48, 0.30, 1.0) # Древесные щепки
	p.position = Vector2(0, -6)
	add_child(p)
	p.emitting = true
	get_tree().create_timer(0.6).timeout.connect(p.queue_free)

func _break_log() -> void:
	is_broken = true
	
	# Звук раскалывания
	var break_sfx = AudioStreamPlayer2D.new()
	break_sfx.stream = load("res://assets/audio/sfx/tools/sfx_wood_break.mp3")
	break_sfx.volume_db = -2.0
	break_sfx.pitch_scale = randf_range(0.95, 1.1)
	break_sfx.bus = &"SFX"
	get_tree().current_scene.add_child(break_sfx)
	break_sfx.global_position = global_position
	break_sfx.play()
	break_sfx.finished.connect(break_sfx.queue_free)
	
	# Эффект разлёта щепок
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = 0.7
	p.amount = 14
	p.direction = Vector2(0, -1)
	p.spread = 90.0
	p.initial_velocity_min = 45.0
	p.initial_velocity_max = 90.0
	p.gravity = Vector2(0, 180)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 3.5
	p.color = Color(0.62, 0.42, 0.25, 1.0)
	p.global_position = global_position + Vector2(0, -6)
	get_tree().current_scene.add_child(p)
	p.emitting = true
	get_tree().create_timer(0.8).timeout.connect(p.queue_free)
	
	_spawn_drops()
	queue_free()

func _spawn_drops() -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	
	# Древесина: 1-2 штуки
	var wood_count = randi_range(1, 2)
	for i in range(wood_count):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-4, 4))
		drop.setup("wood", 1)
		get_tree().current_scene.add_child(drop)
		
	# Палки: 1-2 штуки (с веткой: 2-3)
	var stick_count = randi_range(2, 3) if variant == Variant.ONE_BRANCH else randi_range(1, 2)
	for i in range(stick_count):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-10, 10), randf_range(-4, 4))
		drop.setup("stick", 1)
		get_tree().current_scene.add_child(drop)
		
	# Бонус за грибные брёвна:
	var mushroom_drop_id = ""
	if variant == Variant.RED_MUSHROOM:
		mushroom_drop_id = "red_mushroom"
	elif variant == Variant.BLUE_MUSHROOM:
		mushroom_drop_id = "blue_mushroom"
	elif variant == Variant.PURPLE_MUSHROOM:
		mushroom_drop_id = "purple_mushroom"
		
	if mushroom_drop_id != "":
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-4, 4))
		drop.setup(mushroom_drop_id, 1)
		get_tree().current_scene.add_child(drop)
