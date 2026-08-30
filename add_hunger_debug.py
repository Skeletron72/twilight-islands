import re

with open('scripts/components/debug_panel.gd', 'r') as f:
    content = f.read()

# Add a hunger debug button
old_ready = """func _ready() -> void:
	visible = false"""

new_ready = """func _ready() -> void:
	visible = false
	
	var hunger_btn = Button.new()
	hunger_btn.text = "Голод 5%"
	hunger_btn.pressed.connect(func(): GameStateManager.current_hunger = 5.0)
	grid_container.add_child(hunger_btn)
	
	var hunger25_btn = Button.new()
	hunger25_btn.text = "Голод 25%"
	hunger25_btn.pressed.connect(func(): GameStateManager.current_hunger = 25.0)
	grid_container.add_child(hunger25_btn)
"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/debug_panel.gd', 'w') as f:
    f.write(content)
