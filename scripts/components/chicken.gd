extends CharacterBody2D

@export var speed: float = 15.0

enum State {
	IDLE,
	WALKING,
	PECKING_GROUND,
	MOVING_TO_BUSH,
	PECKING_BUSH
}

var current_state: State = State.IDLE
var direction: Vector2 = Vector2.ZERO
var last_safe_position: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 8.0

var target_bush: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	_pick_new_state()
	last_safe_position = global_position

func _physics_process(delta: float) -> void:
	# Detect if pushed by player
	var moved_by_physics = false
	if current_state in [State.IDLE, State.PECKING_GROUND, State.PECKING_BUSH]:
		if global_position.distance_to(last_safe_position) > 1.0:
			moved_by_physics = true
	
	if moved_by_physics and current_state == State.PECKING_BUSH:
		# Cancel pecking bush if pushed
		_pick_new_state()
		
	state_timer -= delta
	
	match current_state:
		State.IDLE, State.PECKING_GROUND:
			velocity = Vector2.ZERO
			move_and_slide()
			if state_timer <= 0:
				_pick_new_state()
				
			_animate(delta, 1 if current_state == State.PECKING_GROUND else 0)
			
		State.WALKING:
			if state_timer <= 0:
				_pick_new_state()
			
			velocity = direction * speed
			_handle_water_avoidance()
			_apply_flip()
			move_and_slide()
			_animate(delta, 0)
			
		State.MOVING_TO_BUSH:
			if state_timer <= 0 or not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:
				var dist = global_position.distance_to(target_bush.global_position)
				if dist < 24.0:
					# Start pecking the bush
					current_state = State.PECKING_BUSH
					state_timer = 2.0 # Peck for 2 seconds
					velocity = Vector2.ZERO
				else:
					direction = (target_bush.global_position - global_position).normalized()
					velocity = direction * speed
					_handle_water_avoidance()
					_apply_flip()
					move_and_slide()
					_animate(delta, 0)
					
		State.PECKING_BUSH:
			velocity = Vector2.ZERO
			move_and_slide()
			if not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:
				if state_timer <= 0:
					# Eat the berries!
					target_bush.has_berries = false
					target_bush._update_visuals()
					
					# Regrow timer
					var t = get_tree().create_timer(300.0)
					var b = target_bush
					t.timeout.connect(func():
						if is_instance_valid(b):
							b.has_berries = true
							b._update_visuals()
					)
					
					_pick_new_state()
					
			_animate(delta, 1)

	# Water safety fallback
	_ensure_water_safety()
	
	if current_state in [State.IDLE, State.PECKING_GROUND, State.PECKING_BUSH]:
		last_safe_position = global_position

func _animate(delta: float, row: int) -> void:
	anim_timer += delta
	var current_fps = fps
	if row == 1:
		current_fps = fps * 0.8 # slightly slower pecking? or just normal
		
	if anim_timer >= 1.0 / current_fps:
		anim_timer -= (1.0 / current_fps)
		current_frame = (current_frame + 1) % 4
		sprite.frame = (row * 4) + current_frame

func _handle_water_avoidance() -> void:
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
	
	if water_layer:
		var next_pos = global_position + direction * 8.0 + Vector2(0, -2)
		var map_pos = water_layer.local_to_map(next_pos)
		if water_layer.get_cell_source_id(map_pos) != -1:
			var in_water = true
			for child in world_map.get_children():
				if child is TileMapLayer and child != water_layer:
					if child.get_cell_source_id(map_pos) != -1:
						in_water = false
						break
			if in_water:
				direction = -direction
				if current_state == State.MOVING_TO_BUSH:
					_pick_new_state()

func _ensure_water_safety() -> void:
	var is_in_water = false
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
	
	if water_layer:
		var map_pos = water_layer.local_to_map(global_position + Vector2(0, -2))
		if water_layer.get_cell_source_id(map_pos) != -1:
			is_in_water = true
			for child in world_map.get_children():
				if child is TileMapLayer and child != water_layer:
					if child.get_cell_source_id(map_pos) != -1:
						is_in_water = false
						break
	
	if is_in_water:
		global_position = last_safe_position
		if current_state == State.WALKING:
			direction = -direction
			_pick_new_state()
	else:
		last_safe_position = global_position

func _apply_flip() -> void:
	if velocity.x != 0:
		sprite.scale.x = -1 if velocity.x > 0 else 1

func _pick_new_state() -> void:
	target_bush = null
	
	# 20% chance to look for a berry bush
	if randf() < 0.2:
		var bushes = get_tree().get_nodes_in_group("interactable")
		var valid_bushes = []
		for b in bushes:
			if b.name.begins_with("BerryBush") or "has_berries" in b:
				if b.has_berries and global_position.distance_to(b.global_position) < 150.0:
					valid_bushes.append(b)
					
		if valid_bushes.size() > 0:
			target_bush = valid_bushes[randi() % valid_bushes.size()]
			current_state = State.MOVING_TO_BUSH
			state_timer = 10.0 # max 10 seconds to reach it
			return

	# Otherwise normal behavior
	var r = randf()
	if r < 0.3:
		current_state = State.PECKING_GROUND
		state_timer = randf_range(2.0, 4.0)
	elif r < 0.5:
		current_state = State.IDLE
		state_timer = randf_range(1.0, 2.0)
	else:
		current_state = State.WALKING
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		state_timer = randf_range(2.0, 5.0)
