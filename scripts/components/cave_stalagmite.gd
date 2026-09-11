extends StaticBody2D
class_name CaveStalagmite

# Декоративный сталагмит в пещере (4 варианта из Cave_Decorations.png).

var no_highlight: bool = true

@export_range(0, 3) var variant: int = 0:
	set(val):
		variant = clampi(val, 0, 3)
		_update_sprite()

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	if variant == 0 and randf() > 0.0:
		variant = randi() % 4
	_update_sprite()

func _update_sprite() -> void:
	if not sprite: return
	sprite.region_rect = Rect2(variant * 16, 16, 16, 16)
