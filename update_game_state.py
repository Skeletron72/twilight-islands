import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

stamina_code = """
var max_stamina: float = 100.0
var current_stamina: float = 100.0

signal stamina_changed(new_value: float, max_value: float)

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func add_stamina(amount: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + amount, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

"""

if 'var max_stamina' not in content:
    content = content.replace('var current_day: int = 1\n', 'var current_day: int = 1\n' + stamina_code)
    with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
        f.write(content)

