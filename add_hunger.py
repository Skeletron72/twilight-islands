import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

hunger_code = """
var max_hunger: float = 100.0
var current_hunger: float = 100.0
signal hunger_changed(new_value: float, max_value: float)

func add_hunger(amount: float) -> void:
	current_hunger = min(current_hunger + amount, max_hunger)
	hunger_changed.emit(current_hunger, max_hunger)

func _process(delta: float) -> void:
	# Hunger drains over time. 1 in-game day (15 mins?) let's say 1 point every 10 seconds.
	if current_hunger > 0:
		current_hunger -= (0.1 * delta)
		if current_hunger < 0:
			current_hunger = 0
		hunger_changed.emit(current_hunger, max_hunger)
"""

content += hunger_code

with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
    f.write(content)
