@tool
extends Node2D
class_name ResourceSpawner

## ResourceSpawner
## Компонент процедурной расстановки ресурсов и растительности по биомам острова.
## Поддерживает многослойную структуру карты (слоеный пирог) через BiomeService.

@export_group("Actions")
@export var generate_now: bool = false:
	set(val):
		generate_now = false
		if val and is_inside_tree():
			_generate_all()

@export var clear_now: bool = false:
	set(val):
		clear_now = false
		if val and is_inside_tree():
			_clear_all()

@export var detect_area_now: bool = false:
	set(val):
		detect_area_now = false
		if val and is_inside_tree():
			_update_spawn_area()

@export var prune_border_violators_now: bool = false:
	set(val):
		prune_border_violators_now = false
		if val and is_inside_tree():
			_prune_border_violators()

@export var reload_tileset_now: bool = false:
	set(val):
		reload_tileset_now = false
		if val and is_inside_tree():
			_reload_tileset()

@export var refresh_biomes_view: bool = false:
	set(val):
		refresh_biomes_view = false
		if val and is_inside_tree():
			_refresh_biome_cache()
			queue_redraw()

@export_group("Island Bounds & Mode")
@export var auto_detect_spawn_area: bool = true:
	set(val):
		auto_detect_spawn_area = val
		if is_inside_tree() and auto_detect_spawn_area:
			_update_spawn_area()

@export var spawn_area: Rect2 = Rect2(-48, -848, 1664, 1232):
	set(val):
		spawn_area = val
		_refresh_biome_cache()
		queue_redraw()

@export var is_raid_override: bool = false
@export var world_seed: int = 0

@export_group("Visualization & Biome Overlay")
@export var show_biome_overlay: bool = true:
	set(val):
		show_biome_overlay = val
		queue_redraw()

@export var show_legend: bool = true:
	set(val):
		show_legend = val
		queue_redraw()

@export_range(0.05, 1.0, 0.05) var overlay_opacity: float = 0.35:
	set(val):
		overlay_opacity = val
		queue_redraw()

@export var show_spawn_area_gizmo: bool = true:
	set(val):
		show_spawn_area_gizmo = val
		queue_redraw()

@export_group("World Density (Don't Starve Style)")
## Использовать ли генерацию по насыщенности/плотности (как в Don't Starve).
## Количество ресурсов масштабируется от площади каждого биома.
@export var use_density_generation: bool = true

## Общий множитель насыщенности мира (0.5 = Редко, 1.0 = Норма, 1.5 = Густо)
@export_range(0.0, 3.0, 0.1) var global_density: float = 1.0

## Насыщенность деревьев в лесах и рощах
@export_range(0.0, 2.5, 0.1) var tree_density: float = 1.0

## Насыщенность пальм на пляже
@export_range(0.0, 2.5, 0.1) var palm_density: float = 1.0

## Насыщенность валунов и рудных камней
@export_range(0.0, 2.5, 0.1) var boulder_density: float = 1.0

## Насыщенность кустов и папоротников
@export_range(0.0, 2.5, 0.1) var bush_density: float = 1.0

## Насыщенность поваленных брёвен
@export_range(0.0, 2.5, 0.1) var log_density: float = 1.0

## Насыщенность собираемых ресурсов (ветки, мелкие камни)
@export_range(0.0, 2.5, 0.1) var gatherable_density: float = 1.0

@export_group("Spacing & Biome Buffers")
## Дистанция между деревьями (пиксели, 38px исключает наложение спрайтов крон деревьев и пальм)
@export var tree_min_dist: float = 38.0
@export var boulder_min_dist: float = 22.0
@export var bush_min_dist: float = 20.0
@export var log_min_dist: float = 28.0
@export var gatherable_min_dist: float = 16.0

## Буфер от границ чужих биомов (32px = 2 полных тайла).
## Полностью исключает спавн деревьев прямо на стыке разных биомов (например, берез в хвойном лесу)!
@export var biome_border_buffer: float = 32.0
@export var water_clearance_trees: float = 12.0
@export var water_clearance_palms: float = 14.0
@export var water_clearance_boulders: float = 8.0
@export var water_clearance_bushes: float = 8.0
@export var beach_border_clearance: float = 32.0

@export_group("Manual Counts Override (при use_density_generation = false)")
@export var tree_count: int = 48
@export var palm_count: int = 18
@export var boulder_count: int = 20
@export var bush_count: int = 14
@export var log_count: int = 6
@export var stick_count: int = 10
@export var small_stone_count: int = 8

var spawned_positions: Array[Vector2] = []
var _solid_obstacle_positions: Array[Vector2] = []
var _last_fail_reason: String = ""

# Кэш ячеек биомов для быстрой отрисовки и спавна
var _cached_biome_cells: Dictionary = {}
var _cached_biome_core_cells: Dictionary = {}
var _cached_ref_layer: TileMapLayer = null

const BIOME_PALETTE = {
	"clearing": Color(0.25, 0.85, 0.3),  # Луга: нежно-зеленый
	"forest":   Color(0.06, 0.52, 0.2),  # Лес: темно-изумрудный
	"dry":      Color(0.95, 0.72, 0.15), # Сухая трава / Березовый лес: золотисто-янтарный
	"beach":    Color(0.98, 0.88, 0.45), # Пляж: песчано-золотой
	"magic":    Color(0.75, 0.25, 0.95)  # Волшебная трава: фиолетовый
}

const BIOME_NAMES = {
	"clearing": "Луг / Поляны",
	"forest":   "Хвойный / Смешанный лес",
	"dry":      "Берёзовый лес (Сухая трава)",
	"beach":    "Песчаный пляж",
	"magic":    "Волшебный лес"
}

func _get_cached_scene(path: String) -> PackedScene:
	if ResourceLoader.exists(path):
		return load(path) as PackedScene
	push_warning("ResourceSpawner: Scene not found: " + path)
	return null

func _draw() -> void:
	if not Engine.is_editor_hint():
		return
		
	# 1. Отрисовка границы spawn_area
	if show_spawn_area_gizmo:
		var local_rect = Rect2(to_local(spawn_area.position), spawn_area.size)
		draw_rect(local_rect, Color(0.2, 0.8, 0.4, 0.08), true)
		draw_rect(local_rect, Color(0.2, 0.9, 0.4, 0.8), false, 2.0)
		
	# 2. Отрисовка цветной подсветки биомов
	if show_biome_overlay:
		if _cached_biome_cells.is_empty() or not is_instance_valid(_cached_ref_layer):
			_refresh_biome_cache()
			
		if is_instance_valid(_cached_ref_layer):
			for biome_key in BIOME_PALETTE.keys():
				if not _cached_biome_cells.has(biome_key):
					continue
				var cells: Array = _cached_biome_cells[biome_key]
				if cells.is_empty():
					continue
				var base_col: Color = BIOME_PALETTE[biome_key]
				var fill_col = Color(base_col.r, base_col.g, base_col.b, overlay_opacity)
				var border_col = Color(base_col.r, base_col.g, base_col.b, min(1.0, overlay_opacity + 0.3))
				
				for c in cells:
					var w_pos = _cached_ref_layer.to_global(_cached_ref_layer.map_to_local(c)) - Vector2(8, 8)
					var l_pos = to_local(w_pos)
					draw_rect(Rect2(l_pos, Vector2(16, 16)), fill_col, true)
					
		# 3. Отрисовка интерактивной легенды в верхнем углу spawn_area
		if show_legend and not _cached_biome_cells.is_empty():
			_draw_biome_legend()

func _draw_biome_legend() -> void:
	var local_start = to_local(spawn_area.position) + Vector2(16, 16)
	var font = ThemeDB.fallback_font
	var font_size = 12
	
	var active_biomes = []
	for b_key in BIOME_PALETTE.keys():
		var count = _cached_biome_cells.get(b_key, []).size()
		if count > 0:
			active_biomes.append({"key": b_key, "count": count})
			
	if active_biomes.is_empty():
		return
		
	var box_w = 260.0
	var box_h = 32.0 + active_biomes.size() * 20.0
	var box_rect = Rect2(local_start, Vector2(box_w, box_h))
	
	# Подложка легенды
	draw_rect(box_rect, Color(0.04, 0.06, 0.08, 0.85), true)
	draw_rect(box_rect, Color(0.3, 0.7, 0.9, 0.7), false, 1.5)
	
	# Заголовок легенды
	if font:
		draw_string(font, local_start + Vector2(12, 20), "Выделение биомов острова:", HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.9, 0.95, 1.0))
		
	var y_offset = 38.0
	for item in active_biomes:
		var b_key = item["key"]
		var count = item["count"]
		var col = BIOME_PALETTE[b_key]
		var swatch_pos = local_start + Vector2(12, y_offset - 10)
		
		# Цветной квадратик
		draw_rect(Rect2(swatch_pos, Vector2(12, 12)), col, true)
		draw_rect(Rect2(swatch_pos, Vector2(12, 12)), Color.WHITE, false, 1.0)
		
		# Название биома и число тайлов
		if font:
			var label_text = "%s: %d" % [BIOME_NAMES.get(b_key, b_key), count]
			draw_string(font, local_start + Vector2(30, y_offset), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size - 1, Color(0.85, 0.9, 0.95))
			
		y_offset += 20.0

func _refresh_biome_cache() -> void:
	var world_map = _get_world_map()
	if not world_map:
		_cached_biome_cells.clear()
		_cached_biome_core_cells.clear()
		_cached_ref_layer = null
		return
		
	var ground = world_map.get_node_or_null("GroundLayer") as TileMapLayer
	var shore = world_map.get_node_or_null("ShoreLayer") as TileMapLayer
	var grass = world_map.get_node_or_null("GrassLayer") as TileMapLayer
	
	_cached_ref_layer = ground if ground else (shore if shore else (grass if grass else world_map.get_child(0) as TileMapLayer))
	_cached_biome_cells = {
		"clearing": [],
		"forest": [],
		"dry": [],
		"magic": [],
		"beach": []
	}
	_cached_biome_core_cells = {
		"clearing": [],
		"forest": [],
		"dry": [],
		"magic": [],
		"beach": []
	}
	
	var all_cells_dict: Dictionary = {}
	if shore:
		for c in shore.get_used_cells():
			all_cells_dict[c] = true
	if ground:
		for c in ground.get_used_cells():
			all_cells_dict[c] = true
	if grass:
		for c in grass.get_used_cells():
			all_cells_dict[c] = true
			
	var cell_to_biome: Dictionary = {}
	for c in all_cells_dict.keys():
		# Определяем биом с соблюдением приоритета слоев: GrassLayer -> GroundLayer -> ShoreLayer
		var chosen_data: TileData = null
		var is_shore_only = false
		
		if grass and grass.get_cell_source_id(c) != -1:
			chosen_data = grass.get_cell_tile_data(c)
		elif ground and ground.get_cell_source_id(c) != -1:
			chosen_data = ground.get_cell_tile_data(c)
		elif shore and shore.get_cell_source_id(c) != -1:
			chosen_data = shore.get_cell_tile_data(c)
			is_shore_only = true
			
		var b = "clearing"
		if chosen_data:
			b = BiomeService._resolve_biome_from_cell(chosen_data)
			if is_shore_only and (b == "clearing" or b == "void"):
				b = "beach"
				
		cell_to_biome[c] = b
		if _cached_biome_cells.has(b):
			_cached_biome_cells[b].append(c)

	# Выделяем внутренние ячейки (Core Cells) — у которых все 8 соседей принадлежат тому же биому
	for b_name in _cached_biome_core_cells.keys():
		for c in _cached_biome_cells[b_name]:
			var is_core = true
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if dx == 0 and dy == 0: continue
					var nc = c + Vector2i(dx, dy)
					if not cell_to_biome.has(nc) or cell_to_biome[nc] != b_name:
						is_core = false
						break
				if not is_core:
					break
			if is_core:
				_cached_biome_core_cells[b_name].append(c)
			
	print("ResourceSpawner: Biome scan completed:")
	for k in _cached_biome_cells.keys():
		if _cached_biome_cells[k].size() > 0:
			var core_count = _cached_biome_core_cells.get(k, []).size()
			print("  - ", BIOME_NAMES.get(k, k), ": ", _cached_biome_cells[k].size(), " tiles (core: ", core_count, ")")

func _ready() -> void:
	if Engine.is_editor_hint():
		if auto_detect_spawn_area:
			_update_spawn_area()
		else:
			_refresh_biome_cache()
	else:
		await get_tree().process_frame
		var current_scene = get_tree().current_scene
		var is_home = _check_is_home(current_scene)
		
		if is_home:
			if _count_spawned_type("Spawned") == 0:
				_generate_all()
			else:
				_prune_border_violators()
				_replenish_home_resources()
			var gsm = get_node_or_null("/root/GameStateManager")
			if gsm:
				if not gsm.day_changed.is_connected(_on_day_changed):
					gsm.day_changed.connect(_on_day_changed)
		else:
			if _count_spawned_type("Spawned") == 0:
				_generate_all()
			else:
				_prune_border_violators()

func _check_is_home(scene: Node = null) -> bool:
	if is_raid_override:
		return false
	if not scene:
		scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not scene:
		return false
	return scene.name == "HomeIsland"

func _on_day_changed(_new_day: int) -> void:
	_replenish_home_resources()

func _count_spawned_type(prefix: String) -> int:
	var parent = _get_parent_node()
	if not parent: return 0
	var count = 0
	for child in parent.get_children():
		if is_instance_valid(child) and child.name.begins_with(prefix) and not child.is_queued_for_deletion():
			count += 1
	return count

func _clear_all() -> void:
	var parent_node = _get_parent_node()
	if not parent_node: return
	
	var to_remove = []
	for child in parent_node.get_children():
		if is_instance_valid(child) and child.name.begins_with("Spawned"):
			to_remove.append(child)
			
	for child in to_remove:
		parent_node.remove_child(child)
		child.queue_free()
		
	if spawned_positions == null:
		spawned_positions = []
	else:
		spawned_positions.clear()
	if _solid_obstacle_positions == null:
		_solid_obstacle_positions = []
	else:
		_solid_obstacle_positions.clear()
	print("ResourceSpawner: cleared all spawned resources.")

func _get_parent_node() -> Node:
	if is_inside_tree():
		var p = get_parent()
		if p:
			var inter = p.get_node_or_null("Interactables")
			if inter: return inter
			return p
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not current_scene: return null
	var parent_node = current_scene.get_node_or_null("Interactables")
	if not parent_node:
		parent_node = current_scene
	return parent_node

func _get_world_map() -> Node:
	if is_inside_tree():
		var p = get_parent()
		if p:
			var wm = p.get_node_or_null("WorldMap")
			if wm: return wm
		var root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
		if root:
			var wm = root.get_node_or_null("WorldMap")
			if wm: return wm
	return BiomeService.find_world_map(self)

func _update_spawn_area() -> void:
	var world_map = _get_world_map()
	if not world_map:
		push_warning("ResourceSpawner: WorldMap node not found.")
		return
		
	var ground = world_map.get_node_or_null("GroundLayer") as TileMapLayer
	var shore = world_map.get_node_or_null("ShoreLayer") as TileMapLayer
	var grass = world_map.get_node_or_null("GrassLayer") as TileMapLayer
	var cliffs = world_map.get_node_or_null("CliffsLayer") as TileMapLayer
	
	var ref = ground if ground else (shore if shore else (grass if grass else world_map.get_child(0) as TileMapLayer))
	if not ref:
		return

	var min_pos = Vector2(INF, INF)
	var max_pos = Vector2(-INF, -INF)
	var has_cells = false

	for layer in [ground, shore, grass, cliffs]:
		if layer:
			for c in layer.get_used_cells():
				has_cells = true
				var w_pos = layer.to_global(layer.map_to_local(c))
				min_pos.x = min(min_pos.x, w_pos.x - 8.0)
				min_pos.y = min(min_pos.y, w_pos.y - 8.0)
				max_pos.x = max(max_pos.x, w_pos.x + 8.0)
				max_pos.y = max(max_pos.y, w_pos.y + 8.0)

	if not has_cells:
		push_warning("ResourceSpawner: No land cells found on WorldMap layers.")
		return

	spawn_area = Rect2(min_pos, max_pos - min_pos)
	print("ResourceSpawner: auto-detected island territory = ", spawn_area)
	_refresh_biome_cache()
	queue_redraw()
	if Engine.is_editor_hint():
		notify_property_list_changed()

func _gather_candidate_cells(world_map: Node) -> Dictionary:
	_refresh_biome_cache()
	return {
		"biomes": _cached_biome_cells,
		"core_biomes": _cached_biome_core_cells,
		"ref_layer": _cached_ref_layer
	}

func _prune_border_violators() -> void:
	var parent_node = _get_parent_node()
	if not parent_node: return
	var world_map = _get_world_map()
	if not world_map: return
	
	var violators: Array[Node] = []
	for child in parent_node.get_children():
		if not is_instance_valid(child) or not child.name.begins_with("Spawned"):
			continue
		var res_id = ""
		if child.name.begins_with("SpawnedTree_"):
			res_id = "wood"
		elif child.name.begins_with("SpawnedPalm_"):
			res_id = "palm"
		elif child.name.begins_with("SpawnedStoneB_"):
			res_id = "boulder"
		elif child.name.begins_with("SpawnedBush_"):
			res_id = "bush"
		elif child.name.begins_with("SpawnedLog_"):
			res_id = "log"
		elif child.name.begins_with("SpawnedSmallStone_") or child.name.begins_with("SpawnedStick_"):
			# Летающие собираемые палки и мелкие камни упразднены - удаляем их
			violators.append(child)
			continue
			
		if res_id != "" and not _is_valid_spawn(child.global_position, world_map, res_id):
			violators.append(child)
			
	print("ResourceSpawner: Pruning ", violators.size(), " border violators...")
	for node in violators:
		parent_node.remove_child(node)
		node.queue_free()
	print("ResourceSpawner: Pruned ", violators.size(), " invalid nodes.")

func _reload_tileset() -> void:
	var new_ts = ResourceLoader.load("res://resources/cute_tileset.tres", "", ResourceLoader.CACHE_MODE_REPLACE) as TileSet
	if not new_ts:
		push_error("ResourceSpawner: failed to reload cute_tileset.tres")
		return
	var wm = _get_world_map()
	if wm:
		for child in wm.get_children():
			if child is TileMapLayer:
				child.tile_set = new_ts
	print("ResourceSpawner: RELOADED TILESET IN EDITOR! Source 52 tiles: ", (new_ts.get_source(52) as TileSetAtlasSource).get_tiles_count())

func _generate_all() -> void:
	print("ResourceSpawner: starting _generate_all...")
	_clear_all()
	
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not current_scene: return
	var is_home = _check_is_home(current_scene)
	
	var parent_node = _get_parent_node()
	var world_map = _get_world_map()
	if not world_map or not parent_node: return
	
	if auto_detect_spawn_area:
		_update_spawn_area()
		
	var candidate_data = _gather_candidate_cells(world_map)
	var biomes: Dictionary = candidate_data["biomes"]
	
	var total_cells = 0
	for k in biomes.keys():
		total_cells += biomes[k].size()
	if total_cells == 0:
		push_warning("ResourceSpawner: No valid land cells found in spawn area!")
		return
		
	var rng = RandomNumberGenerator.new()
	if world_seed != 0:
		rng.seed = world_seed
	elif is_home:
		rng.seed = 4242
	else:
		var gsm = get_node_or_null("/root/GameStateManager")
		if gsm and "current_raid_seed" in gsm and gsm.current_raid_seed != 0:
			rng.seed = gsm.current_raid_seed
		else:
			rng.randomize()
	
	if spawned_positions == null: spawned_positions = []
	else: spawned_positions.clear()
	if _solid_obstacle_positions == null: _solid_obstacle_positions = []
	else: _solid_obstacle_positions.clear()
	
	# На HomeIsland по умолчанию применяем умеренные стартовые количества
	var eff_trees = 14 if is_home else tree_count
	var eff_palms = 4 if is_home else palm_count
	var eff_boulders = 6 if is_home else boulder_count
	var eff_bushes = 6 if is_home else bush_count
	var eff_logs = 2 if is_home else log_count

	# 1. Деревья по биомам (дубы/ели/березы в лесу, только березы на сухой траве, дубы/плодовые на лугу)
	_spawn_inland_trees(eff_trees, is_home, parent_node, rng, candidate_data)
	
	# 2. Пальмы на песчаном пляже
	_spawn_beach_palms(eff_palms, is_home, parent_node, rng, candidate_data)
	
	# 3. Валуны и камни (распределяются по всему острову, типы 1-9 собираются как мелкие камни)
	_spawn_boulders(eff_boulders, is_home, parent_node, rng, candidate_data)
	
	# 4. Поваленные бревна (в лесах и на сухой траве)
	_spawn_fallen_logs(eff_logs, is_home, parent_node, rng, candidate_data)
	
	# 5. Кусты и папоротники (ягодные кусты, папоротники - основной источник веток)
	_spawn_bushes_and_ferns(eff_bushes, is_home, parent_node, rng, candidate_data)
	
	# 6. Летающие палки и мелкие камни упразднены: палки собираются с кустов, а камни — с лежащих на земле камней
	
	print("ResourceSpawner: generation complete! Total spawned: ", parent_node.get_child_count())

func _replenish_home_resources() -> void:
	# Летающие палки и мелкие камни упразднены.
	# Источники ресурсов в мире: кусты (палки), лежащие камни (камни), деревья (древесина).
	pass

func _get_radial_probe_offsets(radius: float) -> Array[Vector2]:
	var r1 = radius
	var d1 = r1 * 0.7071
	var r2 = radius * 0.5
	var d2 = r2 * 0.7071
	return [
		Vector2(r1, 0), Vector2(-r1, 0), Vector2(0, r1), Vector2(0, -r1),
		Vector2(d1, d1), Vector2(-d1, d1), Vector2(d1, -d1), Vector2(-d1, -d1),
		Vector2(r2, 0), Vector2(-r2, 0), Vector2(0, r2), Vector2(0, -r2),
		Vector2(d2, d2), Vector2(-d2, d2), Vector2(d2, -d2), Vector2(-d2, -d2)
	]

func _is_valid_spawn(pos: Vector2, world_map: Node, resource_id: String = "") -> bool:
	if not world_map: return true 
	
	var ground = world_map.get_node_or_null("GroundLayer")
	var roads = world_map.get_node_or_null("RoadsLayer")
	var objects = world_map.get_node_or_null("ObjectsLayer")
	var houses = world_map.get_node_or_null("HousesLayer")
	var cliffs = world_map.get_node_or_null("CliffsLayer")
	var mountains_tops = world_map.get_node_or_null("MountainsTopsLayer")
	var mountains_borders = world_map.get_node_or_null("MountainsBordersLayer")
	
	if not ground: return true
	
	var map_pos = ground.local_to_map(ground.to_local(pos))
	
	if roads and roads.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "roads"
		return false
	if objects and objects.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "objects"
		return false
	if houses and houses.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "houses"
		return false
	if cliffs and cliffs.get_cell_source_id(map_pos) != -1:
		_last_fail_reason = "cliffs"
		return false
	if mountains_borders and mountains_borders.get_cell_source_id(map_pos) != -1: 
		_last_fail_reason = "mountains_borders"
		return false
	
	# Защита зоны лагеря на HomeIsland (палатка и спавн игрока)
	var current_scene = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	var is_home = _check_is_home(current_scene)
	if is_home:
		var camp_pos = Vector2(390, 132) # Tent
		var player_pos = Vector2(420, 146)
		if pos.distance_to(camp_pos) < 70.0 or pos.distance_to(player_pos) < 50.0:
			if resource_id != "stick" and resource_id != "stone":
				_last_fail_reason = "too close to camp"
				return false

	var tile_info = BiomeService.get_top_tile_info(pos, world_map)
	var on_ground = (tile_info.layer_name in ["GroundLayer", "ShoreLayer", "GrassLayer"])
	var on_mountain = (mountains_tops and mountains_tops.get_cell_source_id(map_pos) != -1)
	
	if not on_ground and not on_mountain:
		_last_fail_reason = "not on ground or mountain (tile=" + tile_info.biome + ")"
		return false
		
	if tile_info.is_water:
		_last_fail_reason = "in water"
		return false
		
	# 1. ПРОВЕРКА БУФЕРА ВОДЫ
	var water_check_radius = 0.0
	if resource_id == "wood":
		water_check_radius = water_clearance_trees
	elif resource_id == "palm":
		water_check_radius = water_clearance_palms
	elif resource_id in ["boulder", "log"]:
		water_check_radius = water_clearance_boulders
	elif resource_id == "bush":
		water_check_radius = water_clearance_bushes
	elif resource_id in ["stick", "stone"]:
		water_check_radius = 6.0
	
	if water_check_radius > 0.0:
		var water_offsets = _get_radial_probe_offsets(water_check_radius)
		for off in water_offsets:
			if BiomeService.is_water_at(pos + off, world_map):
				_last_fail_reason = "too close to water edge"
				return false

	# 2. ПРОВЕРКА ГРАНИЦЫ ПЛЯЖ / ТРАВА И МЕЖДУ БИОМАМИ
	if tile_info.biome == "transition":
		_last_fail_reason = "on transition tile"
		return false

	if tile_info.biome == "beach":
		if resource_id == "palm":
			# Пальма на пляже: не должна стоять на стыке с материковой травой (clearing, forest, dry, magic, transition)
			var beach_probes = _get_radial_probe_offsets(beach_border_clearance)
			for off in beach_probes:
				var b = BiomeService.get_biome_at(pos + off, world_map)
				if b in ["clearing", "forest", "dry", "magic", "transition"]:
					_last_fail_reason = "palm too close to grass border (%s)" % b
					return false
		elif resource_id in ["boulder", "bush"]:
			# На пляже валуны и кусты не должны касаться материковой травы (буфер 24px)
			var beach_b_probes = _get_radial_probe_offsets(24.0)
			for off in beach_b_probes:
				var b = BiomeService.get_biome_at(pos + off, world_map)
				if b in ["clearing", "forest", "dry", "magic", "transition"]:
					_last_fail_reason = "%s on beach too close to grass (%s)" % [resource_id, b]
					return false
		elif resource_id in ["stone", "stick"]:
			# На пляже мелкие камни не должны касаться материковой травы (буфер 16px)
			var beach_g_probes = _get_radial_probe_offsets(16.0)
			for off in beach_g_probes:
				var b = BiomeService.get_biome_at(pos + off, world_map)
				if b in ["clearing", "forest", "dry", "magic", "transition"]:
					_last_fail_reason = "%s on beach too close to grass (%s)" % [resource_id, b]
					return false
		else:
			# Обычные деревья, бревна и ветки не спавнятся на пляже
			_last_fail_reason = "sand/beach tile"
			return false
	else:
		# На материковой траве (clearing, forest, dry, magic):
		if resource_id == "wood":
			# Дерево не может быть на слое берега ShoreLayer
			if tile_info.layer_name == "ShoreLayer":
				_last_fail_reason = "tree on shore layer"
				return false
				
			# 1) Буфер с пляжем/водой/пустотой/переходом (по всем 16 направлениям на глубину beach_border_clearance)
			var border_probes = _get_radial_probe_offsets(beach_border_clearance)
			for off in border_probes:
				var b = BiomeService.get_biome_at(pos + off, world_map)
				if b in ["beach", "water", "void", "ocean", "transition"]:
					_last_fail_reason = "tree too close to beach border (%s)" % b
					return false
			
			# 2) Буфер между материковыми биомами (чтобы березы не спавнились на стыке с хвойным лесом)
			if biome_border_buffer > 0.0:
				var inland_offsets = _get_radial_probe_offsets(biome_border_buffer)
				for off in inland_offsets:
					var nb = BiomeService.get_biome_at(pos + off, world_map)
					if nb != tile_info.biome:
						_last_fail_reason = "tree too close to biome boundary (%s -> %s)" % [tile_info.biome, nb]
						return false
		elif resource_id == "log":
			var log_offsets = _get_radial_probe_offsets(24.0)
			for off in log_offsets:
				var nb = BiomeService.get_biome_at(pos + off, world_map)
				if nb in ["beach", "water", "void", "ocean", "transition"] or nb != tile_info.biome:
					_last_fail_reason = "log on biome boundary (%s)" % nb
					return false
		elif resource_id in ["boulder", "bush"]:
			# Валуны и кусты на материке тоже не должны стоять на стыках! (буфер 24px)
			var item_offsets = _get_radial_probe_offsets(24.0)
			for off in item_offsets:
				var nb = BiomeService.get_biome_at(pos + off, world_map)
				if nb in ["beach", "water", "void", "ocean", "transition"]:
					_last_fail_reason = "%s too close to beach border (%s)" % [resource_id, nb]
					return false
				if nb != tile_info.biome:
					_last_fail_reason = "%s on biome boundary (%s -> %s)" % [resource_id, tile_info.biome, nb]
					return false
		elif resource_id in ["stick", "stone"]:
			var g_offsets = _get_radial_probe_offsets(16.0)
			for off in g_offsets:
				var nb = BiomeService.get_biome_at(pos + off, world_map)
				if nb in ["beach", "water", "void", "ocean", "transition"]:
					_last_fail_reason = "%s too close to beach/water border (%s)" % [resource_id, nb]
					return false
		elif resource_id == "palm":
			return false # Пальмы только на пляже!
			
	return true

func _assign_node_owner(inst: Node, parent_node: Node) -> void:
	var scene_root: Node = null
	if Engine.is_editor_hint() and get_tree().edited_scene_root:
		scene_root = get_tree().edited_scene_root
	elif is_inside_tree() and get_tree().current_scene:
		scene_root = get_tree().current_scene
	elif parent_node and parent_node.owner:
		scene_root = parent_node.owner
	elif parent_node:
		scene_root = parent_node
	if scene_root and is_instance_valid(scene_root) and inst != scene_root:
		inst.owner = scene_root

func _spawn_inland_trees(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, candidate_data: Dictionary) -> void:
	var biomes: Dictionary = candidate_data["biomes"]
	var ref_layer: TileMapLayer = candidate_data["ref_layer"]
	var world_map = _get_world_map()
	
	var inland_keys = ["forest", "dry", "clearing", "magic"]
	var active_biomes: Array[String] = []
	var total_inland_cells = 0
	
	for b_key in inland_keys:
		if biomes.has(b_key) and biomes[b_key].size() > 0:
			active_biomes.append(b_key)
			total_inland_cells += biomes[b_key].size()
			
	if active_biomes.is_empty() or total_inland_cells == 0:
		return
		
	var tree_sizes = ["small", "medium", "big"]
	var total_spawned = 0
	var home_factor: float = 0.55 if is_home else 1.0
	
	# Базовая плотность деревьев на тайл для каждого биома (Don't Starve balance):
	# В густом хвойном лесу деревьев много, в березовой роще умеренно, на лугах просторно
	var biome_base_densities = {
		"forest":   0.052, # ~1 дерево на 19 тайлов
		"dry":      0.042, # ~1 береза на 24 тайла (березовая роща)
		"clearing": 0.016, # ~1 дерево на 60 тайлов (открытые луга с редкими дубами/плодовыми)
		"magic":    0.038  # ~1 дерево на 26 тайлов
	}
	
	for b_key in active_biomes:
		var b_cells: Array = biomes[b_key]
		var b_target: int = 0
		
		if use_density_generation:
			var base_rate = biome_base_densities.get(b_key, 0.03)
			b_target = int(round(b_cells.size() * base_rate * tree_density * global_density * home_factor))
			if b_cells.size() >= 25 and b_target == 0 and tree_density > 0.1 and global_density > 0.1:
				b_target = 1
		else:
			var share: float = float(b_cells.size()) / float(total_inland_cells)
			b_target = max(1, int(round(share * amount)))
			
		var core_cells: Array = candidate_data.get("core_biomes", {}).get(b_key, [])
		var pool: Array = core_cells if core_cells.size() >= 8 else b_cells
		
		var b_spawned = 0
		var b_attempts = 0
		var b_max_attempts = b_target * 100
		
		while b_spawned < b_target and b_attempts < b_max_attempts:
			b_attempts += 1
			var c = pool[rng.randi() % pool.size()]
			var center = ref_layer.to_global(ref_layer.map_to_local(c))
			var test_pos = center + Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
			
			if not _is_valid_spawn(test_pos, world_map, "wood"):
				continue
				
			var current_b = BiomeService.get_biome_at(test_pos, world_map)
			# Дерево должно строго принадлежать текущему биому (без смешивания на стыках)
			if current_b != b_key:
				continue
				
			var too_close = false
			for p in _solid_obstacle_positions:
				if p.distance_to(test_pos) < tree_min_dist:
					too_close = true
					break
			if too_close:
				continue
				
			_solid_obstacle_positions.append(test_pos)
			spawned_positions.append(test_pos)
			
			var scene_path = ""
			var prefix = "SpawnedTree_"
			
			if current_b == "dry":
				# В сухом биоме — ТОЛЬКО березы!
				var t_size = tree_sizes[rng.randi() % tree_sizes.size()]
				scene_path = "res://scenes/objects/trees/" + t_size + "_birch.tscn"
				prefix = "SpawnedTree_DryBirch_"
			elif current_b == "forest":
				# В хвойном лесу — ели и лесные дубы (без берез!)
				var forest_types = ["spruce", "spruce", "oak"]
				var t_type = forest_types[rng.randi() % forest_types.size()]
				var t_size = tree_sizes[rng.randi() % tree_sizes.size()]
				scene_path = "res://scenes/objects/trees/" + t_size + "_" + t_type + ".tscn"
				prefix = "SpawnedTree_Forest_"
			elif current_b == "magic":
				var magic_types = ["spruce", "fruit"]
				var t_type = magic_types[rng.randi() % magic_types.size()]
				var t_size = tree_sizes[rng.randi() % tree_sizes.size()]
				scene_path = "res://scenes/objects/trees/" + t_size + "_" + t_type + ".tscn"
				prefix = "SpawnedTree_Magic_"
			else:
				# На лугах — луговые дубы и фруктовые деревья
				var meadow_types = ["oak", "fruit"]
				var t_type = meadow_types[rng.randi() % meadow_types.size()]
				var t_size = tree_sizes[rng.randi() % tree_sizes.size()]
				scene_path = "res://scenes/objects/trees/" + t_size + "_" + t_type + ".tscn"
				prefix = "SpawnedTree_Meadow_"
				
			var obj_scene = _get_cached_scene(scene_path)
			if not obj_scene: continue
			
			var inst = obj_scene.instantiate()
			inst.name = prefix + str(total_spawned)
			inst.global_position = test_pos
			parent_node.add_child(inst)
			_assign_node_owner(inst, parent_node)
			b_spawned += 1
			total_spawned += 1
			
	print("Spawned ", total_spawned, " Inland Trees across biomes")

func _spawn_beach_palms(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, candidate_data: Dictionary) -> void:
	var biomes: Dictionary = candidate_data["biomes"]
	var beach_cells: Array = biomes.get("beach", [])
	if beach_cells.is_empty(): return
	var ref_layer: TileMapLayer = candidate_data["ref_layer"]
	var world_map = _get_world_map()
	
	var home_factor: float = 0.6 if is_home else 1.0
	var target_palms = 0
	if use_density_generation:
		var base_rate = 0.035 # ~1 пальма на 28 песчаных тайлов
		target_palms = int(round(beach_cells.size() * base_rate * palm_density * global_density * home_factor))
		if beach_cells.size() >= 15 and target_palms == 0 and palm_density > 0.1 and global_density > 0.1:
			target_palms = 1
	else:
		target_palms = 4 if is_home else amount
		
	var core_beach: Array = candidate_data.get("core_biomes", {}).get("beach", [])
	var palm_pool: Array = core_beach if core_beach.size() >= 8 else beach_cells
	
	var spawned = 0
	var attempts = 0
	var max_attempts = target_palms * 100
	
	while spawned < target_palms and attempts < max_attempts:
		attempts += 1
		var c = palm_pool[rng.randi() % palm_pool.size()]
		var center = ref_layer.to_global(ref_layer.map_to_local(c))
		var test_pos = center + Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
		
		if not _is_valid_spawn(test_pos, world_map, "palm"):
			continue
			
		var too_close = false
		for p in _solid_obstacle_positions:
			if p.distance_to(test_pos) < tree_min_dist:
				too_close = true
				break
		if too_close:
			continue
			
		_solid_obstacle_positions.append(test_pos)
		spawned_positions.append(test_pos)
		
		var palm_idx = rng.randi_range(1, 2)
		var scene_path = "res://scenes/objects/trees/palm_tree_%d.tscn" % palm_idx
		var obj_scene = _get_cached_scene(scene_path)
		if not obj_scene: continue
		
		var inst = obj_scene.instantiate()
		inst.name = "SpawnedPalm_Beach_" + str(spawned)
		inst.global_position = test_pos
		parent_node.add_child(inst)
		_assign_node_owner(inst, parent_node)
		spawned += 1
		
	print("Spawned ", spawned, " Beach Palms")

func _spawn_boulders(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, candidate_data: Dictionary) -> void:
	var biomes: Dictionary = candidate_data["biomes"]
	var ref_layer: TileMapLayer = candidate_data["ref_layer"]
	var world_map = _get_world_map()
	
	var all_keys = ["beach", "clearing", "forest", "dry", "magic"]
	var active_keys: Array[String] = []
	var total_land_cells = 0
	for k in all_keys:
		if biomes.has(k) and biomes[k].size() > 0:
			active_keys.append(k)
			total_land_cells += biomes[k].size()
			
	if active_keys.is_empty() or total_land_cells == 0: return
	
	var home_factor: float = 0.6 if is_home else 1.0
	var spawned = 0
	
	var boulder_rates = {
		"beach":    0.024,
		"dry":      0.024,
		"forest":   0.020,
		"magic":    0.020,
		"clearing": 0.012
	}
	
	for b_key in active_keys:
		var b_cells: Array = biomes[b_key]
		var b_target: int = 0
		
		if use_density_generation:
			var base_rate = boulder_rates.get(b_key, 0.018)
			b_target = int(round(b_cells.size() * base_rate * boulder_density * global_density * home_factor))
			if b_cells.size() >= 30 and b_target == 0 and boulder_density > 0.1 and global_density > 0.1:
				b_target = 1
		else:
			var share = float(b_cells.size()) / float(total_land_cells)
			b_target = max(1, int(round(share * amount)))
			
		if b_target <= 0:
			continue
			
		var core_cells: Array = candidate_data.get("core_biomes", {}).get(b_key, [])
		var pool: Array = core_cells if core_cells.size() >= 8 else b_cells
		
		var b_spawned = 0
		var b_attempts = 0
		var b_max_attempts = b_target * 80
		
		while b_spawned < b_target and b_attempts < b_max_attempts:
			b_attempts += 1
			var c = pool[rng.randi() % pool.size()]
			var center = ref_layer.to_global(ref_layer.map_to_local(c))
			var test_pos = center + Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
			
			if not _is_valid_spawn(test_pos, world_map, "boulder"):
				continue
				
			var too_close = false
			for p in _solid_obstacle_positions:
				if p.distance_to(test_pos) < boulder_min_dist:
					too_close = true
					break
			if too_close:
				continue
				
			_solid_obstacle_positions.append(test_pos)
			spawned_positions.append(test_pos)
			
			var stone_idx = rng.randi_range(1, 14)
			var scene_path = "res://scenes/objects/stones/stone_%d.tscn" % stone_idx
			var obj_scene = _get_cached_scene(scene_path)
			if not obj_scene: continue
			
			var b = BiomeService.get_biome_at(test_pos, world_map)
			var prefix = "SpawnedStoneB_" + b.capitalize() + "_"
			var inst = obj_scene.instantiate()
			inst.name = prefix + str(spawned)
			inst.global_position = test_pos
			if "is_permanent" in inst:
				inst.is_permanent = is_home
				
			parent_node.add_child(inst)
			_assign_node_owner(inst, parent_node)
			b_spawned += 1
			spawned += 1
			
	print("Spawned ", spawned, " Boulders / Stones across island")

func _spawn_fallen_logs(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, candidate_data: Dictionary) -> void:
	var biomes: Dictionary = candidate_data["biomes"]
	var log_cells: Array = []
	for b_key in ["forest", "dry", "clearing"]:
		if biomes.has(b_key):
			log_cells.append_array(biomes[b_key])
	if log_cells.is_empty(): return
	var ref_layer: TileMapLayer = candidate_data["ref_layer"]
	var world_map = _get_world_map()
	
	var home_factor: float = 0.5 if is_home else 1.0
	var target_logs = 0
	if use_density_generation:
		var base_rate = 0.007 # ~1 бревно на 140 тайлов (редкий атмосферный элемент)
		target_logs = int(round(log_cells.size() * base_rate * log_density * global_density * home_factor))
		if log_cells.size() >= 50 and target_logs == 0 and log_density > 0.1 and global_density > 0.1:
			target_logs = 1
	else:
		target_logs = 2 if is_home else amount
		
	if target_logs <= 0:
		return
		
	var log_scenes = [
		"res://scenes/objects/decor/fallen_log_horizontal.tscn",
		"res://scenes/objects/decor/fallen_log_vertical.tscn"
	]
	var spawned = 0
	var attempts = 0
	var max_attempts = target_logs * 80
	
	while spawned < target_logs and attempts < max_attempts:
		attempts += 1
		var c = log_cells[rng.randi() % log_cells.size()]
		var center = ref_layer.to_global(ref_layer.map_to_local(c))
		var test_pos = center + Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
		
		if not _is_valid_spawn(test_pos, world_map, "log"):
			continue
			
		var biome = BiomeService.get_biome_at(test_pos, world_map)
		if biome in ["beach", "water", "void", "ocean"]:
			continue
			
		var too_close = false
		for p in _solid_obstacle_positions:
			if p.distance_to(test_pos) < log_min_dist:
				too_close = true
				break
		if too_close:
			continue
			
		_solid_obstacle_positions.append(test_pos)
		spawned_positions.append(test_pos)
		
		var scene_path = log_scenes[rng.randi() % log_scenes.size()]
		var obj_scene = _get_cached_scene(scene_path)
		if not obj_scene: continue
		
		var inst = obj_scene.instantiate()
		inst.name = "SpawnedLog_" + biome.capitalize() + "_" + str(spawned)
		inst.global_position = test_pos
		parent_node.add_child(inst)
		_assign_node_owner(inst, parent_node)
		spawned += 1
		
	print("Spawned ", spawned, " Fallen Logs")

func _spawn_bushes_and_ferns(amount: int, is_home: bool, parent_node: Node, rng: RandomNumberGenerator, candidate_data: Dictionary) -> void:
	var biomes: Dictionary = candidate_data["biomes"]
	var all_land: Array = []
	for k in biomes.keys():
		all_land.append_array(biomes[k])
	if all_land.is_empty(): return
	var ref_layer: TileMapLayer = candidate_data["ref_layer"]
	var world_map = _get_world_map()
	
	var home_factor: float = 0.6 if is_home else 1.0
	var target_bushes = 0
	if use_density_generation:
		var base_rate = 0.022 # ~1 куст на 45 тайлов
		target_bushes = int(round(all_land.size() * base_rate * bush_density * global_density * home_factor))
		if all_land.size() >= 30 and target_bushes == 0 and bush_density > 0.1 and global_density > 0.1:
			target_bushes = 1
	else:
		target_bushes = 6 if is_home else amount
		
	if target_bushes <= 0:
		return
		
	var all_core_land: Array = []
	var core_biomes: Dictionary = candidate_data.get("core_biomes", {})
	for k in core_biomes.keys():
		all_core_land.append_array(core_biomes[k])
	var bush_pool: Array = all_core_land if all_core_land.size() >= 15 else all_land

	var spawned = 0
	var attempts = 0
	var max_attempts = target_bushes * 60
	
	while spawned < target_bushes and attempts < max_attempts:
		attempts += 1
		var c = bush_pool[rng.randi() % bush_pool.size()]
		var center = ref_layer.to_global(ref_layer.map_to_local(c))
		var test_pos = center + Vector2(rng.randf_range(-2, 2), rng.randf_range(-2, 2))
		
		if not _is_valid_spawn(test_pos, world_map, "bush"):
			continue
			
		var too_close = false
		for p in spawned_positions:
			if p.distance_to(test_pos) < bush_min_dist:
				too_close = true
				break
		if too_close:
			continue
			
		spawned_positions.append(test_pos)
		
		var biome = BiomeService.get_biome_at(test_pos, world_map)
		var scene_path = ""
		
		if biome == "dry":
			var dry_bushes = [
				"res://scenes/objects/bushes/desert_fern_dead.tscn",
				"res://scenes/objects/bushes/desert_fern_dead.tscn",
				"res://scenes/objects/bushes/plain_bush.tscn",
				"res://scenes/objects/bushes/desert_fern.tscn"
			]
			scene_path = dry_bushes[rng.randi() % dry_bushes.size()]
		elif biome == "forest":
			var forest_bushes = [
				"res://scenes/objects/bushes/desert_fern.tscn",
				"res://scenes/objects/bushes/plain_bush.tscn",
				"res://scenes/objects/bushes/berry_bush_red.tscn",
				"res://scenes/objects/bushes/berry_bush_purple.tscn"
			]
			scene_path = forest_bushes[rng.randi() % forest_bushes.size()]
		elif biome == "beach":
			scene_path = "res://scenes/objects/bushes/desert_fern_dead.tscn"
		else:
			var meadow_bushes = [
				"res://scenes/objects/bushes/berry_bush_red.tscn",
				"res://scenes/objects/bushes/berry_bush_purple.tscn",
				"res://scenes/objects/bushes/plain_bush.tscn",
				"res://scenes/objects/bushes/desert_fern.tscn"
			]
			scene_path = meadow_bushes[rng.randi() % meadow_bushes.size()]
			
		var obj_scene = _get_cached_scene(scene_path)
		if not obj_scene: continue
		
		var inst = obj_scene.instantiate()
		inst.name = "SpawnedBush_" + biome.capitalize() + "_" + str(spawned)
		inst.global_position = test_pos
		parent_node.add_child(inst)
		_assign_node_owner(inst, parent_node)
		spawned += 1
		
	print("Spawned ", spawned, " Bushes & Ferns")

# Метод упразднен: летающие палки и камни больше не спавнятся.
func _spawn_gatherables(_stick_amt: int, _stone_amt: int, _is_home: bool, _parent_node: Node, _rng: RandomNumberGenerator, _candidate_data: Dictionary) -> void:
	pass

