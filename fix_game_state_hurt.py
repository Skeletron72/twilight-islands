import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

old_damage = """signal health_changed(new_value: float, max_value: float)
signal player_died()

func take_damage(amount: float) -> void:
	if current_health > 0:
		current_health -= amount
		if current_health <= 0:
			current_health = 0
			player_died.emit()
		health_changed.emit(current_health, max_health)"""

new_damage = """signal health_changed(new_value: float, max_value: float)
signal player_died()
signal player_hurt()

func take_damage(amount: float) -> void:
	if current_health > 0:
		current_health -= amount
		if current_health > 0:
			player_hurt.emit()
		if current_health <= 0:
			current_health = 0
			player_died.emit()
		health_changed.emit(current_health, max_health)"""

content = content.replace(old_damage, new_damage)

with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
    f.write(content)

