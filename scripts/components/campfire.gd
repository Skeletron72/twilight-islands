extends StaticBody2D
class_name Campfire

@onready var unlit_sprite: Sprite2D = $Sprite2D
@onready var fire_sprite: Sprite2D = $FireSprite
@onready var light: PointLight2D = $PointLight2D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var fire_sfx: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

@export var is_lit: bool = false

func _ready() -> void:
	add_to_group("interactable")
	y_sort_enabled = true
	if fire_sfx:
		fire_sfx.finished.connect(func():
			if is_lit:
				fire_sfx.play()
		)
	_update_visuals()

func interact(player: Node2D) -> void:
	is_lit = not is_lit
	if is_lit:
		GameStateManager.register_campfire_lit()
	_update_visuals()

func _update_visuals() -> void:
	if unlit_sprite:
		unlit_sprite.visible = not is_lit
	if fire_sprite:
		fire_sprite.visible = is_lit
	if light:
		light.visible = is_lit
	if anim_player:
		if is_lit:
			anim_player.play("burn")
		else:
			anim_player.stop()
	if fire_sfx and is_inside_tree():
		if is_lit and not fire_sfx.playing:
			fire_sfx.play()
		elif not is_lit and fire_sfx.playing:
			fire_sfx.stop()
