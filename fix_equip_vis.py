import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_func = """func _update_equipment_visuals() -> void:
	var cloth_sprite = visuals.get_node("Cloth")
	var boots_sprite = visuals.get_node("Boots")
	
	cloth_sprite.visible = (InventoryManager.equipment.get("chest", "") != "")
	boots_sprite.visible = (InventoryManager.equipment.get("boots", "") != "")"""

new_func = """func _update_equipment_visuals() -> void:
	var chest_sprite = visuals.get_node_or_null("Chest")
	var feet_sprite = visuals.get_node_or_null("Feet")
	
	if chest_sprite:
		chest_sprite.visible = (InventoryManager.equipment.get("chest", "") != "")
	if feet_sprite:
		feet_sprite.visible = (InventoryManager.equipment.get("boots", "") != "")"""

content = content.replace(old_func, new_func)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
