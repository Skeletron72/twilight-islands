extends Interactable
class_name Stone

var hp: int = 3
var is_dead: bool = false
var resource_id: String = "stone"
@export var rock_type: int = 1
@export var is_permanent: bool = false
var anim_frame: int = 0
var anim_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_shape: CollisionShape2D = $CollisionShape2D
@onready var static_shape: CollisionShape2D = $StaticBody/CollisionShape2D

func is_gatherable() -> bool:
	return rock_type >= 1 and rock_type <= 9

func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	var current_scene = get_tree().current_scene
	var is_home = (current_scene and current_scene.name == "HomeIsland")
	if (is_permanent or is_home) and HomeStateManager and HomeStateManager.is_destroyed(get_path()):
		queue_free()
		return
	
	if is_gatherable():
		prompt_text = "Поднять камень"
		# Small loose rocks lying on the ground do not block player movement
		if static_shape:
			static_shape.disabled = true
	else:
		prompt_text = "Добыть камень"
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
	
	if is_gatherable():
		_collect_as_gatherable(player)
		return
	
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
		var current_scene = get_tree().current_scene
		var is_home = (current_scene and current_scene.name == "HomeIsland")
		if (is_permanent or is_home) and HomeStateManager:
			HomeStateManager.mark_destroyed(get_path())
		GameStateManager.register_stone_mined()
		_spawn_drops()
		
		# Code-based destruction animation
		var shrink_tween = create_tween()
		shrink_tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1) # Small pop up
		shrink_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15) # Shrink to nothing
		shrink_tween.tween_callback(queue_free)

func _collect_as_gatherable(player: Node2D) -> void:
	is_dead = true
	
	# Audio pickup effect
	var audio_mgr = player.get_node_or_null("/root/AudioManager") if player else get_node_or_null("/root/AudioManager")
	if audio_mgr and audio_mgr.has_method("play_sfx"):
		audio_mgr.play_sfx(preload("res://assets/audio/sfx/player/sfx_item_pickup.mp3"), randf_range(1.0, 1.15), 0.0)
		
	# Add stone item to inventory
	InventoryManager.add_item("stone", 1)
	
	# Update stats
	GameStateManager.add_stat("items_gathered", 1)
	
	# Mark collected in HomeStateManager so it stays collected on reload
	var current_scene = get_tree().current_scene
	var is_home = (current_scene and current_scene.name == "HomeIsland")
	if (is_permanent or is_home) and HomeStateManager:
		HomeStateManager.mark_destroyed(get_path())
		
	# Disable collisions immediately so player can no longer target it
	if interaction_shape:
		interaction_shape.set_deferred("disabled", true)
	collision_layer = 0
	
	# Smooth gather animation: small hop up, scale pop and shrink
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.25, 1.25), 0.06)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "position:y", sprite.position.y - 7.0, 0.08)
	tween.chain().tween_property(sprite, "scale", Vector2.ZERO, 0.12)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.chain().tween_callback(queue_free)

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
		
	
