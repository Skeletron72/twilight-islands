import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_play = """func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_dir == get_last_direction():
		return
	
	if current_anim != anim_name:
		current_frame = 0
		anim_timer = 0.0
		
	current_anim = anim_name"""

new_play = """var last_played_dir: int = -1

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_dir == last_played_dir:
		return
	
	if current_anim != anim_name:
		current_frame = 0
		anim_timer = 0.0
		
	current_anim = anim_name
	last_played_dir = current_dir
	
	# Immediately update sprite frame when changing animation or direction
	_update_sprites()"""

content = content.replace(old_play, new_play)

old_process = """		for layer_name in LAYERS:
			var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
			if sprite and sprite.texture:
				sprite.frame_coords = Vector2i(current_frame, actual_row)"""

new_process = """		_update_sprites()

func _update_sprites() -> void:
	var row = ANIM_MAP[current_anim]["row"]
	var actual_row = row
	if current_anim == "attack":
		actual_row = row + (current_dir * 3)
	else:
		actual_row = row + current_dir
		
	for layer_name in LAYERS:
		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)"""
content = content.replace(old_process, new_process)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
