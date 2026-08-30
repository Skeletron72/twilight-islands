import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

old_ready = """	# Connect tab buttons
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as BaseButton
		if btn:
			# Bind the current loop's btn_idx explicitly
			btn.pressed.connect(func(idx=btn_idx): _switch_tab(idx))
			btn_idx += 1"""

new_ready = """	# Connect tab buttons
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as BaseButton
		if btn:
			btn.pressed.connect(_switch_tab.bind(btn_idx))
			btn_idx += 1"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
