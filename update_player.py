import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Replace _try_interact to consume stamina
old_interact = """		if current_target is Destructible:
			is_acting = true
			if current_target.resource_id == "wood":
				_play_anim("axe")
			else:
				_play_anim("mining")"""
				
new_interact = """		if current_target is Destructible:
			if GameStateManager.consume_stamina(5.0):
				is_acting = true
				if current_target.resource_id == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass"""
				
content = content.replace(old_interact, new_interact)

# In _physics_process, handle sprint consumption and regeneration
old_sprint = """		if in_water:
			velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting:
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")"""
			
new_sprint = """		if in_water:
			velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting and GameStateManager.current_stamina > 0.5:
			GameStateManager.consume_stamina(10.0 * delta)
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")"""
			
content = content.replace(old_sprint, new_sprint)

# Add regeneration when not sprinting and not acting
# I'll put it right before move_and_slide()
old_move = "	move_and_slide()"
new_move = """	# Stamina regeneration
	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5):
		GameStateManager.add_stamina(5.0 * delta)
		
	move_and_slide()"""

content = content.replace(old_move, new_move)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
