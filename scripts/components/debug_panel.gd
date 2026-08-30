extends Control

@onready var grid = $Panel/VBox/ScrollContainer/GridContainer
@onready var close_btn = $Panel/VBox/Header/CloseBtn

func _ready() -> void:
	hide()
	close_btn.pressed.connect(hide)
	
	for item_id in ItemDB.ITEMS.keys():
		var btn = Button.new()
		var item = ItemDB.ITEMS[item_id]
		var item_name = item.get("name", item_id)
		
		var max_stack = item.get("max_stack", 99)
		var give_amount = 10 if max_stack > 1 else 1
		
		btn.text = "+%d %s" % [give_amount, item_name]
		btn.icon = ItemDB.get_icon(item_id)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.pressed.connect(func():
			InventoryManager.add_item(item_id, give_amount)
			print("Debug: Added %d %s" % [give_amount, item_name])
		)
		grid.add_child(btn)

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		visible = not visible
