extends Stone
class_name CaveOreRock

# Minable ore deposit found inside dungeon and cave floors.
# Drops twilight ore, raw stones, and occasionally ancient coins.

@export_range(1, 4) var ore_variant: int = 1

const ORE_TEXTURES = {
	1: preload("res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Cave_Rock_1_Anim.png"),
	2: preload("res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Cave_Rock_2_Anim.png"),
	3: preload("res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Cave_Rock_3_Anim.png"),
	4: preload("res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Cave_Rock_4_Anim.png")
}

func is_gatherable() -> bool:
	return false

func _ready() -> void:
	super._ready()
	prompt_text = "Добыть рудную жилу"
	hp = randi_range(3, 5)
	
	if ore_variant == 0 or not ORE_TEXTURES.has(ore_variant):
		ore_variant = randi_range(1, 4)
		
	if sprite and ORE_TEXTURES.has(ore_variant):
		sprite.texture = ORE_TEXTURES[ore_variant]
		sprite.hframes = 8
		sprite.vframes = 1
		sprite.frame = randi() % 8

func _spawn_drops() -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	
	# Guaranteed twilight ore drop
	var ore_count = randi_range(1, 2)
	for i in range(ore_count):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
		drop.setup("twilight_ore", 1)
		get_tree().current_scene.add_child(drop)
		
	# Additional stone drops
	var stone_count = randi_range(1, 3)
	for i in range(stone_count):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
		drop.setup("stone", 1)
		get_tree().current_scene.add_child(drop)
		
	# Chance for coins (25%)
	if randf() < 0.25:
		var coin_drop = dropped_scene.instantiate()
		coin_drop.global_position = global_position + Vector2(randf_range(-4, 4), randf_range(-4, 4))
		coin_drop.setup("coin", randi_range(1, 3))
		get_tree().current_scene.add_child(coin_drop)
