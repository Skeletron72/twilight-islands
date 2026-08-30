import re

with open('scripts/components/gatherable.gd', 'r') as f:
    content = f.read()

old_gather = r'(func _gather\(\) -> void:\n\t# Spawn dropped item\n\tvar dropped_scene = preload\("res://scenes/objects/dropped_item\.tscn"\)\n\tvar drop = dropped_scene\.instantiate\(\)\n\tdrop\.global_position = global_position\n\tdrop\.setup\(resource_id, drop_amount\)\n\tget_tree\(\)\.current_scene\.add_child\(drop\))'

new_gather = """func _gather() -> void:
	# Add directly to inventory
	InventoryManager.add_item(resource_id, drop_amount)"""

content = re.sub(old_gather, new_gather, content)

with open('scripts/components/gatherable.gd', 'w') as f:
    f.write(content)
