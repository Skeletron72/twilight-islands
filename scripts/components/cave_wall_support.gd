extends Node2D
class_name CaveWallSupport

# Декоративная деревянная опора южной стены с масляным фонарем и мерцающим светом огня.

var no_highlight: bool = true

@onready var light: PointLight2D = get_node_or_null("LanternLight")

var _base_energy: float = 0.95
var _target_energy: float = 0.95
var _base_scale: Vector2 = Vector2(1.5, 1.5)
var _target_scale: Vector2 = Vector2(1.5, 1.5)
var _flicker_timer: float = 0.0

func _ready() -> void:
	if light:
		_base_energy = light.energy
		_target_energy = _base_energy
		_base_scale = light.scale
		_target_scale = _base_scale
		_flicker_timer = randf() * 0.2

func _process(delta: float) -> void:
	if not light: return
	
	_flicker_timer -= delta
	if _flicker_timer <= 0.0:
		_flicker_timer = randf_range(0.06, 0.16)
		# Теплое мерцание огня масляного фонаря
		_target_energy = _base_energy + randf_range(-0.16, 0.16)
		var scale_offset = randf_range(-0.06, 0.06)
		_target_scale = _base_scale + Vector2(scale_offset, scale_offset)
	
	# Плавная интерполяция к целевому значению для живого пламени
	light.energy = move_toward(light.energy, _target_energy, delta * 3.5)
	light.scale = light.scale.move_toward(_target_scale, delta * 1.5)
