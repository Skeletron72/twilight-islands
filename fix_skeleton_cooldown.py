import re

with open('scripts/components/skeleton.gd', 'r') as f:
    content = f.read()

# Add attack_cooldown variable
content = content.replace('var is_dead: bool = false', 'var is_dead: bool = false\nvar attack_cooldown: float = 0.0')

# Update _physics_process
old_physics = """func _physics_process(delta: float) -> void:
	if is_dead:
		_process_animation(delta)
		return
		
	if is_acting:
		_process_animation(delta)
		return
		
	if not is_instance_valid(player):
		_process_animation(delta)
		return
		
	var dist = global_position.distance_to(player.global_position)
	if dist > 20.0:
		var dir = global_position.direction_to(player.global_position)
		global_position += dir * speed * delta
		sprite.scale.x = -1 if dir.x < 0 else 1
		_play_anim("walk")
	else:
		# Начинаем атаку!
		_play_anim("attack")
		is_acting = true
		
	_process_animation(delta)"""

new_physics = """func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if is_dead:
		_process_animation(delta)
		return
		
	if is_acting:
		_process_animation(delta)
		return
		
	if not is_instance_valid(player):
		_process_animation(delta)
		return
		
	var dist = global_position.distance_to(player.global_position)
	# Бежим к игроку, если далеко ИЛИ если атака на перезарядке
	if dist > 22.0 or attack_cooldown > 0:
		# Если мы слишком близко, можно даже немного сбросить скорость или просто стоять.
		# Но пусть пока просто медленно подходит или толкает.
		var dir = global_position.direction_to(player.global_position)
		global_position += dir * speed * delta
		sprite.scale.x = -1 if dir.x < 0 else 1
		_play_anim("walk")
	else:
		# Начинаем атаку!
		_play_anim("attack")
		is_acting = true
		attack_cooldown = 1.5 # 1.5 секунды до следующей атаки
		
	_process_animation(delta)"""

content = content.replace(old_physics, new_physics)

with open('scripts/components/skeleton.gd', 'w') as f:
    f.write(content)
