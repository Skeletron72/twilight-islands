extends Node

enum Mode { SAFE, RAID }
var current_mode: Mode = Mode.SAFE

# UI Slot Mapping (10 slots)
var ui_slots: Array = ["", "", "", "", "", "", "", ""]
signal ui_slots_changed(index: int)

# Safe inventory
var inventory: Dictionary = {}
# Temp inventory for raids
var temp_inventory: Dictionary = {}
var equipment: Dictionary = {"chest": "cloth_basic", "boots": "boots_basic"}
signal equipment_changed


signal inventory_changed(item_id: String, new_amount: int)

func _ready() -> void:
	# Populate UI slots with existing items on startup
	for item_id in inventory.keys():
		_update_ui_slots(item_id, inventory[item_id])

func add_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0: return
	
	var target_inv = inventory if current_mode == Mode.SAFE else temp_inventory
	
	if target_inv.has(item_id):
		target_inv[item_id] += amount
	else:
		target_inv[item_id] = amount
		
	# Combine for display/UI if needed, but for now just signal the total
	_update_ui_slots(item_id, get_item_amount(item_id))
	inventory_changed.emit(item_id, get_item_amount(item_id))

func remove_item(item_id: String, amount: int = 1) -> bool:
	if get_item_amount(item_id) < amount:
		return false
		
	# Try removing from temp first, then safe
	var remaining_to_remove = amount
	
	if temp_inventory.has(item_id):
		var temp_amt = temp_inventory[item_id]
		var taking = min(temp_amt, remaining_to_remove)
		temp_inventory[item_id] -= taking
		remaining_to_remove -= taking
		if temp_inventory[item_id] <= 0:
			temp_inventory.erase(item_id)
			
	if remaining_to_remove > 0 and inventory.has(item_id):
		inventory[item_id] -= remaining_to_remove
		if inventory[item_id] <= 0:
			inventory.erase(item_id)
			
	_update_ui_slots(item_id, get_item_amount(item_id))
	inventory_changed.emit(item_id, get_item_amount(item_id))
	return true

func get_item_amount(item_id: String) -> int:
	var total = 0
	if inventory.has(item_id): total += inventory[item_id]
	if temp_inventory.has(item_id): total += temp_inventory[item_id]
	return total

func set_mode(new_mode: Mode) -> void:
	current_mode = new_mode

func commit_temp_inventory() -> void:
	for item_id in temp_inventory:
		if inventory.has(item_id):
			inventory[item_id] += temp_inventory[item_id]
		else:
			inventory[item_id] = temp_inventory[item_id]
	temp_inventory.clear()
	# Emit signals to refresh UI
	for item_id in inventory:
		_update_ui_slots(item_id, get_item_amount(item_id))
		inventory_changed.emit(item_id, get_item_amount(item_id))

func clear_temp_inventory() -> void:
	# Keep track of what we lost for UI notification
	var lost_items = temp_inventory.duplicate()
	temp_inventory.clear()
	
	for item_id in lost_items:
		_update_ui_slots(item_id, get_item_amount(item_id))
		inventory_changed.emit(item_id, get_item_amount(item_id))

func equip(item_id: String) -> void:
	var item = ItemDB.get_item(item_id)
	if not item.has("equip_slot"): return
	
	var slot = item["equip_slot"]
	# Unequip current if exists
	if equipment.has(slot) and equipment[slot] != "":
		add_item(equipment[slot], 1)
		
	# Remove from inventory
	remove_item(item_id, 1)
	
	equipment[slot] = item_id
	equipment_changed.emit()

func unequip(slot: String) -> void:
	if equipment.has(slot) and equipment[slot] != "":
		add_item(equipment[slot], 1)
		equipment[slot] = ""
		equipment_changed.emit()

func _update_ui_slots(item_id: String, new_amount: int) -> void:
	if new_amount > 0:
		# If it's already in a slot, just emit update for amount label
		if ui_slots.has(item_id):
			ui_slots_changed.emit(ui_slots.find(item_id))
			return
		# Find empty slot
		for i in range(8):
			if ui_slots[i] == "":
				ui_slots[i] = item_id
				ui_slots_changed.emit(i)
				return
	else:
		# Item removed completely, clear its slot
		for i in range(8):
			if ui_slots[i] == item_id:
				ui_slots[i] = ""
				ui_slots_changed.emit(i)
				return
func swap_ui_slots(idx1: int, idx2: int) -> void:
	if idx1 < 0 or idx1 >= 8 or idx2 < 0 or idx2 >= 8: return
	var temp = ui_slots[idx1]
	ui_slots[idx1] = ui_slots[idx2]
	ui_slots[idx2] = temp
	ui_slots_changed.emit(idx1)
	ui_slots_changed.emit(idx2)
