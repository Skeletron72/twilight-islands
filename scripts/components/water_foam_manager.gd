class_name WaterFoamManager
extends Node2D

## Менеджер естественной водной пены.
## Спавнит пену ТОЛЬКО в море (OceanLayer) и в пещерных озёрах (подземелье).
## В реках на островах спавн строго отключён.
## Форма пены всегда минимум 2х2 тайла (без одиночных 1х1 кусочков).

@export var max_foams: int = 14
@export var spawn_radius_min: float = 60.0
@export var spawn_radius_max: float = 300.0
@export var despawn_distance: float = 460.0
@export var min_dist_between: float = 48.0

var foam_scene: PackedScene = preload("res://scenes/vfx/water_foam_ambient.tscn")
var _spawn_timer: float = 0.5
var _active_foams: Array[Node2D] = []
var _is_cave: bool = false

func _ready() -> void:
	var world_map = get_parent().get_node_or_null("WorldMap") if get_parent() else null
	if world_map:
		z_as_relative = false
		z_index = -3900 # Строго над OceanLayer (-4000), но под землёй и объектами
	else:
		z_as_relative = true
		z_index = 1
		
	var root_scene = get_tree().current_scene if (get_tree() and get_tree().current_scene) else null
	if root_scene:
		if root_scene.name == "Dungeon" or root_scene.get_node_or_null("FloorLayer") != null:
			_is_cave = true
			max_foams = 6 # В пещерах озёра компактнее
			spawn_radius_max = 220.0

func _process(delta: float) -> void:
	if not is_inside_tree():
		return
	var tree = get_tree()
	if not tree:
		return

	# Фильтрация уничтоженных нод
	_active_foams = _active_foams.filter(func(f): return is_instance_valid(f))
	
	var player = tree.get_first_node_in_group("player")
	var center_pos = player.global_position if (player and is_instance_valid(player)) else global_position
	
	# Удаление уплывших далеко от игрока
	for f in _active_foams:
		if f.global_position.distance_to(center_pos) > despawn_distance:
			if f.has_method("fade_out_and_free"):
				f.fade_out_and_free(0.8)
			else:
				f.queue_free()

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = randf_range(0.7, 1.5)
		if _active_foams.size() < max_foams:
			_try_spawn_foam(center_pos)

func _try_spawn_foam(center_pos: Vector2) -> void:
	if not foam_scene:
		return
		
	# До 8 попыток найти подходящее место в открытой воде
	for attempt in range(8):
		var angle = randf() * TAU
		var dist = randf_range(spawn_radius_min, spawn_radius_max)
		var cand_pos = center_pos + Vector2(cos(angle), sin(angle)) * dist
		
		if _is_valid_water_spot(cand_pos):
			var foam = foam_scene.instantiate() as Node2D
			foam.global_position = cand_pos
			add_child(foam)
			_active_foams.append(foam)
			break

func _is_valid_water_spot(pos: Vector2) -> bool:
	var center_info = BiomeService.get_top_tile_info(pos)
	if not center_info.is_water:
		return false

	if _is_cave:
		# В пещерах вода допустима только на FloorLayer / WaterLayer в пещере
		# Проверяем окрестности (радиус 20px), чтобы волна 2х2+ помещалась в озере
		var cave_offsets = [
			Vector2(-20, -20), Vector2(20, -20), Vector2(-20, 20), Vector2(20, 20),
			Vector2(-20, 0), Vector2(20, 0), Vector2(0, -20), Vector2(0, 20)
		]
		for off in cave_offsets:
			var p = BiomeService.get_top_tile_info(pos + off)
			if not p.is_water:
				return false
	else:
		# НА ПОВЕРХНОСТИ: спавн РАЗРЕШЁН ТОЛЬКО В МОРЕ (OceanLayer)
		# В РЕКАХ (WaterLayer) СПАВН СТРОГО ЗАПРЕЩЁН
		if center_info.layer_name != "OceanLayer":
			return false
		
		# Проверяем контрольные точки вокруг (радиус 24px):
		# все точки обязаны быть в OceanLayer (исключая сушу, берег и реки)
		var ocean_offsets = [
			Vector2(-24, -24), Vector2(24, -24), Vector2(-24, 24), Vector2(24, 24),
			Vector2(-24, 0), Vector2(24, 0), Vector2(0, -24), Vector2(0, 24)
		]
		for off in ocean_offsets:
			var p = BiomeService.get_top_tile_info(pos + off)
			if not p.is_water or p.layer_name != "OceanLayer":
				return false

	# Дистанция до других активных островков пены (не менее 48px)
	for f in _active_foams:
		if is_instance_valid(f) and f.global_position.distance_to(pos) < min_dist_between:
			return false

	return true
