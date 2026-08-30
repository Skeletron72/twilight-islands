import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Change MarginContainer to Control
content = content.replace('var hunger_wrapper: MarginContainer', 'var hunger_wrapper: Control')
content = content.replace('hunger_wrapper = MarginContainer.new()', 'hunger_wrapper = Control.new()\n\thunger_wrapper.custom_minimum_size = Vector2(32, 4)')

# Fix the process logic
old_logic = """			if hunger_pct <= 0.05:
				hunger_wrapper.add_theme_constant_override("margin_left", randi() % 3 - 1)
				hunger_wrapper.add_theme_constant_override("margin_top", randi() % 3 - 1)
				# Flicker
				if randi() % 10 < 2:
					hunger_bar.modulate = Color(1.5, 0.5, 0.5)
				else:
					hunger_bar.modulate = Color.WHITE
			else:
				hunger_wrapper.add_theme_constant_override("margin_left", 0)
				hunger_wrapper.add_theme_constant_override("margin_top", 0)
				hunger_bar.modulate = Color.WHITE"""

new_logic = """			if hunger_pct <= 0.05:
				hunger_bar.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
				# Flicker
				if randi() % 10 < 2:
					hunger_bar.modulate = Color(1.5, 0.5, 0.5)
				else:
					hunger_bar.modulate = Color.WHITE
			else:
				hunger_bar.position = Vector2.ZERO
				hunger_bar.modulate = Color.WHITE"""

content = content.replace(old_logic, new_logic)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
