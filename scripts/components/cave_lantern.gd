extends Node2D
class_name CaveLantern

# Настенный масляный светильник без опоры, освещающий пещеру теплым мерцающим светом.

var no_highlight: bool = true

@onready var light: PointLight2D = get_node_or_null("LanternLight")

var _base_energy: float = 0.9
var _target_energy: float = 0.9
var _base_scale: Vector2 = Vector2(1.6, 1.6)
var _target_scale: Vector2 = Vector2(1.6, 1.6)
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
		_target_energy = _base_energy + randf_range(-0.15, 0.15)
		var s_jitter = randf_range(-0.05, 0.05)
		_target_scale = _base_scale + Vector2(s_jitter, s_jitter)
		
	light.energy = move_toward(light.energy, _target_energy, delta * 3.5)
	light.scale = light.scale.move_toward(_target_scale, delta * 1.5)
