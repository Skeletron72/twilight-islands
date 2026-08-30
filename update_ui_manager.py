import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

content = content.replace('"MarginContainer/VBoxContainer/StaminaBar"', '"MarginContainer/VBoxContainer/StaminaContainer/StaminaBar"')

exhaust_check = """
func _on_stamina_changed(new_val: float, max_val: float) -> void:
	var sb = get_node_or_null("MarginContainer/VBoxContainer/StaminaContainer/StaminaBar")
	if sb:
		sb.max_value = max_val
		sb.value = new_val
		
		# Change color to red if exhausted
		var style = sb.get_theme_stylebox("fill").duplicate()
		if GameStateManager.is_exhausted:
			style.bg_color = Color(0.8, 0.2, 0.2, 1.0) # Red
		else:
			style.bg_color = Color(0.15, 0.85, 0.25, 1.0) # Green
		sb.add_theme_stylebox_override("fill", style)
"""

content = re.sub(r'func _on_stamina_changed.*?sb\.value = new_val', exhaust_check.strip(), content, flags=re.DOTALL)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
