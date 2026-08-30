import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

health_code = """
var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(new_value: float, max_value: float)
signal player_died()

func take_damage(amount: float) -> void:
	if current_health > 0:
		current_health -= amount
		if current_health <= 0:
			current_health = 0
			player_died.emit()
		health_changed.emit(current_health, max_health)

func heal(amount: float) -> void:
	if current_health > 0 and current_health < max_health:
		current_health = min(current_health + amount, max_health)
		health_changed.emit(current_health, max_health)

"""

if 'var max_health' not in content:
    content = content.replace('var current_day: int = 1\n', 'var current_day: int = 1\n' + health_code)
    
with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
    f.write(content)
