import re

with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

# 1. Remove set_process(false)
content = content.replace("	set_process(false) # Only process when animating destruction", "	# Always process to loop the idle animation")

# 2. Update the hp <= 0 block in interact
old_death = """	if hp <= 0:
		is_dead = true
		_spawn_drops()
		set_process(true) # Start destruction animation"""

new_death = """	if hp <= 0:
		is_dead = true
		_spawn_drops()
		
		# Code-based destruction animation
		var shrink_tween = create_tween()
		shrink_tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1) # Small pop up
		shrink_tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15) # Shrink to nothing
		shrink_tween.tween_callback(queue_free)"""
content = content.replace(old_death, new_death)

# 3. Update _process to loop the animation
old_process = """func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 0.1: # 10 FPS
		anim_timer -= 0.1
		anim_frame += 1
		if anim_frame >= 8:
			queue_free()
		else:
			sprite.frame = anim_frame"""

new_process = """func _process(delta: float) -> void:
	if is_dead: return # Stop animating frames when shrinking
	
	anim_timer += delta
	if anim_timer >= 0.15: # About 6.6 FPS for gentle idle wiggle
		anim_timer -= 0.15
		anim_frame = (anim_frame + 1) % 8
		sprite.frame = anim_frame"""
content = content.replace(old_process, new_process)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
