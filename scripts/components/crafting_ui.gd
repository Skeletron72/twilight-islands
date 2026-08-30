extends Control

@onready var craft_button: Button = $Panel/VBoxContainer/CraftButton
@onready var status_label: Label = $Panel/VBoxContainer/StatusLabel

func _ready() -> void:
	craft_button.pressed.connect(_on_craft_pressed)

func _on_craft_pressed() -> void:
	if InventoryManager.get_item_amount("wood") >= 5 and InventoryManager.get_item_amount("stone") >= 3:
		InventoryManager.remove_item("wood", 5)
		InventoryManager.remove_item("stone", 3)
		status_label.text = "Boat Upgraded!"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Not enough resources (5 Wood, 3 Stone)"
		status_label.modulate = Color.RED
