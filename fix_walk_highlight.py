import re

with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

# Remove TargetHighlight block
highlight_block = r'\[node name="TargetHighlight" type="ColorRect" parent="\."\].*?mouse_filter = 2\n\n'
content = re.sub(highlight_block, '', content, flags=re.DOTALL)

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Remove target_highlight var
content = content.replace('@onready var target_highlight: Sprite2D = $TargetHighlight\n', '')

# Add walk animation
run_block = """	"run": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/RUN/base_run_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/RUN/boots1_run_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/RUN/cloth1_run_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/RUN/hair_merged_run_strip8.png"),
		"tools": null
	},"""
walk_block = """	"walk": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/WALK/base_walk_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/WALK/boots1_walk_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/WALK/cloth1_walk_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/WALK/hair_merged_walk_strip8.png"),
		"tools": null
	},"""
# Wait, I previously set tools: preload(...) for run! I should use the current block.
content = re.sub(r'(\t"run": \{[^\}]+\},)', r'\1\n' + walk_block, content)

# Update _physics_process
old_process = """	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if direction != Vector2.ZERO:
		velocity = direction * speed
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
		_play_anim("run")
	else:
		velocity = Vector2.ZERO
		_play_anim("idle")"""

new_process = """	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
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

content = content.replace(old_process, new_process)

# Update auto_target
old_auto = """	if current_target:
		target_highlight.visible = true
		target_highlight.global_position = current_target.global_position
	else:
		target_highlight.visible = false"""

new_auto = """	# Reset old target modulate
	if current_target and is_instance_valid(current_target):
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color.WHITE
		
	current_target = closest_target
	
	# Highlight new target
	if current_target and is_instance_valid(current_target):
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color(1.4, 1.4, 1.4, 1.0)"""

# In _update_auto_target, I need to replace from `current_target = closest_target` downwards
content = re.sub(r'\tcurrent_target = closest_target\n.*?\ttarget_highlight\.visible = false', new_auto, content, flags=re.DOTALL)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
