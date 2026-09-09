extends Node

# DungeonManager
# Manages dungeon floor progression, surface return position, and floor transitions.

var current_floor: int = 1
var max_floor_reached: int = 1
var dungeon_seed: int = 0
var cleared_floor_tiles: Dictionary = {} # floor_num (int) -> Array[Vector2i]

var surface_scene_path: String = "res://scenes/levels/home_island.tscn"
var surface_return_pos: Vector2 = Vector2.ZERO
var is_returning_to_surface: bool = false
var is_entering_dungeon: bool = false

func _ready() -> void:
	get_tree().node_added.connect(_on_node_added)
	var gsm = get_node_or_null("/root/GameStateManager")
	if gsm and gsm.has_signal("day_changed"):
		gsm.day_changed.connect(_on_day_changed)

func _on_day_changed(_new_day: int) -> void:
	# Cave resets each new day with new layout and replenished ores
	dungeon_seed = randi()
	cleared_floor_tiles.clear()

func get_or_create_dungeon_seed() -> int:
	if dungeon_seed == 0:
		dungeon_seed = randi()
	return dungeon_seed

func mark_tile_cleared(floor_num: int, tile: Vector2i) -> void:
	if not cleared_floor_tiles.has(floor_num):
		cleared_floor_tiles[floor_num] = []
	if tile not in cleared_floor_tiles[floor_num]:
		cleared_floor_tiles[floor_num].append(tile)

func is_tile_cleared(floor_num: int, tile: Vector2i) -> bool:
	return cleared_floor_tiles.has(floor_num) and (tile in cleared_floor_tiles[floor_num])

func enter_dungeon(entrance_node: Node2D, player: Node2D = null) -> void:
	if not entrance_node:
		return
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]

	var current_scene = get_tree().current_scene
	if current_scene and current_scene.scene_file_path != "":
		surface_scene_path = current_scene.scene_file_path
	elif entrance_node.owner and entrance_node.owner.scene_file_path != "":
		surface_scene_path = entrance_node.owner.scene_file_path

	# Place player slightly below the cave entrance upon return so they step out cleanly
	surface_return_pos = entrance_node.global_position + Vector2(0, 18)
	current_floor = 1
	get_or_create_dungeon_seed()
	is_entering_dungeon = true
	is_returning_to_surface = false

	# Transition to dungeon level
	TransitionManager.transition_to("res://scenes/levels/dungeon.tscn", "Спускаемся в пещеру...")

func next_floor() -> void:
	current_floor += 1
	if current_floor > max_floor_reached:
		max_floor_reached = current_floor
	TransitionManager.transition_to("res://scenes/levels/dungeon.tscn", "Этаж %d..." % current_floor)

func previous_floor() -> void:
	if current_floor <= 1:
		exit_to_surface()
	else:
		current_floor -= 1
		TransitionManager.transition_to("res://scenes/levels/dungeon.tscn", "Этаж %d..." % current_floor)

func exit_to_surface() -> void:
	is_returning_to_surface = true
	is_entering_dungeon = false
	current_floor = 1
	var target = surface_scene_path if surface_scene_path != "" else "res://scenes/levels/home_island.tscn"
	TransitionManager.transition_to(target, "Поднимаемся на поверхность...")

func _on_node_added(node: Node) -> void:
	if is_returning_to_surface and node is Player:
		is_returning_to_surface = false
		if surface_return_pos != Vector2.ZERO:
			node.global_position = surface_return_pos
			var cam = node.get_node_or_null("Camera2D") as Camera2D
			if cam:
				cam.reset_smoothing()
