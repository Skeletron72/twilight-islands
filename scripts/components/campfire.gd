extends StaticBody2D

@onready var fire_sprite = $FireSprite
@onready var light = $PointLight2D
@onready var anim_player = $AnimationPlayer

var is_lit: bool = false

func _ready() -> void:
	_update_visuals()

func interact(player: Node2D) -> void:
	is_lit = not is_lit
	_update_visuals()

func _update_visuals() -> void:
	fire_sprite.visible = is_lit
	light.visible = is_lit
	if is_lit:
		anim_player.play("burn")
	else:
		anim_player.stop()
