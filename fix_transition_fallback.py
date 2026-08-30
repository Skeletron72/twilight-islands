import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

old_code = """	GameStateManager.current_stamina = GameStateManager.max_stamina
	get_node("/root/TransitionManager").transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")"""

new_code = """	GameStateManager.current_stamina = GameStateManager.max_stamina
	var tm = get_node_or_null("/root/TransitionManager")
	if tm:
		tm.transition_to("res://scenes/levels/home_island.tscn", "Вы погибли...")
	else:
		get_tree().change_scene_to_file("res://scenes/levels/home_island.tscn")"""

content = content.replace(old_code, new_code)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
