import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_sprint = """		elif is_sprinting and GameStateManager.current_stamina > 0.5:
			GameStateManager.consume_stamina(10.0 * delta)
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")"""

new_sprint = """		elif is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted:
			GameStateManager.consume_stamina(10.0 * delta)
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")"""

content = content.replace(old_sprint, new_sprint)

old_regen = """	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5):"""
new_regen = """	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted):"""

content = content.replace(old_regen, new_regen)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
