extends Sprite2D
class_name BurnEffect

## BurnEffect - статус «Горит»
## Использует statusfx_burn_sheet.png (9 кадров 100x100, активные: 1, 2, 3, 4, 5, 6, 7)
## Тушится водой (вход в воду, статус «Мокрый», или дождь/гроза на улице)

const BURN_TEXTURE = preload("res://assets/sprites/vfx/status/statusfx_burn_sheet.png")
const ACTIVE_FRAMES = [1, 2, 3, 4, 5, 6, 7]

var duration: float = 6.0
var _anim_timer: float = 0.0
var _elapsed: float = 0.0
var _damage_timer: float = 0.0
const DAMAGE_INTERVAL: float = 0.8
const DAMAGE_PER_TICK: float = 2.0

var _target_node: Node2D = null
var _original_parent_modulate: Color = Color.WHITE

func _ready() -> void:
	texture = BURN_TEXTURE
	hframes = 9
	vframes = 1
	frame = ACTIVE_FRAMES[0]
	scale = Vector2(0.85, 0.85)
	position = Vector2(0, -10)
	z_index = 24
	z_as_relative = true
	modulate = Color(1.3, 1.1, 0.85, 1.0) # Яркое пламя
	
	_target_node = get_parent() as Node2D
	if _target_node:
		_original_parent_modulate = _target_node.modulate

func _process(delta: float) -> void:
	if not _target_node or not is_instance_valid(_target_node):
		queue_free()
		return
		
	# ПРОВЕРКА ТУШЕНИЯ ВОДОЙ:
	# 1. Если персонаж в воде
	# 2. Если персонаж мокрый (статус is_wet)
	# 3. Если на улице идет дождь / гроза / сумеречный шторм
	var in_water = bool(_target_node.get("in_water"))
	var is_wet = bool(_target_node.get("is_wet"))
	var is_raining = WeatherManager and WeatherManager.is_precipitation()
	
	if in_water or is_wet or is_raining:
		extinguish()
		return
		
	_elapsed += delta
	_anim_timer += delta
	_damage_timer += delta
	
	# Анимация огня (12 fps)
	var f_idx = int(_anim_timer * 12.0) % ACTIVE_FRAMES.size()
	frame = ACTIVE_FRAMES[f_idx]
	
	# Огненное мерцание персонажа
	if _target_node and is_instance_valid(_target_node):
		var flame_pulse = 0.85 + randf() * 0.3
		var flame_tint = Color(1.3 * flame_pulse, 0.65 * flame_pulse, 0.35 * flame_pulse, 1.0)
		_target_node.modulate = flame_tint if randf() < 0.35 else _original_parent_modulate
		
	# Периодический урон от горения
	if _damage_timer >= DAMAGE_INTERVAL:
		_damage_timer = 0.0
		if _target_node.has_method("take_damage"):
			_target_node.take_damage(DAMAGE_PER_TICK, _target_node.global_position)
			
	if _elapsed >= duration:
		_cleanup_and_remove()

func extend_duration(extra_time: float) -> void:
	duration = max(duration - _elapsed, extra_time)
	_elapsed = 0.0

func extinguish() -> void:
	# Визуальный дымок пара при тушении
	_spawn_steam_puff(global_position)
	if _target_node and "is_burning" in _target_node:
		_target_node.set("is_burning", false)
	_cleanup_and_remove()

func _spawn_steam_puff(pos: Vector2) -> void:
	var dust_scene = load("res://scenes/vfx/impact_dust.tscn")
	if dust_scene:
		var dust = dust_scene.instantiate()
		dust.global_position = pos
		dust.modulate = Color(0.85, 0.90, 0.95, 0.7) # Белый дымок пара
		if get_tree() and get_tree().current_scene:
			get_tree().current_scene.add_child(dust)

func _cleanup_and_remove() -> void:
	if _target_node and is_instance_valid(_target_node):
		_target_node.modulate = _original_parent_modulate
		if "is_burning" in _target_node:
			_target_node.set("is_burning", false)
	queue_free()

static func apply_to(target: Node2D, time_sec: float = 6.0) -> BurnEffect:
	if not is_instance_valid(target):
		return null
		
	# Нельзя загореться, если уже в воде, мокрый или под дождем!
	var in_water = bool(target.get("in_water"))
	var is_wet = bool(target.get("is_wet"))
	var is_raining = WeatherManager and WeatherManager.is_precipitation()
	if in_water or is_wet or is_raining:
		# Вода не дает загореться
		return null
		
	var existing = target.get_node_or_null("BurnEffect") as BurnEffect
	if existing:
		existing.extend_duration(time_sec)
		return existing
		
	var effect = BurnEffect.new()
	effect.name = "BurnEffect"
	effect.duration = time_sec
	target.add_child(effect)
	if "is_burning" in target:
		target.set("is_burning", true)
	return effect
