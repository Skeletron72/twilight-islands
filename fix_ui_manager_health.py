import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

old_ready = """	GameStateManager.stamina_changed.connect(_on_stamina_changed)
	_update_time_text()
	
	var sb = get_node_or_null("MarginContainer/VBoxContainer/StaminaContainer/StaminaBar")
	if sb:
		sb.max_value = GameStateManager.max_stamina
		sb.value = GameStateManager.current_stamina"""

new_ready = """	GameStateManager.stamina_changed.connect(_on_stamina_changed)
	GameStateManager.health_changed.connect(_on_health_changed)
	GameStateManager.player_died.connect(_on_player_died)
	_update_time_text()
	
	var sb = get_node_or_null("MarginContainer/VBoxContainer/StaminaContainer/StaminaBar")
	if sb:
		sb.max_value = GameStateManager.max_stamina
		sb.value = GameStateManager.current_stamina
		
	var hb = get_node_or_null("MarginContainer/VBoxContainer/HealthContainer/HealthBar")
	if hb:
		hb.max_value = GameStateManager.max_health
		hb.value = GameStateManager.current_health"""
		
content = content.replace(old_ready, new_ready)

health_funcs = """
func _on_health_changed(new_val: float, max_val: float) -> void:
	var hb = get_node_or_null("MarginContainer/VBoxContainer/HealthContainer/HealthBar")
	if hb:
		hb.max_value = max_val
		hb.value = new_val

func _on_player_died() -> void:
	print("Player died! Lost raid loot.")
	InventoryManager.clear_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	# Reset stats for next run
	GameStateManager.current_health = GameStateManager.max_health
	GameStateManager.current_stamina = GameStateManager.max_stamina
	TransitionManager.transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")
"""

content += health_funcs

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
