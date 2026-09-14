extends Node

enum Mode { SAFE, RAID }
var current_mode: Mode = Mode.SAFE

# UI Slot Mapping (10 slots)
var ui_slots: Array = ["", "", "", "", "", "", "", ""]
signal ui_slots_changed(index: int)
var active_slot_index: int = -1
signal active_slot_changed(index: int)

func get_active_item_id() -> String:
	if active_slot_index >= 0 and active_slot_index < ui_slots.size():
		return ui_slots[active_slot_index]
	return ""

func set_active_slot(index: int) -> void:
	if active_slot_index != index:
		active_slot_index = index
		active_slot_changed.emit(index)

# Safe inventory
var inventory: Dictionary = {}
# Temp inventory for raids
var temp_inventory: Dictionary = {}
var equipment: Dictionary = {
	"head": "",
	"accessory": "",
	"chest": "cloth_basic",
	"artifact": "",
	"boots": "boots_basic"
}
signal equipment_changed


signal inventory_changed(item_id: String, new_amount: int)

func _ready() -> void:
	# Populate UI slots with existing items on startup
	for item_id in inventory.keys():
		_update_ui_slots(item_id, inventory[item_id])
		if ItemDB:
			ItemDB.check_discovery(item_id)

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
	
	if ItemDB:
		ItemDB.check_discovery(item_id)

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

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_item_amount(item_id) >= amount

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
				if active_slot_index == i:
					set_active_slot(-1)
				return
func swap_ui_slots(idx1: int, idx2: int) -> void:
	if idx1 < 0 or idx1 >= 8 or idx2 < 0 or idx2 >= 8: return
	var temp = ui_slots[idx1]
	ui_slots[idx1] = ui_slots[idx2]
	ui_slots[idx2] = temp
	ui_slots_changed.emit(idx1)
	ui_slots_changed.emit(idx2)

# Drops amount of item_id into the world near the player position.
func drop_item(item_id: String, amount: int, world_pos: Vector2 = Vector2.ZERO) -> void:
	if item_id == "" or amount <= 0: return
	if get_item_amount(item_id) < amount: return

	var spawn_pos = world_pos
	if spawn_pos == Vector2.ZERO:
		var tree = Engine.get_main_loop() as SceneTree
		if tree:
			var p = tree.get_first_node_in_group("player")
			if p:
				spawn_pos = p.global_position + Vector2(randf_range(-10, 10), 12)

	remove_item(item_id, amount)

	var tree2 = Engine.get_main_loop() as SceneTree
	if tree2:
		var scene = load("res://scenes/objects/dropped_item.tscn")
		if scene:
			var drop = scene.instantiate()
			drop.item_id = item_id
			drop.amount = amount
			drop.pickup_delay = 1.5
			drop.global_position = spawn_pos
			var current = tree2.current_scene
			if current:
				current.add_child(drop)

# Transfer exactly 'amount' items from slot from_idx to slot to_idx.
# If to_idx already has the same item, stack. If empty, place there.
# If different item, swap (standard behavior). 
func transfer_partial(from_idx: int, to_idx: int, amount: int) -> void:
	if from_idx < 0 or from_idx >= 8 or to_idx < 0 or to_idx >= 8: return
	if from_idx == to_idx: return
	var from_item = ui_slots[from_idx]
	var to_item = ui_slots[to_idx]
	if from_item == "": return
	var avail = get_item_amount(from_item)
	var transfer_amt = min(amount, avail)
	if transfer_amt <= 0: return

	if to_item == "" or to_item == from_item:
		# Simple partial move
		if not remove_item(from_item, transfer_amt): return
		# If from slot now empty, clear it
		if get_item_amount(from_item) <= 0:
			for i in range(8):
				if ui_slots[i] == from_item:
					ui_slots[i] = ""
					ui_slots_changed.emit(i)
					break
		# Add to target inventory slot
		if ui_slots[to_idx] == "":
			ui_slots[to_idx] = from_item
		add_item(from_item, transfer_amt)
		ui_slots_changed.emit(from_idx)
		ui_slots_changed.emit(to_idx)
	else:
		# Different items — full swap
		swap_ui_slots(from_idx, to_idx)

# Move item in slot hotbar_idx to the first free inventory slot (bag area, indices 0-7)
# or vice versa. We use this for RMB quick-transfer.
# 'from_slot_idx' is the ui_slots index; we try to move it to first empty slot.
# Returns true if successful.
func quick_transfer(from_slot_idx: int) -> bool:
	if from_slot_idx < 0 or from_slot_idx >= 8: return false
	var item_id = ui_slots[from_slot_idx]
	if item_id == "": return false
	# Find first empty slot that isn't from_slot_idx
	for i in range(8):
		if i != from_slot_idx and ui_slots[i] == "":
			ui_slots[i] = item_id
			ui_slots[from_slot_idx] = ""
			ui_slots_changed.emit(from_slot_idx)
			ui_slots_changed.emit(i)
			return true
	return false

