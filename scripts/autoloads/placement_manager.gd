extends Node

var is_placing: bool = false
var current_item_id: String = ""
var ghost_sprite: Sprite2D = null
var current_scene = null
var _was_pressed: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	ghost_sprite = Sprite2D.new()
	ghost_sprite.modulate = Color(1, 1, 1, 0.5)
	ghost_sprite.visible = false
	ghost_sprite.z_index = 100
	add_child(ghost_sprite)

func start_placement(item_id: String) -> void:
	current_item_id = item_id
	is_placing = true
	ghost_sprite.texture = ItemDB.get_icon(item_id).atlas if ItemDB.get_icon(item_id) else null
	# Wait, get_icon returns AtlasTexture. We can just set texture to the AtlasTexture!
	var icon = ItemDB.get_icon(item_id)
	if icon:
		ghost_sprite.texture = icon
	ghost_sprite.visible = true

func stop_placement() -> void:
	is_placing = false
	current_item_id = ""
	ghost_sprite.visible = false

func _process(delta: float) -> void:
	if not is_placing: return
	
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_2d()
	var world_pos = mouse_pos
	if camera:
		world_pos = (mouse_pos - get_viewport().get_visible_rect().size / 2.0) / camera.zoom + camera.global_position
		
	# Snap to 16x16 grid
	var snapped_x = floor(world_pos.x / 16.0) * 16.0 + 8.0
	var snapped_y = floor(world_pos.y / 16.0) * 16.0 + 8.0
	var target_pos = Vector2(snapped_x, snapped_y)
	
	ghost_sprite.global_position = target_pos
	
	var can_place = _can_place_at(target_pos)
	if can_place:
		ghost_sprite.modulate = Color(0.2, 1.0, 0.2, 0.6)
	else:
		ghost_sprite.modulate = Color(1.0, 0.2, 0.2, 0.6)
		
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if not _was_pressed:
			_was_pressed = true
			
			# Check if over UI (naive check for now - if book is open, don't place)
			var ui_layer = get_tree().current_scene.get_node_or_null("UILayer")
			if ui_layer and ui_layer.has_node("BookUI") and ui_layer.get_node("BookUI").visible:
				return
				
			if can_place:
				_place_object(target_pos)
	else:
		_was_pressed = false

func _can_place_at(pos: Vector2) -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(pos) > 80.0:
		return false # Too far
		
	# Check for collisions using physics point query
	var space = ghost_sprite.get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = 1 # Environment mask
	var result = space.intersect_point(query)
	if result.size() > 0:
		return false
		
	return true

func _place_object(pos: Vector2) -> void:
	if not is_placing: return
	
	var item = ItemDB.get_item(current_item_id)
	if not item.has("scene"): return
	
	var scene_path = item["scene"]
	var scene = load(scene_path)
	if scene:
		var instance = scene.instantiate()
		instance.global_position = pos
		var ysort = get_tree().current_scene.get_node_or_null("Interactables")
		if ysort:
			ysort.add_child(instance)
		else:
			get_tree().current_scene.add_child(instance)
			
		InventoryManager.remove_item(current_item_id, 1)
		
		# If no more items, stop placement
		if InventoryManager.get_item_amount(current_item_id) <= 0:
			stop_placement()
