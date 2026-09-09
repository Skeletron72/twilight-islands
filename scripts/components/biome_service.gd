class_name BiomeService
extends RefCounted

## BiomeService
## Сервис для послойного определения биома и типа поверхности ("слоеный пирог")
## Поддерживает многослойные тайлмапы: OceanLayer -> ShoreLayer -> GroundLayer -> WaterLayer -> RoadsLayer

enum SurfaceType { GRASS, STONE, DIRT, WATER, VOID }

# Стандартный порядок проверки слоев сверху вниз для определения поверхности под ногами
const LAYER_PRIORITY = ["RoadsLayer", "WaterLayer", "GrassLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]

# Маппинг ID террейнов из cute_tileset.tres в имена биомов (на случай отсутствия custom_data)
const TERRAIN_TO_BIOME: Dictionary = {
	0: "clearing",      # Базовая трава
	1: "clearing",      # Dirt (дорожка в траве)
	2: "beach",         # Sand (песок)
	3: "water",         # Water
	4: "water",         # Stone Water
	5: "clearing",      # FarmLand
	6: "beach",         # Beach Water
	7: "clearing",      # Brown Cliff
	8: "clearing",      # Grey Cliff
	9: "forest",        # Лесная трава
	10: "dry",          # Сухая трава
	11: "magic"         # Волшебная трава
}

## Находит узел WorldMap на текущей или переданной сцене
static func find_world_map(context_node: Node = null) -> Node:
	if context_node and is_instance_valid(context_node):
		if context_node.name == "WorldMap":
			return context_node
		var wm = context_node.get_node_or_null("WorldMap")
		if wm: return wm
		if context_node.is_inside_tree() and context_node.get_tree():
			var root = context_node.get_tree().current_scene
			if root:
				wm = root.get_node_or_null("WorldMap")
				if wm: return wm

	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		if Engine.is_editor_hint() and tree.edited_scene_root:
			var wm = tree.edited_scene_root.get_node_or_null("WorldMap")
			if wm: return wm
		if tree.current_scene:
			var wm = tree.current_scene.get_node_or_null("WorldMap")
			if wm: return wm

	return null

## Возвращает исчерпывающую информацию о тайле под ногами в точке world_pos с учетом "слоеного пирога"
static func get_top_tile_info(world_pos: Vector2, world_map: Node = null) -> Dictionary:
	var result = {
		"biome": "void",
		"surface": SurfaceType.VOID,
		"layer_name": "",
		"layer": null,
		"map_pos": Vector2i.ZERO,
		"source_id": -1,
		"cell_data": null,
		"is_water": false,
		"can_hoe": false,
		"is_road": false,
		"underlying_biome": "" # биом грунта под дорогой/мостом
	}

	if not world_map:
		world_map = find_world_map()
	if not world_map:
		return result

	# Проверяем слои сверху вниз
	for layer_name in LAYER_PRIORITY:
		var layer = world_map.get_node_or_null(layer_name) as TileMapLayer
		if not layer:
			continue

		var local_pos = layer.to_local(world_pos)
		var map_pos = layer.local_to_map(local_pos)
		var source_id = layer.get_cell_source_id(map_pos)
		if source_id == -1:
			continue # На этом слое ничего нет, падаем глубже в пирог!

		var cell_data = layer.get_cell_tile_data(map_pos)
		if not cell_data:
			continue

		# Если мы наткнулись на дорогу — отмечаем поверхность как камень/дорога,
		# но продолжаем искать под ней биом грунта для underlying_biome!
		if layer_name == "RoadsLayer":
			result["is_road"] = true
			if result["surface"] == SurfaceType.VOID:
				result["surface"] = SurfaceType.STONE
			# Запоминаем данные дороги, если основной слой еще не определен
			if result["layer_name"] == "":
				result["layer_name"] = "RoadsLayer"
				result["layer"] = layer
				result["map_pos"] = map_pos
				result["source_id"] = source_id
				result["cell_data"] = cell_data
			continue

		# Если мы наткнулись на внутреннюю воду
		if layer_name == "WaterLayer":
			result["is_water"] = true
			result["surface"] = SurfaceType.WATER
			result["biome"] = "water"
			result["layer_name"] = "WaterLayer"
			result["layer"] = layer
			result["map_pos"] = map_pos
			result["source_id"] = source_id
			result["cell_data"] = cell_data
			return result

		# Слой наложений трав и биомов поверх земли (GrassLayer)
		if layer_name == "GrassLayer":
			var biome_tag = _resolve_biome_from_cell(cell_data)
			result["biome"] = biome_tag
			result["layer_name"] = "GrassLayer"
			result["layer"] = layer
			result["map_pos"] = map_pos
			result["source_id"] = source_id
			result["cell_data"] = cell_data
			result["can_hoe"] = cell_data.get_custom_data("can_hoe") == true
			result["is_water"] = cell_data.get_custom_data("is_water") == true
			
			if result["surface"] == SurfaceType.VOID:
				result["surface"] = SurfaceType.WATER if result["is_water"] else SurfaceType.GRASS
			return result

		# Основной слой земли (травы всех видов)
		if layer_name == "GroundLayer":
			var biome_tag = _resolve_biome_from_cell(cell_data)
			result["biome"] = biome_tag
			result["layer_name"] = "GroundLayer"
			result["layer"] = layer
			result["map_pos"] = map_pos
			result["source_id"] = source_id
			result["cell_data"] = cell_data
			result["can_hoe"] = cell_data.get_custom_data("can_hoe") == true
			result["is_water"] = cell_data.get_custom_data("is_water") == true
			
			if result["surface"] == SurfaceType.VOID:
				result["surface"] = SurfaceType.WATER if result["is_water"] else SurfaceType.GRASS
			return result

		# Слой берега / пляжа (песок, подстилающий весь остров)
		if layer_name == "ShoreLayer":
			# Мы попали сюда только если на GroundLayer не было тайла!
			var biome_tag = _resolve_biome_from_cell(cell_data)
			if biome_tag == "clearing" or biome_tag == "void":
				biome_tag = "beach" # Для ShoreLayer по умолчанию пляж
			result["biome"] = biome_tag
			result["layer_name"] = "ShoreLayer"
			result["layer"] = layer
			result["map_pos"] = map_pos
			result["source_id"] = source_id
			result["cell_data"] = cell_data
			result["can_hoe"] = cell_data.get_custom_data("can_hoe") == true
			
			# Песок пляжа не должен считаться водой, даже если у анимированного тайла стоит флаг
			if biome_tag == "beach":
				result["is_water"] = false
			else:
				result["is_water"] = cell_data.get_custom_data("is_water") == true

			if result["surface"] == SurfaceType.VOID:
				result["surface"] = SurfaceType.WATER if result["is_water"] else SurfaceType.DIRT
			return result

		# Океан вокруг острова
		if layer_name == "OceanLayer":
			result["biome"] = "ocean"
			result["surface"] = SurfaceType.WATER
			result["is_water"] = true
			result["layer_name"] = "OceanLayer"
			result["layer"] = layer
			result["map_pos"] = map_pos
			result["source_id"] = source_id
			result["cell_data"] = cell_data
			return result

	return result

## Быстрое определение имени биома в точке мира
static func get_biome_at(world_pos: Vector2, world_map: Node = null) -> String:
	var info = get_top_tile_info(world_pos, world_map)
	return info.get("biome", "void")

## Быстрое определение, является ли точка водой
static func is_water_at(world_pos: Vector2, world_map: Node = null) -> bool:
	var info = get_top_tile_info(world_pos, world_map)
	if info.get("biome", "") == "beach":
		return false
	return info.get("is_water", false) or info.get("biome", "") in ["water", "ocean"]

## Проверяет, является ли тайл автотайлом перехода между разными биомами
static func is_transition_cell_data(cell_data: TileData) -> bool:
	if not cell_data or cell_data.terrain_set == -1:
		return false
	var biomes_found: Dictionary = {}
	if cell_data.terrain != -1 and TERRAIN_TO_BIOME.has(cell_data.terrain):
		biomes_found[TERRAIN_TO_BIOME[cell_data.terrain]] = true
	for bit in [
		TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
		TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
		TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
		TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
		TileSet.CELL_NEIGHBOR_LEFT_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
		TileSet.CELL_NEIGHBOR_TOP_SIDE,
		TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
	]:
		if cell_data.is_valid_terrain_peering_bit(bit):
			var bit_t = cell_data.get_terrain_peering_bit(bit)
			if bit_t != -1 and TERRAIN_TO_BIOME.has(bit_t):
				biomes_found[TERRAIN_TO_BIOME[bit_t]] = true
	return biomes_found.size() > 1

## Извлекает имя биома из TileData: сначала из custom_data("biome"), затем из terrain ID и peering bits
static func _resolve_biome_from_cell(cell_data: TileData) -> String:
	if not cell_data:
		return "void"

	# Если в автотайле смешаны разные биомы — помечаем как transition (граница)
	if is_transition_cell_data(cell_data):
		return "transition"

	# 1. Проверяем custom_data("biome")
	var custom_biome = cell_data.get_custom_data("biome")
	if custom_biome is String and custom_biome != "":
		return custom_biome

	# 2. Если пусто — проверяем прямой террейн
	var t_id = cell_data.terrain
	if t_id != -1 and TERRAIN_TO_BIOME.has(t_id):
		return TERRAIN_TO_BIOME[t_id]

	# 3. Проверяем peering bits террейнов (для краевых автотайлов)
	if cell_data.terrain_set != -1:
		for bit in [
			TileSet.CELL_NEIGHBOR_RIGHT_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
			TileSet.CELL_NEIGHBOR_BOTTOM_SIDE,
			TileSet.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_LEFT_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_LEFT_CORNER,
			TileSet.CELL_NEIGHBOR_TOP_SIDE,
			TileSet.CELL_NEIGHBOR_TOP_RIGHT_CORNER
		]:
			if cell_data.is_valid_terrain_peering_bit(bit):
				var bit_t = cell_data.get_terrain_peering_bit(bit)
				if bit_t != -1 and TERRAIN_TO_BIOME.has(bit_t):
					return TERRAIN_TO_BIOME[bit_t]

	return "clearing"

## Индексирует всю карту острова и группирует видимые тайлы по биомам
## Возвращает Dictionary[String, Array[Vector2i]]:
## {
##    "clearing": [Vector2i, ...],
##    "forest":   [Vector2i, ...],
##    "dry":      [Vector2i, ...],
##    "magic":    [Vector2i, ...],
##    "beach":    [Vector2i, ...]
## }
static func get_cells_by_biome(world_map: Node = null, exclude_blocked: bool = true) -> Dictionary:
	var result: Dictionary = {
		"clearing": [],
		"forest": [],
		"dry": [],
		"magic": [],
		"beach": [],
		"water": []
	}

	if not world_map:
		world_map = find_world_map()
	if not world_map:
		return result

	var grass_layer = world_map.get_node_or_null("GrassLayer") as TileMapLayer
	var ground_layer = world_map.get_node_or_null("GroundLayer") as TileMapLayer
	var shore_layer = world_map.get_node_or_null("ShoreLayer") as TileMapLayer
	var roads_layer = world_map.get_node_or_null("RoadsLayer") as TileMapLayer
	var water_layer = world_map.get_node_or_null("WaterLayer") as TileMapLayer
	var objects_layer = world_map.get_node_or_null("ObjectsLayer") as TileMapLayer
	var cliffs_layer = world_map.get_node_or_null("CliffsLayer") as TileMapLayer
	var houses_layer = world_map.get_node_or_null("HousesLayer") as TileMapLayer

	# Собираем все координаты суши со всех слоев
	var all_coords: Dictionary = {}
	if shore_layer:
		for cell in shore_layer.get_used_cells():
			all_coords[cell] = true
	if ground_layer:
		for cell in ground_layer.get_used_cells():
			all_coords[cell] = true
	if grass_layer:
		for cell in grass_layer.get_used_cells():
			all_coords[cell] = true

	for cell in all_coords.keys():
		# Проверка блокировок объектами/домами/скалами/дорогами
		if exclude_blocked:
			if roads_layer and roads_layer.get_cell_source_id(cell) != -1:
				continue
			if objects_layer and objects_layer.get_cell_source_id(cell) != -1:
				continue
			if houses_layer and houses_layer.get_cell_source_id(cell) != -1:
				continue
			if cliffs_layer and cliffs_layer.get_cell_source_id(cell) != -1:
				continue
			if water_layer and water_layer.get_cell_source_id(cell) != -1:
				continue

		# Приоритет слоев: GrassLayer -> GroundLayer -> ShoreLayer
		if grass_layer and grass_layer.get_cell_source_id(cell) != -1:
			var cell_data = grass_layer.get_cell_tile_data(cell)
			var b = _resolve_biome_from_cell(cell_data)
			if not result.has(b):
				result[b] = []
			result[b].append(cell)
		elif ground_layer and ground_layer.get_cell_source_id(cell) != -1:
			var cell_data = ground_layer.get_cell_tile_data(cell)
			var b = _resolve_biome_from_cell(cell_data)
			if not result.has(b):
				result[b] = []
			result[b].append(cell)
		elif shore_layer and shore_layer.get_cell_source_id(cell) != -1:
			var cell_data = shore_layer.get_cell_tile_data(cell)
			var b = _resolve_biome_from_cell(cell_data)
			if b == "clearing" or b == "void":
				b = "beach"
			if not result.has(b):
				result[b] = []
			result[b].append(cell)

	return result

## Возвращает случайную мировую позицию внутри заданного биома
static func get_random_world_pos_in_biome(biome_name: String, rng: RandomNumberGenerator, world_map: Node = null) -> Vector2:
	var biome_cells = get_cells_by_biome(world_map, true)
	if not biome_cells.has(biome_name) or biome_cells[biome_name].is_empty():
		return Vector2.INF

	var cells: Array = biome_cells[biome_name]
	var cell: Vector2i = cells[rng.randi() % cells.size()]

	var ref_layer = (world_map.get_node_or_null("GroundLayer") if world_map else null) as TileMapLayer
	if not ref_layer and world_map:
		ref_layer = world_map.get_node_or_null("ShoreLayer") as TileMapLayer

	if ref_layer:
		return ref_layer.to_global(ref_layer.map_to_local(cell))
	return Vector2(cell.x * 16.0 + 8.0, cell.y * 16.0 + 8.0)
