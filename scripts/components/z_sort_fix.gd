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

	if GameStateManager and GameStateManager.has_signal("day_changed"):
		GameStateManager.day_changed.connect(_on_day_changed)

	if HomeStateManager.workshop_built and HomeStateManager.workshop_pos != Vector2.ZERO:
		HomeStateManager.check_workshop_progress()
		_restore_workshop()

func _on_day_changed(_new_day: int) -> void:
	if HomeStateManager.check_workshop_progress():
		var ws = get_node_or_null("ShipwrightWorkshop")
		if ws and ws.has_method("finish_construction"):
			ws.finish_construction()
		var boat = get_node_or_null("Boat")
		if boat:
			boat.global_position = HomeStateManager.get_workshop_boat_pos()
			if boat.has_method("_update_visuals"):
				boat._update_visuals()

func _restore_workshop() -> void:
	if not has_node("ShipwrightWorkshop"):
		var workshop_scene = load("res://scenes/objects/buildings/shipwright_workshop.tscn") as PackedScene
		if workshop_scene:
			var ws = workshop_scene.instantiate()
			ws.name = "ShipwrightWorkshop"
			ws.global_position = HomeStateManager.workshop_pos
			if ws.has_method("setup_orientation"):
				ws.setup_orientation(HomeStateManager.workshop_orientation)
			if ws.has_method("set_under_construction"):
				ws.set_under_construction(HomeStateManager.workshop_under_construction)
			add_child(ws)

	var boat = get_node_or_null("Boat")
	if boat:
		boat.global_position = HomeStateManager.get_workshop_boat_pos()
		if boat.has_method("_update_visuals"):
			boat._update_visuals()

	var finn = get_node_or_null("NpcShipwright")
	if finn:
		finn.global_position = HomeStateManager.get_workshop_npc_pos()
		if "home_origin" in finn:
			finn.home_origin = finn.global_position

func _process(_delta: float) -> void:
	for child in get_children():
		if child is Node2D:
			if child.name == "TentInterior" or child is TentInterior or child.name == "WorkshopInterior" or child is WorkshopInterior:
				continue
			if child.name == "WorldMap":
				child.z_index = -4000
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
