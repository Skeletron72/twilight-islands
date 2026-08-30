import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Add hunger_bar and hunger_wrapper
content = content.replace('var stamina_bar: ProgressBar', 'var stamina_bar: ProgressBar\nvar hunger_bar: ProgressBar\nvar hunger_wrapper: MarginContainer')

# Create hunger_bar UI
ui_code = """
	stamina_bar.add_theme_stylebox_override("background", st_bg)
	stamina_bar.add_theme_stylebox_override("fill", st_fill)
	
	hunger_wrapper = MarginContainer.new()
	hunger_bar = ProgressBar.new()
	hunger_bar.custom_minimum_size = Vector2(32, 4)
	hunger_bar.show_percentage = false
	var hu_bg = StyleBoxFlat.new()
	hu_bg.anti_aliasing = false
	hu_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hu_bg.border_width_left = 1; hu_bg.border_width_top = 1; hu_bg.border_width_right = 1; hu_bg.border_width_bottom = 1
	hu_bg.border_color = Color(0,0,0,1)
	var hu_fill = StyleBoxFlat.new()
	hu_fill.anti_aliasing = false
	hu_fill.bg_color = Color(0.9, 0.6, 0.1, 1) # Orange
	hu_fill.border_width_left = 1; hu_fill.border_width_top = 1; hu_fill.border_width_right = 1; hu_fill.border_width_bottom = 1
	hu_fill.border_color = Color(0,0,0,0)
	hunger_bar.add_theme_stylebox_override("background", hu_bg)
	hunger_bar.add_theme_stylebox_override("fill", hu_fill)
	hunger_wrapper.add_child(hunger_bar)
	
	stats_ui.add_child(hp_bar)
	stats_ui.add_child(stamina_bar)
	stats_ui.add_child(hunger_wrapper)
	add_child(stats_ui)"""

content = re.sub(r'\tstamina_bar\.add_theme_stylebox_override\("fill", st_fill\)\n\t\n\tstats_ui\.add_child\(hp_bar\)\n\tstats_ui\.add_child\(stamina_bar\)\n\tadd_child\(stats_ui\)', ui_code, content)

# Process logic
process_code = """func _process(delta: float) -> void:
	if hp_bar and stamina_bar and hunger_bar:
		hp_bar.max_value = GameStateManager.max_health
		hp_bar.value = GameStateManager.current_health
		stamina_bar.max_value = GameStateManager.max_stamina
		stamina_bar.value = GameStateManager.current_stamina
		hunger_bar.max_value = GameStateManager.max_hunger
		hunger_bar.value = GameStateManager.current_hunger
		
		# Hunger logic
		var hunger_pct = GameStateManager.current_hunger / GameStateManager.max_hunger
		if hunger_pct <= 0.25:
			hunger_wrapper.visible = true
			if hunger_pct <= 0.05:
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
				hunger_bar.modulate = Color.WHITE
		else:
			hunger_wrapper.visible = false
"""

content = re.sub(r'func _process\(delta: float\) -> void:.*?stamina_bar\.value = GameStateManager\.current_stamina', process_code, content, flags=re.DOTALL)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
