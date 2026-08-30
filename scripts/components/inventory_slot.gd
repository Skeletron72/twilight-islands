extends Control

signal item_clicked(item_id: String)

var slot_index: int = -1
var custom_item_id: String = ""
var custom_amount: int = -1

@onready var icon_rect: TextureRect = $Icon
@onready var shadow_rect: TextureRect = $Shadow
@onready var amount_label: Label = $Amount

func set_slot_index(idx: int) -> void:
	slot_index = idx
	_refresh()

func set_item(id: String, amt: int) -> void:
	custom_item_id = id
	custom_amount = amt
	_refresh()

func _refresh() -> void:
	var item_id = ""
	var amount = 0
	
	if custom_amount != -1:
		item_id = custom_item_id
		amount = custom_amount
	else:
		if slot_index < 0 or slot_index >= InventoryManager.ui_slots.size(): return
		item_id = InventoryManager.ui_slots[slot_index]
		amount = InventoryManager.get_item_amount(item_id) if item_id != "" else 0
	
	if amount > 0 and item_id != "":
		icon_rect.texture = ItemDB.get_icon(item_id)
		shadow_rect.show()
		amount_label.text = str(amount)
		if amount > 1:
			amount_label.show()
		else:
			amount_label.hide()
	else:
		icon_rect.texture = null
		shadow_rect.hide()
		amount_label.hide()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_index < 0: return null # Disable drag for custom slots for now
	var item_id = InventoryManager.ui_slots[slot_index]
	if item_id == "" or InventoryManager.get_item_amount(item_id) <= 0: return null
	
	# Create drag preview (just a texture rect floating with the mouse)
	var preview = TextureRect.new()
	preview.texture = icon_rect.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(48, 48)
	preview.modulate.a = 0.8
	
	var control = Control.new()
	preview.position = -Vector2(24, 24) # Center on cursor
	control.add_child(preview)
	set_drag_preview(control)
	
	return {"type": "inventory_slot", "slot_index": slot_index}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if slot_index < 0: return false # Disable drag for custom slots for now
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "inventory_slot":
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if slot_index < 0: return
	var from_idx = data["slot_index"]
	if from_idx != slot_index:
		InventoryManager.swap_ui_slots(from_idx, slot_index)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if custom_amount != -1:
			pass # StorageUI handles gui_input override
		elif slot_index >= 0 and slot_index < InventoryManager.ui_slots.size():
			var item_id = InventoryManager.ui_slots[slot_index]
			if item_id != "":
				item_clicked.emit(item_id)
