import re

with open('scripts/components/skeleton.gd', 'r') as f:
    content = f.read()

content = content.replace('var hp: int = max_hp', 'var hp: int = max_hp\nvar hp_bar: ProgressBar')

ready_ui_code = """
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-16, -30)
	hp_bar.custom_minimum_size = Vector2(32, 4)
	hp_bar.show_percentage = false
	hp_bar.z_index = 50
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
	add_child(hp_bar)
"""

content = content.replace('func _ready() -> void:', 'func _ready() -> void:\n' + ready_ui_code)

process_ui_code = """
func _process(delta: float) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.visible = (hp < max_hp and hp > 0 and not is_dead)
"""
content = content.replace('func _physics_process(delta: float) -> void:', process_ui_code + '\nfunc _physics_process(delta: float) -> void:')

with open('scripts/components/skeleton.gd', 'w') as f:
    f.write(content)
