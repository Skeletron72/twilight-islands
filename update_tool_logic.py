import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# 1. Add Tool textures to _ready
old_ready = """	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	for layer_name in LAYERS:"""

new_ready = """	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	# Preload tools
	var tool_sprite = visuals.get_node_or_null("Tool")
	if tool_sprite:
		tool_sprite.visible = false
	
	for layer_name in LAYERS:"""
content = content.replace(old_ready, new_ready)

# 2. Add Tool logic to _update_sprites
old_update = """		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)"""

new_update = """		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)
			
	var tool_sprite: Sprite2D = visuals.get_node_or_null("Tool")
	if tool_sprite:
		if current_anim in ["attack", "axe", "mining"]:
			tool_sprite.visible = true
			if current_anim == "attack":
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Sword.png")
				tool_sprite.hframes = 4
				tool_sprite.vframes = 9
				# Attack row in player body is 6 + (dir*3). In sword it's 0 + (dir*3).
				var sword_row = actual_row - 6
				tool_sprite.frame_coords = Vector2i(current_frame, sword_row)
			elif current_anim in ["axe", "mining"]:
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Tools.png")
				tool_sprite.hframes = 6
				tool_sprite.vframes = 12
				# Axe row in player body is 32 + dir. In tools it's 0 + dir.
				# Mining row in player body is 35 + dir. In tools it's 3 + dir.
				var tool_row = actual_row - 32
				tool_sprite.frame_coords = Vector2i(current_frame, tool_row)
		else:
			tool_sprite.visible = false"""
content = content.replace(old_update, new_update)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
