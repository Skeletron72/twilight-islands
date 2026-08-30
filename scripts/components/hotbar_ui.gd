extends Control

var slots: Array = []
var active_slot_index: int = -1

func _ready() -> void:
	var container = $HBoxContainer
	for i in range(4):
		var slot_node = container.get_node("Slot" + str(i))
		slot_node.pivot_offset = slot_node.custom_minimum_size / 2.0
		slots.append(slot_node)
		
	# Setup initial visual state
	for i in range(4):
		_update_slot_visual(i, i == active_slot_index)
		
	InventoryManager.ui_slots_changed.connect(_on_ui_slots_changed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_up"): # Or scroll up
		var idx = active_slot_index - 1
		if idx < 0: idx = 3
		if active_slot_index == -1: idx = 3
		_set_active_slot(idx)
	elif event.is_action_pressed("ui_page_down"): # Or scroll down
		var idx = (active_slot_index + 1) % 4
		if active_slot_index == -1: idx = 0
		_set_active_slot(idx)
	
	# Number keys 1-4
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			_set_active_slot(event.keycode - KEY_1)
			
	# Handle using/eating item on left click or interact button
	var is_use_pressed = false
	if event.is_action_pressed("interact"):
		is_use_pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		is_use_pressed = true
		
	if is_use_pressed and active_slot_index != -1:
		var item_id = InventoryManager.ui_slots[active_slot_index]
		if item_id != "":
			var item_data = ItemDB.get_item(item_id)
			var consumed = false
			if item_data.has("hunger_restore"):
				GameStateManager.add_hunger(item_data["hunger_restore"])
				consumed = true
			if item_data.has("health_restore"):
				GameStateManager.heal(item_data["health_restore"])
				consumed = true
			if item_data.has("stamina_restore"):
				GameStateManager.add_stamina(item_data["stamina_restore"])
				consumed = true
				
			if consumed:
				InventoryManager.remove_item(item_id, 1)
				var p_color = item_data.get("particle_color", Color.WHITE)
				GameStateManager.item_consumed.emit(p_color)
				print("Съели ", item_data["name"])

func _set_active_slot(index: int) -> void:
	if index == active_slot_index:
		_animate_slot_selection(active_slot_index, false)
		active_slot_index = -1
		return
	
	var old_index = active_slot_index
	active_slot_index = index
	
	if old_index != -1:
		_animate_slot_selection(old_index, false)
	
	if active_slot_index != -1:
		_animate_slot_selection(active_slot_index, true)
		
		# Check if placeable
		var item_id = InventoryManager.ui_slots[active_slot_index]
		if item_id != "":
			var item_data = ItemDB.get_item(item_id)
			if item_data.get("placeable", false):
				PlacementManager.start_placement(item_id)
			else:
				PlacementManager.stop_placement()
		else:
			PlacementManager.stop_placement()
	else:
		PlacementManager.stop_placement()
	
func _animate_slot_selection(index: int, is_selected: bool) -> void:
	var slot = slots[index]
	var target_scale = Vector2(1.2, 1.2) if is_selected else Vector2(1.0, 1.0)
	
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(slot, "scale", target_scale, 0.1)

func _update_slot_visual(index: int, is_selected: bool) -> void:
	var slot = slots[index]
	slot.scale = Vector2(1.2, 1.2) if is_selected else Vector2(1.0, 1.0)
	
	var item_id = InventoryManager.ui_slots[index]
	var amount = InventoryManager.get_item_amount(item_id) if item_id != "" else 0
	
	var icon = slot.get_node("Icon")
	var shadow = slot.get_node("Shadow")
	var lbl = slot.get_node("Amount")
	
	if amount > 0 and item_id != "":
		icon.texture = ItemDB.get_icon(item_id)
		shadow.show()
		lbl.text = str(amount)
		if amount > 1: lbl.show()
		else: lbl.hide()
	else:
		icon.texture = null
		shadow.hide()
		lbl.hide()

func _on_ui_slots_changed(idx: int) -> void:
	if idx < 4:
		_update_slot_visual(idx, idx == active_slot_index)
		
		if idx == active_slot_index and PlacementManager.is_placing:
			var item_id = InventoryManager.ui_slots[idx]
			if item_id != PlacementManager.current_item_id or InventoryManager.get_item_amount(item_id) <= 0:
				PlacementManager.stop_placement()
				if item_id == "" or InventoryManager.get_item_amount(item_id) <= 0:
					_set_active_slot(idx) # toggle off if ran out

