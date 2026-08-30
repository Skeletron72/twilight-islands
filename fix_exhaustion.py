import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

old_consume = """func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount:
		current_stamina -= amount
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func add_stamina(amount: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + amount, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)"""

new_consume = """var is_exhausted: bool = false

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount and not is_exhausted:
		current_stamina -= amount
		if current_stamina <= 0.5:
			is_exhausted = true
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func add_stamina(amount: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + amount, max_stamina)
		if is_exhausted and current_stamina >= 15.0:
			is_exhausted = false
		stamina_changed.emit(current_stamina, max_stamina)"""

content = content.replace(old_consume, new_consume)

with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
    f.write(content)
