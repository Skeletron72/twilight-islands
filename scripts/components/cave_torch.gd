extends Node2D
class_name CaveTorch

# Wall torch / ambient light providing warm illumination in cave floors.

@onready var light: PointLight2D = $PointLight2D
var _base_energy: float = 0.85
var _flicker_timer: float = 0.0

func _ready() -> void:
	if light:
		_base_energy = light.energy
		_flicker_timer = randf() * 0.2

func _process(delta: float) -> void:
	if not light: return
	_flicker_timer -= delta
	if _flicker_timer <= 0.0:
		_flicker_timer = randf_range(0.08, 0.18)
		# Subtle warm torch flicker
		light.energy = _base_energy + randf_range(-0.12, 0.12)
