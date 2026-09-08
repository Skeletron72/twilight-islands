@tool
extends Area2D
class_name BiomeZone

@export var biome_name: String = "clearing"
@export var debug_color: Color = Color(0.2, 0.8, 0.2, 0.3):
	set(val):
		debug_color = val
		_update_visuals()

@export_group("Auto Generation")
@export var object_scenes: Array[PackedScene] = []
@export var total_spawn_count: int = 20
@export var min_distance: float = 24.0
@export var generate_objects: bool = false:
	set(val):
		if val:
			generate_objects = false
			_generate_objects()

var visual_polygon: Polygon2D

func _ready() -> void:
	y_sort_enabled = true
	if not Engine.is_editor_hint():
		if has_node("VisualPolygon"):
			$VisualPolygon.visible = false
		
	collision_layer = 0
	collision_mask = 1 
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)
		
	_update_visuals()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_visuals()

func _update_visuals() -> void:
	var col_poly = get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if not col_poly or col_poly.polygon.is_empty(): return
	
	if not visual_polygon:
		visual_polygon = get_node_or_null("VisualPolygon")
		if not visual_polygon:
			visual_polygon = Polygon2D.new()
			visual_polygon.name = "VisualPolygon"
			add_child(visual_polygon)
			if Engine.is_editor_hint():
				var scene_owner = owner if owner else (get_tree().edited_scene_root if get_tree() else null)
				if scene_owner:
					visual_polygon.owner = scene_owner
				
	visual_polygon.polygon = col_poly.polygon
	visual_polygon.color = debug_color
	visual_polygon.position = col_poly.position
	visual_polygon.z_index = -10

func _generate_objects() -> void:
	print("--- BiomeZone '", name, "' (", biome_name, ") generating objects ---")
	var col_poly = get_node_or_null("CollisionPolygon2D") as CollisionPolygon2D
	if not col_poly or col_poly.polygon.is_empty():
		print("ERROR: CollisionPolygon2D is missing or empty!")
		return
	
	if object_scenes.is_empty(): 
		print("ERROR: No scenes assigned in object_scenes!")
		return
		
	var scene_owner = owner
	if not scene_owner and Engine.is_editor_hint() and get_tree():
		scene_owner = get_tree().edited_scene_root
		
	# Удаляем старые авто-сгенерированные объекты
	for child in get_children():
		if child.has_meta("auto_generated"):
			child.queue_free()
			
	var poly = col_poly.polygon
	var min_x = poly[0].x; var max_x = poly[0].x
	var min_y = poly[0].y; var max_y = poly[0].y
	for p in poly:
		if p.x < min_x: min_x = p.x
		if p.x > max_x: max_x = p.x
		if p.y < min_y: min_y = p.y
		if p.y > max_y: max_y = p.y
		
	var spawned_positions: Array[Vector2] = []
	for child in get_children():
		if child is Node2D and not child is CollisionPolygon2D and not child is Polygon2D:
			spawned_positions.append(child.position)
			
	var spawned = 0
	var attempts = 0
	var max_attempts = total_spawn_count * 100
	
	while spawned < total_spawn_count and attempts < max_attempts:
		attempts += 1
		var pt = Vector2(randf_range(min_x, max_x), randf_range(min_y, max_y))
		
		if Geometry2D.is_point_in_polygon(pt, poly):
			if BiomeService.is_water_at(to_global(pt)):
				continue
			var too_close = false
			for pos in spawned_positions:
				if pt.distance_to(pos) < min_distance:
					too_close = true
					break
					
			if not too_close:
				var scene = object_scenes.pick_random()
				if scene:
					var inst = scene.instantiate()
					inst.position = pt
					inst.set_meta("auto_generated", true)
					add_child(inst)
					if scene_owner:
						inst.owner = scene_owner
					spawned_positions.append(pt)
					spawned += 1
					
	print("Biome '", biome_name, "': Successfully spawned ", spawned, "/", total_spawn_count, " objects.")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if "current_biome" in body:
			body.current_biome = biome_name

func _on_body_exited(body: Node2D) -> void:
	pass
