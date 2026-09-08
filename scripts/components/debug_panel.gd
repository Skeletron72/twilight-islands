extends Control

@onready var grid = $Panel/VBox/ScrollContainer/GridContainer
@onready var close_btn = $Panel/VBox/Header/CloseBtn

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	hide()
	close_btn.pressed.connect(hide)
	
	# Extra convenience button: boat resources
	var boat_btn = Button.new()
	boat_btn.text = "⛵ Ресурсы для лодки"
	boat_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	boat_btn.pressed.connect(func():
		InventoryManager.add_item("wood", 30)
		InventoryManager.add_item("stick", 15)
		InventoryManager.add_item("stone", 15)
		InventoryManager.add_item("cloth_basic", 10)
		print("Debug: Added boat upgrade resources!")
	)
	grid.add_child(boat_btn)

	for item_id in ItemDB.ITEMS.keys():
		var btn = Button.new()
		var item = ItemDB.ITEMS[item_id]
		var item_name = item.get("name", item_id)
		
		var max_stack = item.get("max_stack", 99)
		var give_amount = 10 if max_stack > 1 else 1
		
		btn.text = "+%d %s" % [give_amount, item_name]
		btn.icon = ItemDB.get_icon(item_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		var id_copy = item_id
		var amt_copy = give_amount
		var name_copy = item_name
		btn.pressed.connect(func():
			InventoryManager.add_item(id_copy, amt_copy)
			print("Debug: Added %d %s" % [amt_copy, name_copy])
		)
		grid.add_child(btn)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3:
			visible = not visible
		elif event.keycode == KEY_F4:
			InventoryManager.add_item("wood", 30)
			InventoryManager.add_item("stick", 15)
			InventoryManager.add_item("stone", 15)
			InventoryManager.add_item("cloth_basic", 10)
			print("Debug shortcut: Added boat resources!")
