extends Control

const InventorySlotScene = preload("res://scenes/ui/inventory_slot.tscn")

@onready var player_grid = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/LeftPage/PlayerGrid
@onready var chest_grid = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/ChestGrid
@onready var break_button = $DimBackground/CenterContainer/BookPanel/Pages/HBoxContainer/RightPage/BreakButton

var current_chest: Node2D = null

func _ready() -> void:
	visible = false
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	if break_button:
		break_button.pressed.connect(_on_break_button_pressed)

func _on_break_button_pressed() -> void:
	if current_chest and current_chest.has_method("break_crate"):
		var chest = current_chest
		close()
		chest.break_crate()

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
	if current_chest and current_chest.has_method("close_chest"):
		current_chest.close_chest()
	current_chest = null
	get_tree().paused = false

func _on_inventory_changed(item_id: String = "", new_amount: int = 0) -> void:
	if visible:
		_refresh_ui()

func _refresh_ui() -> void:
	if not current_chest: return
	
	# Очищаем слоты
	for child in player_grid.get_children():
		child.queue_free()
	for child in chest_grid.get_children():
		child.queue_free()
		
	# 1. Рюкзак игрока: ровно 8 слотов (сетка 4x2)
	var p_items: Array = []
	for item_id in InventoryManager.inventory.keys():
		var amt = InventoryManager.inventory[item_id]
		if amt > 0:
			p_items.append({"id": item_id, "amt": amt})
			
	for i in range(8):
		var slot = InventorySlotScene.instantiate()
		player_grid.add_child(slot)
		if i < p_items.size():
			var it = p_items[i]
			slot.set_item(it["id"], it["amt"])
			var target_id = it["id"]
			slot.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_transfer_to_chest(target_id)
			)
		else:
			slot.set_item("", 0)
			
	# 2. Сундук: ровно 4 слота (сетка 2x2)
	var c_items: Array = []
	for item_id in current_chest.inventory.keys():
		var amt = current_chest.inventory[item_id]
		if amt > 0:
			c_items.append({"id": item_id, "amt": amt})
			
	for i in range(4):
		var slot = InventorySlotScene.instantiate()
		chest_grid.add_child(slot)
		if i < c_items.size():
			var it = c_items[i]
			slot.set_item(it["id"], it["amt"])
			var target_id = it["id"]
			slot.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
					_transfer_to_player(target_id)
			)
		else:
			slot.set_item("", 0)

func _transfer_to_chest(item_id: String) -> void:
	if not current_chest: return
	
	# Лимит ящика — ровно 4 предмета
	if not current_chest.inventory.has(item_id) and current_chest.inventory.keys().size() >= 4:
		print("Сундук полон!")
		return
		
	# Перенос 1 предмета в сундук
	if InventoryManager.remove_item(item_id, 1):
		if current_chest.inventory.has(item_id):
			current_chest.inventory[item_id] += 1
		else:
			current_chest.inventory[item_id] = 1
		_refresh_ui()

func _transfer_to_player(item_id: String) -> void:
	if not current_chest: return
	if not current_chest.inventory.has(item_id): return
	
	# Перенос 1 предмета в инвентарь игрока
	InventoryManager.add_item(item_id, 1)
	current_chest.inventory[item_id] -= 1
	if current_chest.inventory[item_id] <= 0:
		current_chest.inventory.erase(item_id)
	_refresh_ui()
