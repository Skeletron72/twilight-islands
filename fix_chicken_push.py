import re

with open('scripts/components/chicken.gd', 'r') as f:
    content = f.read()

# Add last_safe_position
if 'var last_safe_position: Vector2' not in content:
    content = content.replace('var direction: Vector2 = Vector2.ZERO', 'var direction: Vector2 = Vector2.ZERO\nvar last_safe_position: Vector2 = Vector2.ZERO')

# Update _ready
if 'last_safe_position = global_position' not in content:
    content = content.replace('func _ready() -> void:\n\t_pick_new_state()', 'func _ready() -> void:\n\t_pick_new_state()\n\tlast_safe_position = global_position')

# Update _physics_process to check actual position after move_and_slide
new_water_check = """		move_and_slide()
		
		# Анимация ходьбы"""

# Replace the existing move_and_slide with the rubber-band logic
rubber_band = """		move_and_slide()
		
		# Продвинутая проверка воды (не дает затолкать)
		var is_in_water = false
		if water_layer:
			var map_pos = water_layer.local_to_map(global_position + Vector2(0, -2))
			if water_layer.get_cell_source_id(map_pos) != -1:
				is_in_water = true
				for child in world_map.get_children():
					if child is TileMapLayer and child != water_layer:
						if child.get_cell_source_id(map_pos) != -1:
							is_in_water = false
							break
		
		if is_in_water:
			global_position = last_safe_position
			direction = -direction # Отпрыгиваем
			_pick_new_state()
		else:
			last_safe_position = global_position
		
		# Анимация ходьбы"""

content = content.replace(new_water_check, rubber_band)

# Also apply rubber band to the idle state
idle_move = """	else:
		velocity = Vector2.ZERO
		move_and_slide()
		# Анимация покоя"""
		
idle_rubber_band = """	else:
		velocity = Vector2.ZERO
		move_and_slide()
		
		var is_in_water = false
		var current_scene = get_tree().current_scene
		var world_map = current_scene.get_node_or_null("WorldMap")
		var water_layer = world_map.get_node_or_null("WaterLayer") if world_map else null
		if water_layer:
			var map_pos = water_layer.local_to_map(global_position + Vector2(0, -2))
			if water_layer.get_cell_source_id(map_pos) != -1:
				is_in_water = true
				for child in world_map.get_children():
					if child is TileMapLayer and child != water_layer:
						if child.get_cell_source_id(map_pos) != -1:
							is_in_water = false
							break
		
		if is_in_water:
			global_position = last_safe_position
		else:
			last_safe_position = global_position
			
		# Анимация покоя"""

content = content.replace(idle_move, idle_rubber_band)

with open('scripts/components/chicken.gd', 'w') as f:
    f.write(content)

