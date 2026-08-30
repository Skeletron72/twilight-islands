extends Area2D
class_name DroppedItem

var item_id: String = ""
var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var float_timer: float = 0.0
var start_y: float = 0.0

var is_pickup_ready: bool = false
var is_sucking: bool = false
var target_player: Node2D = null

func setup(id: String, count: int) -> void:
	item_id = id
	amount = count

func _ready() -> void:
	if item_id != "":
		sprite.texture = ItemDB.get_icon(item_id)
		
	# Pop out animation with random scatter
	scale = Vector2.ZERO
	var tween = create_tween()
	
	# Random direction and distance for pop out
	var random_offset = Vector2(randf_range(-24, 24), randf_range(8, 24))
	var target_pos = position + random_offset
	
	tween.set_parallel(true)
	tween.tween_property(self, "position", target_pos, 0.4).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Make them smaller (0.6 scale)
	tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	# Allow pickup after 0.7 seconds
	await get_tree().create_timer(0.7).timeout
	is_pickup_ready = true

func _process(delta: float) -> void:
	if not is_sucking:
		float_timer += delta * 4.0
		sprite.position.y = sin(float_timer) * 4.0
		
		# Check for player pickup
		if is_pickup_ready:
			for body in get_overlapping_bodies():
				if body is Player: # Assumes Player class exists
					is_sucking = true
					target_player = body
					break
	else:
		if target_player:
			var speed = 250.0
			var dir = (target_player.global_position - global_position).normalized()
			global_position += dir * speed * delta
			
			# Shrink slightly while flying
			scale = scale.move_toward(Vector2(0.2, 0.2), delta * 2.0)
			
			if global_position.distance_to(target_player.global_position) < 10.0:
				InventoryManager.add_item(item_id, amount)
				queue_free()

func _draw() -> void:
	# Draw a simple pixel shadow below the item
	# The transform squishes it vertically (0.3) to make it look like a flat ellipse
	draw_set_transform(Vector2(0, 8), 0, Vector2(1.0, 0.3))
	draw_circle(Vector2.ZERO, 8.0, Color(0, 0, 0, 0.4))

