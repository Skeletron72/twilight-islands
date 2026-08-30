import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

# Change default to -1
content = content.replace('var active_slot_index: int = 0', 'var active_slot_index: int = -1')

# Replace _set_active_slot
old_set = """func _set_active_slot(index: int) -> void:
	if index == active_slot_index: return
	
	var old_index = active_slot_index
	active_slot_index = index
	
	_animate_slot_selection(old_index, false)
	_animate_slot_selection(active_slot_index, true)"""

new_set = """func _set_active_slot(index: int) -> void:
	if index == active_slot_index:
		_animate_slot_selection(active_slot_index, false)
		active_slot_index = -1
		return
	
	var old_index = active_slot_index
	active_slot_index = index
	
	if old_index != -1:
		_animate_slot_selection(old_index, false)
	
	if active_slot_index != -1:
		_animate_slot_selection(active_slot_index, true)"""

content = content.replace(old_set, new_set)

# Also fix the page up/page down scroll to work nicely with -1
old_input = """func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_up"): # Or scroll up
		_set_active_slot((active_slot_index - 1 + 4) % 4)
	elif event.is_action_pressed("ui_page_down"): # Or scroll down
		_set_active_slot((active_slot_index + 1) % 4)"""

new_input = """func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_up"): # Or scroll up
		var idx = active_slot_index - 1
		if idx < 0: idx = 3
		if active_slot_index == -1: idx = 3
		_set_active_slot(idx)
	elif event.is_action_pressed("ui_page_down"): # Or scroll down
		var idx = (active_slot_index + 1) % 4
		if active_slot_index == -1: idx = 0
		_set_active_slot(idx)"""

content = content.replace(old_input, new_input)

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
