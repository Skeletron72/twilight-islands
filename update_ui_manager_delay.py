import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

old_died = """func _on_player_died() -> void:
	print("Player died! Lost raid loot.")
	InventoryManager.clear_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	# Reset stats for next run
	GameStateManager.current_health = GameStateManager.max_health
	GameStateManager.current_stamina = GameStateManager.max_stamina
	TransitionManager.transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")"""

new_died = """func _on_player_died() -> void:
	print("Player died! Lost raid loot.")
	
	# Ждем 2 секунды, чтобы проигралась анимация смерти
	await get_tree().create_timer(2.0).timeout
	
	InventoryManager.clear_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	# Reset stats for next run
	GameStateManager.current_health = GameStateManager.max_health
	GameStateManager.current_stamina = GameStateManager.max_stamina
	TransitionManager.transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")"""

content = content.replace(old_died, new_died)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
