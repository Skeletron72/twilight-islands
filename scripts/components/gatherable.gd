extends Area2D
class_name Gatherable

@export var resource_id: String = "stick":
	set(val):
		resource_id = val
		_update_texture()

@export var amount: int = 1
@export var is_permanent: bool = false

@onready var sprite: Sprite2D = $Sprite2D

var float_timer: float = 0.0
var _hover_y: float = 0.0
var _shadow_scale: float = 1.0
var is_sucking: bool = false
var target_player: Node2D = null
var _suction_speed: float = 0.0

func _ready() -> void:
	collision_layer = 2 # Layer 2 for Player interaction/highlighting
	collision_mask = 1  # Layer 1 for Player body detection
	y_sort_enabled = true
	
	if is_permanent and HomeStateManager and HomeStateManager.is_destroyed(get_path()):
		queue_free()
		return
		
	_update_texture()
	float_timer = randf_range(0.0, TAU)
	scale = Vector2(0.65, 0.65)

func _update_texture() -> void:
	if sprite and resource_id != "" and ItemDB:
		sprite.texture = ItemDB.get_icon(resource_id)

func interact(player: Node2D) -> void:
	if not is_sucking:
		_start_pickup(player)

func _process(delta: float) -> void:
	if not is_sucking:
		float_timer += delta * 2.5
		_hover_y = sin(float_timer) * 1.5
		if sprite:
			sprite.position.y = -2.0 + _hover_y
		_shadow_scale = 1.0 + (_hover_y / 15.0)
		queue_redraw()
		
		for body in get_overlapping_bodies():
			if body is Player:
				_start_pickup(body)
				break
	else:
		if target_player and is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position)
			_suction_speed = move_toward(_suction_speed, 650.0, delta * 900.0)
			var dir = (target_player.global_position - global_position).normalized()
			global_position += dir * _suction_speed * delta
			scale = scale.move_toward(Vector2(0.2, 0.2), delta * 1.5)
			if dist < 8.0:
				_collect()

func _start_pickup(player: Node2D) -> void:
	is_sucking = true
	target_player = player
	_suction_speed = 50.0
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.75, 0.75), 0.06)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _collect() -> void:
	if AudioManager:
		AudioManager.play_sfx(preload("res://assets/audio/sfx/player/sfx_item_pickup.mp3"), randf_range(1.0, 1.15), 0.0)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.08)
	tween.chain().tween_callback(func():
		InventoryManager.add_item(resource_id, amount)
		if is_permanent and HomeStateManager:
			HomeStateManager.mark_destroyed(get_path())
		queue_free()
	)

func _draw() -> void:
	draw_set_transform(Vector2(0, 4), 0, Vector2(_shadow_scale, 0.25))
	draw_circle(Vector2.ZERO, 6.0, Color(0, 0, 0, 0.25))
