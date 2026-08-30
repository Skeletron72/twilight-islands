gd_content = """extends Control

const InventorySlotScene = preload("res://scenes/ui/inventory_slot.tscn")

@onready var player_grid = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/PlayerGrid
@onready var chest_grid = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ChestGrid

var current_chest: Node2D = null

func _ready() -> void:
	visible = false
	GameStateManager.inventory_changed.connect(_on_inventory_changed)

func _input(event: InputEvent) -> void:
	if visible and (event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory")):
		close()
		get_viewport().set_input_as_handled()

func open(chest_node: Node2D) -> void:
	current_chest = chest_node
	visible = true
	get_tree().paused = true
	_refresh_ui()

func close() -> void:
	visible = false
	current_chest = null
	get_tree().paused = false

func _on_inventory_changed() -> void:
	if visible:
		_refresh_ui()

func _refresh_ui() -> void:
	if not current_chest: return
	
	# Clear grids
	for child in player_grid.get_children():
		child.queue_free()
	for child in chest_grid.get_children():
		child.queue_free()
		
	# Build player inventory
	for item_id in InventoryManager.inventory.keys():
		var amt = InventoryManager.inventory[item_id]
		if amt > 0:
			var slot = InventorySlotScene.instantiate()
			player_grid.add_child(slot)
			slot.set_item(item_id, amt)
			# Override click behavior
			slot.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_transfer_to_chest(item_id)
			)
			
	# Build chest inventory
	for item_id in current_chest.inventory.keys():
		var amt = current_chest.inventory[item_id]
		if amt > 0:
			var slot = InventorySlotScene.instantiate()
			chest_grid.add_child(slot)
			slot.set_item(item_id, amt)
			slot.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_transfer_to_player(item_id)
			)
			
	# Pad chest grid to 4 slots minimum
	var slots_used = current_chest.inventory.keys().size()
	for i in range(max(0, 4 - slots_used)):
		var empty_slot = InventorySlotScene.instantiate()
		chest_grid.add_child(empty_slot)
		empty_slot.set_item("", 0)

func _transfer_to_chest(item_id: String) -> void:
	# Chest has max 4 items types
	if not current_chest.inventory.has(item_id) and current_chest.inventory.keys().size() >= 4:
		print("Сундук полон!")
		return
		
	# Move 1 item
	if InventoryManager.remove_item(item_id, 1):
		if current_chest.inventory.has(item_id):
			current_chest.inventory[item_id] += 1
		else:
			current_chest.inventory[item_id] = 1
		_refresh_ui()

func _transfer_to_player(item_id: String) -> void:
	if not current_chest.inventory.has(item_id): return
	
	if InventoryManager.add_item(item_id, 1):
		current_chest.inventory[item_id] -= 1
		if current_chest.inventory[item_id] <= 0:
			current_chest.inventory.erase(item_id)
		_refresh_ui()
"""

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(gd_content)

print("Created storage_ui.gd")
