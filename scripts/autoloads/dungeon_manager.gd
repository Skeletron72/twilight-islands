extends Node

var current_floor: int = 1
var dungeon_seed: int = 0
var surface_return_scene: String = ""
var surface_return_position: Vector2 = Vector2.ZERO
var spawn_at_ladder_down: bool = false
var floor_ladder_tiles: Dictionary = {} # floor_num -> Vector2i

var cleared_tiles: Dictionary = {} # floor_num -> { tile_vec2i: true }

func get_or_create_dungeon_seed() -> int:
	if dungeon_seed == 0:
		dungeon_seed = randi()
	return dungeon_seed

func enter_dungeon(entrance_node: Node2D, player: Node2D) -> void:
	# Сохраняем сцену и координаты возврата на поверхность
	if get_tree() and is_instance_valid(get_tree().current_scene):
		surface_return_scene = get_tree().current_scene.scene_file_path
	if entrance_node:
		surface_return_position = entrance_node.global_position + Vector2(0, 32)
	
	# Сброс состояния для нового спуска в шахту
	current_floor = 1
	dungeon_seed = randi()
	spawn_at_ladder_down = false
	cleared_tiles.clear()
	floor_ladder_tiles.clear()
	
	if TransitionManager:
		TransitionManager.play_iris_transition(func():
			get_tree().change_scene_to_file("res://scenes/levels/dungeon.tscn")
		, 0.6)
	else:
		get_tree().change_scene_to_file("res://scenes/levels/dungeon.tscn")

func next_floor() -> void:
	current_floor += 1
	spawn_at_ladder_down = false
	if TransitionManager:
		TransitionManager.play_iris_transition(func():
			get_tree().reload_current_scene()
		, 0.6)
	else:
		get_tree().reload_current_scene()

func previous_floor() -> void:
	if current_floor > 1:
		current_floor -= 1
		# При подъеме наверх игрок должен появиться у люка спуска на верхнем этаже
		spawn_at_ladder_down = true
		if TransitionManager:
			TransitionManager.play_iris_transition(func():
				get_tree().reload_current_scene()
			, 0.6)
		else:
			get_tree().reload_current_scene()
	else:
		exit_to_surface()

func exit_to_surface() -> void:
	var target_scene = surface_return_scene
	if target_scene == "" or not ResourceLoader.exists(target_scene):
		target_scene = "res://scenes/levels/home_island.tscn"
	var return_pos = surface_return_position
	
	var do_exit = func():
		get_tree().change_scene_to_file(target_scene)
		
		# Ожидаем завершения загрузки сцены и установки current_scene движком
		while not is_instance_valid(get_tree().current_scene) or get_tree().current_scene.scene_file_path != target_scene:
			await get_tree().process_frame
		
		# Даем кадр на завершение инициализации дочерних нод сцены
		await get_tree().process_frame
		
		var p = get_tree().get_first_node_in_group("player")
		if not p and is_instance_valid(get_tree().current_scene):
			p = get_tree().current_scene.get_node_or_null("Player")
		
		if p:
			if return_pos != Vector2.ZERO:
				p.global_position = return_pos
			var cam = p.get_node_or_null("Camera2D") as Camera2D
			if cam:
				cam.reset_smoothing()

	if TransitionManager:
		TransitionManager.play_iris_transition(do_exit, 0.6)
	else:
		do_exit.call()

func is_tile_cleared(floor_num: int, tile: Vector2i) -> bool:
	if not cleared_tiles.has(floor_num): return false
	return cleared_tiles[floor_num].has(tile)

func mark_tile_cleared(floor_num: int, tile: Vector2i) -> void:
	if not cleared_tiles.has(floor_num):
		cleared_tiles[floor_num] = {}
	cleared_tiles[floor_num][tile] = true
