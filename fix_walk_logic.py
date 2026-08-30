import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Fix speed
content = content.replace('@export var speed: float = 55.0', '@export var speed: float = 40.0')

# Fix movement logic
old_process = """	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Mobile analog override
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.output_vector.length() > 0:
		direction = mobile_controls.output_vector
		
	var move_length = direction.length()
	
	if move_length > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
			
		if move_length > 0.6 or Input.is_action_pressed("sprint"):
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			velocity = direction.normalized() * speed
			_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		_play_anim("idle")"""

new_process = """	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# Mobile analog override
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.touch_id != -1:
		direction = mobile_controls.output_vector
		is_sprinting = direction.length() > 0.6
		
	if direction.length() > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
			
		if is_sprinting:
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			velocity = direction.normalized() * speed
			_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		_play_anim("idle")"""

content = content.replace(old_process, new_process)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
