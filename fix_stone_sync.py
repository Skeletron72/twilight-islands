import re

with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

old_ready = """	var is_large = rock_type >= 11
	if is_large:
		hp = randi_range(4, 7)
	else:
		hp = randi_range(2, 4)
		
	# Always process to loop the idle animation"""

new_ready = """	var is_large = rock_type >= 11
	if is_large:
		hp = randi_range(4, 7)
	else:
		hp = randi_range(2, 4)
		
	# Randomize start frame and timer so they wiggle chaotically
	anim_frame = randi() % 8
	if sprite:
		sprite.frame = anim_frame
	anim_timer = randf() * 0.1
	set_process(true)"""

content = content.replace(old_ready, new_ready)

# Make it slightly faster so it's more obvious (10 FPS)
old_process = """	anim_timer += delta
	if anim_timer >= 0.15: # About 6.6 FPS for gentle idle wiggle
		anim_timer -= 0.15"""
new_process = """	anim_timer += delta
	if anim_timer >= 0.1: # 10 FPS
		anim_timer -= 0.1"""
content = content.replace(old_process, new_process)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
