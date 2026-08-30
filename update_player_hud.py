import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Add ui references
content = content.replace('var current_target: Area2D = null', 'var current_target: Area2D = null\nvar hp_bar: ProgressBar\nvar stamina_bar: ProgressBar')

ready_ui_code = """
	var stats_ui = VBoxContainer.new()
	stats_ui.position = Vector2(-16, -35)
	stats_ui.custom_minimum_size = Vector2(32, 8)
	stats_ui.add_theme_constant_override("separation", 1)
	stats_ui.z_index = 50
	
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(32, 4)
	hp_bar.show_percentage = false
	var hp_bg = StyleBoxFlat.new()
	hp_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.border_width_left = 1; hp_bg.border_width_top = 1; hp_bg.border_width_right = 1; hp_bg.border_width_bottom = 1
	hp_bg.border_color = Color(0,0,0,1)
	var hp_fill = StyleBoxFlat.new()
	hp_fill.bg_color = Color(0.85, 0.15, 0.15, 1)
	hp_fill.border_width_left = 1; hp_fill.border_width_top = 1; hp_fill.border_width_right = 1; hp_fill.border_width_bottom = 1
	hp_fill.border_color = Color(0,0,0,0)
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	
	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(32, 4)
	stamina_bar.show_percentage = false
	var st_bg = StyleBoxFlat.new()
	st_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	st_bg.border_width_left = 1; st_bg.border_width_top = 1; st_bg.border_width_right = 1; st_bg.border_width_bottom = 1
	st_bg.border_color = Color(0,0,0,1)
	var st_fill = StyleBoxFlat.new()
	st_fill.bg_color = Color(0.15, 0.85, 0.25, 1)
	st_fill.border_width_left = 1; st_fill.border_width_top = 1; st_fill.border_width_right = 1; st_fill.border_width_bottom = 1
	st_fill.border_color = Color(0,0,0,0)
	stamina_bar.add_theme_stylebox_override("background", st_bg)
	stamina_bar.add_theme_stylebox_override("fill", st_fill)
	
	stats_ui.add_child(hp_bar)
	stats_ui.add_child(stamina_bar)
	add_child(stats_ui)
"""

content = content.replace('func _ready() -> void:', 'func _ready() -> void:\n' + ready_ui_code)

process_ui_code = """
func _process(delta: float) -> void:
	if hp_bar and stamina_bar:
		hp_bar.max_value = GameStateManager.max_health
		hp_bar.value = GameStateManager.current_health
		stamina_bar.max_value = GameStateManager.max_stamina
		stamina_bar.value = GameStateManager.current_stamina
		
		hp_bar.visible = (hp_bar.value < hp_bar.max_value)
		stamina_bar.visible = (stamina_bar.value < stamina_bar.max_value)
		
		var style = stamina_bar.get_theme_stylebox("fill")
		if GameStateManager.is_exhausted:
			style.bg_color = Color(0.8, 0.2, 0.2, 1)
		else:
			style.bg_color = Color(0.15, 0.85, 0.25, 1)
"""
content = content.replace('func _physics_process(delta: float) -> void:', process_ui_code + '\nfunc _physics_process(delta: float) -> void:')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
