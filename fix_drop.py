import re

with open('scripts/components/destructible.gd', 'r') as f:
    content = f.read()

old_destroy = """func _destroy() -> void:
	InventoryManager.add_item(resource_id, drop_amount)
	
	if is_permanent:
		HomeStateManager.mark_destroyed(get_path())
		
	queue_free()"""

new_destroy = """func _destroy() -> void:
	# Spawn dropped item
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	var drop = dropped_scene.instantiate()
	drop.global_position = global_position
	drop.setup(resource_id, drop_amount)
	get_tree().current_scene.add_child(drop)
	
	if is_permanent:
		HomeStateManager.mark_destroyed(get_path())
		
	queue_free()"""

content = content.replace(old_destroy, new_destroy)

with open('scripts/components/destructible.gd', 'w') as f:
    f.write(content)
