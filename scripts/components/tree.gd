extends Interactable
class_name TreeObject

enum State { FULL_TREE, STUMP }

@export var tree_type: String = "oak"
@export var tree_size: String = "big" # "small", "medium", "big"

var current_state: State = State.FULL_TREE
var hp: int = 5
var stump_hp: int = 3
var is_animating: bool = false
var resource_id: String = "wood"

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_shape: CollisionShape2D = $CollisionShape2D
@onready var static_shape: CollisionShape2D = $StaticBody/CollisionShape2D
@onready var occluder: Area2D = $OccluderArea

func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	# Configure HP based on size
	if tree_size == "big":
		hp = 5
		stump_hp = 3
	elif tree_size == "medium":
		hp = 4
		stump_hp = 2
	else:
		hp = 3
		stump_hp = 1
		
	# Ensure correct starting frame (Full tree is frame 1)
	if sprite:
		sprite.frame = 1
		
	# Make shapes unique
	if interaction_shape and interaction_shape.shape:
		interaction_shape.shape = interaction_shape.shape.duplicate()
	if static_shape and static_shape.shape:
		static_shape.shape = static_shape.shape.duplicate()
	if occluder:
		var occ_shape = occluder.get_node("CollisionShape2D")
		if occ_shape and occ_shape.shape:
			occ_shape.shape = occ_shape.shape.duplicate()

func interact(player: Node2D) -> void:
	if is_animating: return
	
	if current_state == State.FULL_TREE:
		hp -= 1
		_play_shake_animation()
		if hp <= 0:
			_chop_down(player)
	else:
		stump_hp -= 1
		_play_shake_animation()
		if stump_hp <= 0:
			_destroy_stump()

func _play_shake_animation() -> void:
	if not sprite: return
	
	var orig_mod = sprite.modulate
	sprite.modulate = Color(1.5, 1.2, 1.2)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", orig_mod, 0.15)
	
	var shake_tween = create_tween()
	if current_state == State.FULL_TREE:
		# Sway from the bottom pivot
		shake_tween.tween_property(sprite, "rotation", 0.1, 0.03)
		shake_tween.tween_property(sprite, "rotation", -0.1, 0.04)
		shake_tween.tween_property(sprite, "rotation", 0.05, 0.04)
		shake_tween.tween_property(sprite, "rotation", 0.0, 0.04)
		_spawn_leaf_particles()
	else:
		# Just tiny shake for the stump
		var orig_pos = Vector2(0, sprite.offset.y)
		shake_tween.tween_property(sprite, "offset:x", orig_pos.x + 1.0, 0.03)
		shake_tween.tween_property(sprite, "offset:x", orig_pos.x - 1.0, 0.04)
		shake_tween.tween_property(sprite, "offset:x", orig_pos.x, 0.04)

func _spawn_leaf_particles() -> void:
	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.lifetime = 2.0 # Last much longer
	
	var tex_path = "res://assets/new_assets/Cute_Fantasy/Trees/Oak_Leaf_Particle.png"
	if tree_type == "birch":
		tex_path = "res://assets/new_assets/Cute_Fantasy/Trees/Birch_Leaf_Particle.png"
	elif tree_type == "spruce":
		tex_path = "res://assets/new_assets/Cute_Fantasy/Trees/Spruce_Needle_Particle.png"
		
	particles.texture = load(tex_path)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	
	var w = 24.0
	var h = 32.0
	var y_pos = -30.0
	
	# Dynamically read the exact canopy bounds from the OccluderArea!
	if occluder and occluder.get_node_or_null("CollisionShape2D"):
		var shape = occluder.get_node("CollisionShape2D").shape
		if shape is RectangleShape2D:
			w = shape.size.x / 2.0
			h = shape.size.y / 2.0
			y_pos = occluder.position.y
			
	particles.emission_rect_extents = Vector2(w, h)
	particles.position = Vector2(0, y_pos)
	
	# Float gently like a feather
	particles.gravity = Vector2(0, 60.0) 
	particles.direction = Vector2(0, -1) # Burst slightly upwards first
	particles.spread = 60.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 25.0
	
	# Slower rotation
	particles.angular_velocity_min = -45.0
	particles.angular_velocity_max = 45.0
	
	particles.scale_amount_min = 0.6
	particles.scale_amount_max = 1.0
	
	# Smooth fade out at the end
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.6, 1))
	curve.add_point(Vector2(1, 0))
	particles.scale_amount_curve = curve
	
	add_child(particles)
	particles.emitting = true
	
	get_tree().create_timer(3.0).timeout.connect(particles.queue_free)

func _chop_down(player: Node2D) -> void:
	is_animating = true
	current_state = State.STUMP
	
	_spawn_drops(tree_size == "big", false)
	
	# Create the falling top sprite
	var falling_top = Sprite2D.new()
	falling_top.texture = sprite.texture
	falling_top.hframes = 3
	falling_top.frame = 2 # Top only
	falling_top.global_position = sprite.global_position
	falling_top.offset = sprite.offset
	get_tree().current_scene.add_child(falling_top)
	
	# Determine fall direction (away from player)
	var fall_dir = 1.0
	if player and player.global_position.x > global_position.x:
		fall_dir = -1.0
		
	# Fall animation
	var fall_tween = create_tween()
	fall_tween.set_parallel(true)
	fall_tween.tween_property(falling_top, "rotation", fall_dir * (PI / 2.5), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	fall_tween.tween_property(falling_top, "modulate:a", 0.0, 0.5).set_delay(0.2)
	
	# When fall finishes, delete the temporary sprite and re-enable interaction
	var cleanup_tween = create_tween()
	cleanup_tween.tween_interval(0.6)
	cleanup_tween.tween_callback(func():
		falling_top.queue_free()
		is_animating = false
	)
	
	# Change our own sprite to the stump (frame 0)
	sprite.frame = 0
	
	# Disable the occluder since the top is gone
	if occluder:
		occluder.queue_free()

func _destroy_stump() -> void:
	_spawn_drops(tree_size == "big", true)
	queue_free()

func _spawn_drops(is_large: bool, is_stump: bool) -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	
	var wood_amount = 0
	var stick_amount = 0
	
	if is_stump:
		wood_amount = randi_range(1, 2)
		stick_amount = randi_range(1, 2) if is_large else randi_range(0, 1)
	else:
		if tree_size == "big": wood_amount = randi_range(3, 5)
		elif tree_size == "medium": wood_amount = randi_range(2, 4)
		else: wood_amount = randi_range(1, 2)
		
	# Spawn wood
	for i in range(wood_amount):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		drop.setup("wood", 1)
		get_tree().current_scene.add_child(drop)
		
	# Spawn sticks
	for i in range(stick_amount):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
		drop.setup("stick", 1)
		get_tree().current_scene.add_child(drop)
# trigger cache rebuild
