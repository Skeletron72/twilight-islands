extends Interactable
class_name Destructible

@export var max_hp: int = 3
@export var hp_variance: int = 0
@export var resource_id: String = "wood"
@export var drop_amount: int = 1
@export var drop_variance: int = 0
@export var drop_on_shrink: int = 0
@export var is_permanent: bool = false # True for HomeBase objects

# Ожидает массив Rect2 от маленькой стадии (индекс 0) до большой (индекс size-1)
@export var regions: Array[Rect2] = [] 

var current_hp: int
var current_stage_index: int = -1

func _ready() -> void:
	super._ready()
	collision_layer = 2
	if hp_variance > 0:
		max_hp += randi_range(-hp_variance, hp_variance)
	current_hp = max_hp
	
	if is_permanent and HomeStateManager.is_destroyed(get_path()):
		queue_free()
		return
		
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.texture is AtlasTexture:
		sprite.texture = sprite.texture.duplicate()
		
	_update_visual_stage()

func interact(player: Node2D) -> void:
	current_hp -= 1
	
	# Visual feedback
	var sprite = get_node_or_null("Sprite2D")
	if sprite:
		# Flash
		var orig_mod = sprite.modulate
		sprite.modulate = Color(1.5, 0.5, 0.5) # Soft red flash
		var tween = create_tween()
		tween.tween_property(sprite, "modulate", orig_mod, 0.15)
		
		# Shake
		var orig_pos = sprite.position
		var shake_tween = create_tween()
		shake_tween.tween_property(sprite, "position:x", orig_pos.x +  1.5, 0.03)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x -  1.5, 0.04)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x +  1.0, 0.04)
		shake_tween.tween_property(sprite, "position:x", orig_pos.x,  0.04)
		
	if current_hp <= 0:
		_destroy()
	else:
		var old_stage = current_stage_index
		_update_visual_stage()
		if current_stage_index < old_stage and drop_on_shrink > 0:
			for i in range(old_stage - current_stage_index):
				_spawn_drop(drop_on_shrink)

func _update_visual_stage() -> void:
	if regions.is_empty(): return
	var sprite = get_node_or_null("Sprite2D")
	if sprite and sprite.texture is AtlasTexture:
		var ratio = float(current_hp) / max_hp
		var idx = clamp(int(ceil(ratio * regions.size())) - 1, 0, regions.size() - 1)
		current_stage_index = idx
		sprite.texture.region = regions[idx]

func _spawn_drop(base_amount: int) -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	var total_amount = base_amount + randi_range(0, drop_variance)
	for i in range(total_amount):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position
		drop.setup(resource_id, 1) # Each physical item is worth 1
		get_tree().current_scene.add_child(drop)

func _destroy() -> void:
	if drop_amount > 0:
		_spawn_drop(drop_amount)
	
	if is_permanent:
		HomeStateManager.mark_destroyed(get_path())
		
	queue_free()
