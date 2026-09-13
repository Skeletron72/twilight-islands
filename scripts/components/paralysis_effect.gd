extends Sprite2D
class_name ParalysisEffect

## Эффект электрического паралича (желтые или фиолетовые искры вокруг сущности)
## Использует status_paralyzed_Y_sheet.png (9 кадров 100x100, активные: 0, 3, 4, 5, 6, 7)

const PARALYZED_TEXTURE = preload("res://assets/sprites/vfx/lightning/Lightning Yellow/status_paralyzed_Y_sheet.png")
const ACTIVE_FRAMES = [0, 3, 4, 5, 6, 7]

var duration: float = 2.0
var is_twilight: bool = false
var _anim_timer: float = 0.0
var _elapsed: float = 0.0
var _original_parent_modulate: Color = Color.WHITE
var _target_node: Node2D = null

func _ready() -> void:
	texture = PARALYZED_TEXTURE
	hframes = 9
	vframes = 1
	frame = ACTIVE_FRAMES[0]
	scale = Vector2(0.68, 0.68)
	position = Vector2(0, -12)
	z_index = 20
	z_as_relative = true
	
	# Фиолетовый фильтр для сумеречного шторма
	if is_twilight or (WeatherManager and WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM):
		modulate = Color(1.35, 0.55, 1.9, 1.0)
	else:
		modulate = Color(1.2, 1.2, 0.85, 1.0)
	
	_target_node = get_parent() as Node2D
	if _target_node:
		_original_parent_modulate = _target_node.modulate

func _process(delta: float) -> void:
	_elapsed += delta
	_anim_timer += delta
	
	# Анимация искр (12 кадров в секунду без пустых кадров)
	var f_idx = int(_anim_timer * 12.0) % ACTIVE_FRAMES.size()
	frame = ACTIVE_FRAMES[f_idx]
	
	# Электрическая дрожь родителя с учетом фильтра
	if _target_node and is_instance_valid(_target_node):
		var jitter_alpha = 0.85 + randf() * 0.15
		var elec_tint: Color
		if is_twilight or (WeatherManager and WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM):
			elec_tint = Color(1.25, 0.6, 1.7, jitter_alpha)
		else:
			elec_tint = Color(1.15, 1.15, 0.8, jitter_alpha)
			
		_target_node.modulate = elec_tint if randf() < 0.3 else _original_parent_modulate
	
	if _elapsed >= duration:
		_cleanup_and_remove()

func extend_duration(extra_time: float) -> void:
	duration = max(duration - _elapsed, extra_time)
	_elapsed = 0.0

func _cleanup_and_remove() -> void:
	if _target_node and is_instance_valid(_target_node):
		_target_node.modulate = _original_parent_modulate
	queue_free()

static func apply_to(target: Node2D, time_sec: float, p_is_twilight: bool = false) -> ParalysisEffect:
	if not is_instance_valid(target):
		return null
		
	var existing = target.get_node_or_null("ParalysisEffect") as ParalysisEffect
	if existing:
		existing.is_twilight = p_is_twilight or existing.is_twilight
		existing.extend_duration(time_sec)
		return existing
		
	var effect = ParalysisEffect.new()
	effect.name = "ParalysisEffect"
	effect.duration = time_sec
	effect.is_twilight = p_is_twilight
	target.add_child(effect)
	return effect
