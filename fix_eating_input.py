import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

old_logic = """	# Handle using/eating item on left click
	if event.is_action_pressed("left_click") and active_slot_index != -1:"""

new_logic = """	# Handle using/eating item on left click or interact button
	var is_use_pressed = false
	if event.is_action_pressed("interact"):
		is_use_pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_use_pressed = true
		
	if is_use_pressed and active_slot_index != -1:"""

content = content.replace(old_logic, new_logic)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
