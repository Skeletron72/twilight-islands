extends Node2D

var is_placing: bool = false
var current_item_id: String = ""
var ghost_container: Node2D = null
var _was_pressed: bool = false
var current_rotation: int = 0

# Лимит дальности размещения (в пикселях от игрока) ~ 3.5 - 4 тайла
const MAX_PLACEMENT_DISTANCE: float = 64.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 4096
	z_as_relative = false
	
	ghost_container = Node2D.new()
	ghost_container.name = "GhostContainer"
	ghost_container.z_index = 4096
	ghost_container.z_as_relative = false
	add_child(ghost_container)
	ghost_container.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not is_placing: return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_rotate_placement()

func _rotate_placement() -> void:
	current_rotation = (current_rotation + 1) % 3
	for child in ghost_container.get_children():
		if child.has_method("set_direction"):
			child.set_direction(current_rotation)
	queue_redraw()

func start_placement(item_id: String) -> void:
	current_item_id = item_id
	current_rotation = 0
	is_placing = true
	_build_ghost_preview(item_id)
	ghost_container.visible = true
	queue_redraw()

func stop_placement() -> void:
	is_placing = false
	current_item_id = ""
	current_rotation = 0
	ghost_container.visible = false
	_clear_ghost_preview()
	queue_redraw()

func _clear_ghost_preview() -> void:
	for child in ghost_container.get_children():
		child.queue_free()

func _build_ghost_preview(item_id: String) -> void:
	_clear_ghost_preview()
	
	var item = ItemDB.get_item(item_id)
	if item.has("scene"):
		var packed_scene = load(item["scene"]) as PackedScene
		if packed_scene:
			var instance = packed_scene.instantiate()
			if instance.has_method("set_direction"):
				instance.set_direction(current_rotation)
			_neutralize_ghost_node(instance)
			ghost_container.add_child(instance)
			return
			
	# Запасной вариант (если у предмета нет сцены) — иконка
	var icon_sprite = Sprite2D.new()
	var icon = ItemDB.get_icon(item_id)
	if icon:
		icon_sprite.texture = icon
	ghost_container.add_child(icon_sprite)

func _neutralize_ghost_node(node: Node) -> void:
	# Отключаем физику, обработку и коллизии у превью-копии объекта
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_input(false)
	
	if node is CollisionObject2D:
		node.collision_layer = 0
		node.collision_mask = 0
	if node is CollisionShape2D or node is CollisionPolygon2D:
		node.disabled = true
	elif node is PointLight2D:
		node.enabled = false
	elif node is AudioStreamPlayer or node is AudioStreamPlayer2D:
		node.stop()
	elif node is AnimationPlayer:
		node.stop()
		
	# Рекурсивно обрабатываем всех потомков
	for child in node.get_children():
		_neutralize_ghost_node(child)

func _process(delta: float) -> void:
	if not is_placing: return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_2d()
	var world_pos = mouse_pos
	if camera:
		world_pos = (mouse_pos - get_viewport().get_visible_rect().size / 2.0) / camera.zoom + camera.global_position
		
	var is_in_tent = false
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		is_in_tent = player.global_position.distance_to(TentManager.INTERIOR_POS) < 350.0
		
	var target_pos: Vector2
	if is_in_tent:
		# Внутри шатра сетка 8x8, выровненная по центру шатра (позволяет ставить вплотную к стенам: x = -16, -8, 0, 8, 16)
		var rel = world_pos - TentManager.INTERIOR_POS
		var sx = round(rel.x / 8.0) * 8.0
		var sy = round(rel.y / 8.0) * 8.0
		target_pos = TentManager.INTERIOR_POS + Vector2(sx, sy)
	else:
		# Сетка 16x16 в открытом мире
		var snapped_x = floor(world_pos.x / 16.0) * 16.0 + 8.0
		var snapped_y = floor(world_pos.y / 16.0) * 16.0 + 8.0
		target_pos = Vector2(snapped_x, snapped_y)
	
	ghost_container.global_position = target_pos
	
	var can_place = _can_place_at(target_pos)
	if can_place:
		# Полупрозрачный зелёный цвет — можно строить
		ghost_container.modulate = Color(0.35, 1.0, 0.35, 0.8)
	else:
		# Полупрозрачный красный цвет — вне радиуса или занято
		ghost_container.modulate = Color(1.0, 0.25, 0.25, 0.7)
		
	queue_redraw()
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _was_pressed:
			_was_pressed = true
			
			# Проверка, открыто ли меню (книга, сундук и т.д.)
			var ui_layer = get_tree().current_scene.get_node_or_null("UILayer")
			if ui_layer:
				var book = ui_layer.get_node_or_null("BookUI")
				if book and book.visible: return
				var storage = ui_layer.get_node_or_null("StorageUI")
				if storage and storage.visible: return
				
			if can_place:
				_place_object(target_pos)
	else:
		_was_pressed = false

func _can_place_at(pos: Vector2) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return false
		
	# Проверка строгого лимита дальности
	if player.global_position.distance_to(pos) > MAX_PLACEMENT_DISTANCE:
		return false
		
	# Проверка: находится ли игрок внутри палатки?
	var is_in_tent = player.global_position.distance_to(TentManager.INTERIOR_POS) < 350.0
	if is_in_tent:
		# Нельзя строить палатку внутри палатки
		if current_item_id == "tent":
			return false
			
		var local_p = pos - TentManager.INTERIOR_POS
		# Допустимая область пола шатра (вплотную к стенам)
		if abs(local_p.x) > 20.0 or local_p.y < -26.0 or local_p.y > 36.0:
			return false
			
	# Проверка коллизий с препятствиями (слой 1=стены/окружение, слой 4=постройки/кровати/ящики)
	var space = get_world_2d().direct_space_state
	var excludes: Array[RID] = []
	if player and player is CollisionObject2D:
		excludes.append(player.get_rid())
	for child in ghost_container.get_children():
		if child is CollisionObject2D:
			excludes.append(child.get_rid())
		for sub in child.get_children():
			if sub is CollisionObject2D:
				excludes.append(sub.get_rid())

	# 1. Проверяем реальную физическую форму объекта через intersect_shape
	var ghost = ghost_container.get_child(0) if ghost_container.get_child_count() > 0 else null
	var ghost_shapes: Array[Dictionary] = []
	if ghost:
		ghost_shapes = _get_ghost_shapes(ghost)

	var check_mask = 1 | 4 # Физические препятствия и постройки (без триггеров слоя 2)

	if ghost_shapes.size() > 0:
		for s_info in ghost_shapes:
			var query = PhysicsShapeQueryParameters2D.new()
			query.shape = s_info["shape"]
			query.transform = Transform2D(0.0, pos) * s_info["transform"]
			query.collision_mask = check_mask
			query.exclude = excludes
			var hits = space.intersect_shape(query)
			if hits.size() > 0:
				return false
	else:
		# Резервная проверка через прямоугольник 14x14
		var fallback_shape = RectangleShape2D.new()
		fallback_shape.size = Vector2(14, 14)
		var query = PhysicsShapeQueryParameters2D.new()
		query.shape = fallback_shape
		query.transform = Transform2D(0.0, pos + Vector2(0, -6))
		query.collision_mask = check_mask
		query.exclude = excludes
		if space.intersect_shape(query).size() > 0:
			return false

	# 2. Проверка расстояния до уже стоящих объектов (нельзя ставить объект внутрь объекта)
	var interactables = get_tree().get_nodes_in_group("interactable")
	for obj in interactables:
		if not is_instance_valid(obj) or obj == player: continue
		if ghost_container.is_ancestor_of(obj): continue
		
		# Проверяем нахождение в том же пространстве (снаружи или внутри палатки)
		var obj_in_tent = obj.global_position.distance_to(TentManager.INTERIOR_POS) < 350.0
		if obj_in_tent != is_in_tent:
			continue
			
		# Проверка палатки в мире (только когда мы на улице, чтобы не путать с TentInterior)
		if not is_in_tent and (obj.name == "Tent" or obj.name.begins_with("SampleTent") or ("is_tent" in obj and obj.is_tent)):
			var tent_center = obj.global_position + Vector2(0, -22)
			if pos.distance_to(tent_center) < 26.0:
				return false
				
		# Проверка кроватей (односпальная кровать)
		if obj is OrangeBed or obj.name.begins_with("OrangeBed"):
			var bed_center = obj.global_position + Vector2(0, -12)
			var my_bed_center = pos + Vector2(0, -12)
			if my_bed_center.distance_to(bed_center) < 14.0:
				return false
				
		# Проверка ящиков и костров
		if obj.name.begins_with("StorageBox") or obj.name.begins_with("Campfire"):
			if pos.distance_to(obj.global_position) < 12.0:
				return false

	return true

func _get_ghost_shapes(node: Node) -> Array[Dictionary]:
	var shapes: Array[Dictionary] = []
	for child in node.get_children():
		if child is CollisionShape2D and child.shape:
			shapes.append({
				"shape": child.shape,
				"transform": child.transform
			})
		elif child is CollisionPolygon2D and child.polygon.size() >= 3:
			var poly = ConvexPolygonShape2D.new()
			poly.points = child.polygon
			shapes.append({
				"shape": poly,
				"transform": child.transform
			})
		shapes.append_array(_get_ghost_shapes(child))
	return shapes

func _place_object(pos: Vector2) -> void:
	if not is_placing: return
	
	var item = ItemDB.get_item(current_item_id)
	if not item.has("scene"): return
	
	var scene_path = item["scene"]
	var scene = load(scene_path)
	if scene:
		var instance = scene.instantiate()
		if instance.has_method("set_direction"):
			instance.set_direction(current_rotation)
		instance.global_position = pos
		var ysort = get_tree().current_scene.get_node_or_null("Interactables")
		if ysort:
			ysort.add_child(instance)
		else:
			get_tree().current_scene.add_child(instance)
			
		InventoryManager.remove_item(current_item_id, 1)
		
		# Если предмет закончился — прекращаем размещение
		if InventoryManager.get_item_amount(current_item_id) <= 0:
			stop_placement()

func _draw() -> void:
	if not is_placing: return
	
	# Очень деликатные пиксельные точки (1x1) по кругу дальности размещения (8% прозрачности)
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var center = to_local(player.global_position)
		var dot_col = Color(1.0, 1.0, 1.0, 0.08)
		var steps = 36
		for i in range(steps):
			var angle = i * (TAU / steps)
			var px = round(center.x + cos(angle) * MAX_PLACEMENT_DISTANCE)
			var py = round(center.y + sin(angle) * MAX_PLACEMENT_DISTANCE)
			draw_rect(Rect2(px, py, 1.0, 1.0), dot_col)
