import re

with open('scripts/components/berry_bush.gd', 'r') as f:
    content = f.read()

# Make the texture unique in _ready
old_ready = """func _ready() -> void:
	_update_visuals()"""

new_ready = """func _ready() -> void:
	sprite.texture = sprite.texture.duplicate()
	_update_visuals()"""

content = content.replace(old_ready, new_ready)

# Make the amount random
old_interact = """		if resource_id == "red_bush":
			InventoryManager.add_item("red_berry", 2)
		else:
			InventoryManager.add_item("yellow_berry", 2)"""

new_interact = """		var amount = randi() % 5 + 1 # 1 to 5
		if resource_id == "red_bush":
			InventoryManager.add_item("red_berry", amount)
		else:
			InventoryManager.add_item("yellow_berry", amount)"""

content = content.replace(old_interact, new_interact)

with open('scripts/components/berry_bush.gd', 'w') as f:
    f.write(content)
