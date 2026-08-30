import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Connect signal
old_ready = """	GameStateManager.player_hurt.connect(_on_hurt)
	GameStateManager.player_died.connect(_on_died)
	InventoryManager.equipment_changed.connect(_update_equipment_visuals)"""

new_ready = """	GameStateManager.player_hurt.connect(_on_hurt)
	GameStateManager.player_died.connect(_on_died)
	GameStateManager.item_consumed.connect(_on_item_consumed)
	InventoryManager.equipment_changed.connect(_update_equipment_visuals)"""

content = content.replace(old_ready, new_ready)

# Add handler function
particle_func = """
func _on_item_consumed(p_color: Color) -> void:
	var particle_scene = load("res://scenes/vfx/eat_particles.tscn")
	if particle_scene:
		var inst = particle_scene.instantiate()
		inst.color = p_color
		# Set at player's head/mouth height
		inst.position = Vector2(0, -10)
		add_child(inst)
"""

content += particle_func

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
