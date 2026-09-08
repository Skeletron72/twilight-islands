extends Node

# Ручная Z-сортировка по глобальной Y-позиции.
# Этот скрипт прикреплен к HomeIsland (self).
# Все объекты (Player, Chicken, а также деревья/камни/пальмы внутри зон)
# получают абсолютный z_index равный их глобальной Y-координате.

func _ready() -> void:
	var world_map = get_node_or_null("WorldMap")
	if world_map:
		world_map.z_index = -4000
		world_map.z_as_relative = false

func _process(_delta: float) -> void:
	for child in get_children():
		if child is Node2D:
			if child.name == "TentInterior" or child is TentInterior:
				continue
			if child.name == "WorldMap":
				child.z_index = -4000
				child.z_as_relative = false
				continue
			if child is DroppedItem and child.is_in_air:
				child.z_index = int(child.global_position.y) + 160
				child.z_as_relative = false
				continue
			child.z_index = int(child.global_position.y)
			child.z_as_relative = false
			
			# Если это BiomeZone или контейнер объектов (деревья, пальмы, камни внутри)
			if child is Area2D or child.name.ends_with("Zone") or child.name == "Interactables":
				for sub in child.get_children():
					if sub is Node2D and not sub is CollisionPolygon2D and not sub is Polygon2D:
						sub.z_index = int(sub.global_position.y)
						sub.z_as_relative = false
