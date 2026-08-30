import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

old_ready = """func _ready() -> void:
	show()
	GameStateManager.time_changed.connect(_on_time_changed)
	GameStateManager.day_changed.connect(_on_day_changed)
	_update_time_text()"""

new_ready = """func _ready() -> void:
	show()
	GameStateManager.time_changed.connect(_on_time_changed)
	GameStateManager.day_changed.connect(_on_day_changed)
	GameStateManager.stamina_changed.connect(_on_stamina_changed)
	_update_time_text()
	
	var sb = get_node_or_null("MarginContainer/VBoxContainer/StaminaBar")
	if sb:
		sb.max_value = GameStateManager.max_stamina
		sb.value = GameStateManager.current_stamina
"""

content = content.replace(old_ready, new_ready)

stamina_func = """
func _on_stamina_changed(new_val: float, max_val: float) -> void:
	var sb = get_node_or_null("MarginContainer/VBoxContainer/StaminaBar")
	if sb:
		sb.max_value = max_val
		sb.value = new_val
"""

content += stamina_func

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
