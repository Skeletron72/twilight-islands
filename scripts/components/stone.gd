extends Interactable
class_name Stone

var hp: int = 3
var is_dead: bool = false
var resource_id: String = "stone"
@export var rock_type: int = 1
var anim_frame: int = 0
var anim_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_shape: CollisionShape2D = $CollisionShape2D
@onready var static_shape: CollisionShape2D = $StaticBody/CollisionShape2D

func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	var is_large = rock_type >= 11
	if is_large:
		hp = randi_range(4, 7)
	else:
		hp = randi_range(2, 4)
		
	# Randomize start frame and timer so they wiggle chaotically
	anim_frame = randi() % 8
	if sprite:
		sprite.frame = anim_frame
	anim_timer = randf() * 0.1
	set_process(true)

func interact(player: Node2D) -> void:
	if is_dead: return
	
	hp -= 1
	
	# Visual feedback: flash and shake
	var orig_mod = sprite.modulate
	sprite.modulate = Color(1.5, 0.5, 0.5)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", orig_mod, 0.15)
	
	var orig_pos = Vector2.ZERO
	var shake_tween = create_tween()
	shake_tween.tween_property(sprite, "position:x", orig_pos.x + 1.5, 0.03)
	shake_tween.tween_property(sprite, "position:x", orig_pos.x - 1.5, 0.04)
	shake_tween.tween_property(sprite, "position:x", orig_pos.x + 1.0, 0.04)
	shake_tween.tween_property(sprite, "position:x", orig_pos.x, 0.04)
	
	if hp <= 0:
		is_dead = true
		_spawn_drops()
		
		# Code-based destruction animation
		var shrink_tween = create_tween()
		shrink_tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1) # Small pop up
		shrink_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15) # Shrink to nothing
		shrink_tween.tween_callback(queue_free)

func _process(delta: float) -> void:
	if is_dead: return # Stop animating frames when shrinking
	
	anim_timer += delta
	if anim_timer >= 0.1: # 10 FPS
		anim_timer -= 0.1
		anim_frame = (anim_frame + 1) % 8
		if sprite: sprite.frame = anim_frame

func _spawn_drops() -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	var is_large = rock_type >= 11
	
	# Small rocks drop 1-2 stone. Large drop 2-4 stone.
	var amount = randi_range(2, 4) if is_large else randi_range(1, 2)
	
	for i in range(amount):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-4, 4), randf_range(-4, 4))
		drop.setup("stone", 1)
		get_tree().current_scene.add_child(drop)
		
	
