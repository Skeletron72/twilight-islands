import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Find the entire _physics_process block and replace it
pattern = r'func _physics_process\(delta: float\) -> void:.*?func _play_anim'
new_process = """func _physics_process(delta: float) -> void:
	if is_acting:
		velocity = Vector2.ZERO
		move_and_slide()
		_process_animation(delta)
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# Mobile analog override
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.touch_id != -1:
		direction = mobile_controls.output_vector
		is_sprinting = direction.length() > 0.6
		
	var in_water = false
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		var water_layer = world_map.get_node_or_null("WaterLayer")
		if water_layer:
			var map_pos = water_layer.local_to_map(global_position + Vector2(0, -4))
			if water_layer.get_cell_source_id(map_pos) != -1:
				in_water = true
				for child in world_map.get_children():
					if child is TileMapLayer and child != water_layer:
						if child.get_cell_source_id(map_pos) != -1:
							in_water = false
							break

	if direction.length() > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
			
		if in_water:
			velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting and GameStateManager.current_stamina > 0.5:
			GameStateManager.consume_stamina(10.0 * delta)
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			velocity = direction.normalized() * speed
			_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		if in_water:
			_play_anim("swimming")
		else:
			_play_anim("idle")

	_update_auto_target()
		
	if Input.is_action_just_pressed("interact"):
		_try_interact()

	# Stamina regeneration
	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5):
		GameStateManager.add_stamina(5.0 * delta)
		
	move_and_slide()
	_process_animation(delta)

func _play_anim"""

content = re.sub(pattern, new_process, content, flags=re.DOTALL)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
