extends Node

var current_floor: int = 1
var dungeon_seed: int = 0
var surface_return_scene: String = ""
var surface_return_position: Vector2 = Vector2.ZERO

var cleared_tiles: Dictionary = {} # floor_num -> { tile_vec2i: true }

func get_or_create_dungeon_seed() -> int:
	if dungeon_seed == 0:
		dungeon_seed = randi()
	return dungeon_seed

func enter_dungeon(entrance_node: Node2D, player: Node2D) -> void:
	if TransitionManager:
		# Save where to return to
		surface_return_scene = get_tree().current_scene.scene_file_path
		surface_return_position = entrance_node.global_position + Vector2(0, 32)
		
		# Reset dungeon run
		current_floor = 1
		dungeon_seed = randi()
		cleared_tiles.clear()
		
		TransitionManager.play_iris_transition(func():
			get_tree().change_scene_to_file("res://scenes/levels/dungeon.tscn")
		, 0.6)

func next_floor() -> void:
	if TransitionManager:
		current_floor += 1
		TransitionManager.play_iris_transition(func():
			get_tree().reload_current_scene()
		, 0.6)

func previous_floor() -> void:
	if current_floor > 1:
		if TransitionManager:
			current_floor -= 1
			TransitionManager.play_iris_transition(func():
				get_tree().reload_current_scene()
			, 0.6)
	else:
		exit_to_surface()

func exit_to_surface() -> void:
	if TransitionManager and surface_return_scene != "":
		TransitionManager.play_iris_transition(func():
			get_tree().change_scene_to_file(surface_return_scene)
			
			# Wait a bit for scene to load
			await get_tree().process_frame
			var p = get_tree().current_scene.get_node_or_null("Player")
			if p:
				p.global_position = surface_return_position
		, 0.6)

func is_tile_cleared(floor_num: int, tile: Vector2i) -> bool:
	if not cleared_tiles.has(floor_num): return false
	return cleared_tiles[floor_num].has(tile)

func mark_tile_cleared(floor_num: int, tile: Vector2i) -> void:
	if not cleared_tiles.has(floor_num):
		cleared_tiles[floor_num] = {}
	cleared_tiles[floor_num][tile] = true
