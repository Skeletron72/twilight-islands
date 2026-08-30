import re

with open('scripts/components/destructible.gd', 'r') as f:
    content = f.read()

# Add drop_variance
if '@export var drop_variance: int = 0' not in content:
    content = content.replace('@export var drop_amount: int = 1', '@export var drop_amount: int = 1\n@export var drop_variance: int = 0')

# Update _spawn_drop
old_spawn = r'(func _spawn_drop\(amount: int\) -> void:\n\tvar dropped_scene = preload\("res://scenes/objects/dropped_item\.tscn"\)\n\tvar drop = dropped_scene\.instantiate\(\)\n\tdrop\.global_position = global_position\n\tdrop\.setup\(resource_id, amount\)\n\tget_tree\(\)\.current_scene\.add_child\(drop\))'

new_spawn = """func _spawn_drop(base_amount: int) -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	var total_amount = base_amount + randi_range(0, drop_variance)
	for i in range(total_amount):
		var drop = dropped_scene.instantiate()
		drop.global_position = global_position
		drop.setup(resource_id, 1) # Each physical item is worth 1
		get_tree().current_scene.add_child(drop)"""

content = re.sub(old_spawn, new_spawn, content)

with open('scripts/components/destructible.gd', 'w') as f:
    f.write(content)
