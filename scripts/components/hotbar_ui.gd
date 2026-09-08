extends Control

const SLOT_COUNT: int = 4

var slots: Array = []
var active_slot_index: int = -1
var selector_tweens: Dictionary = {}

var sel_wide_tex: AtlasTexture
var sel_narrow_tex: AtlasTexture

func _ready() -> void:
	var sel_img = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Selectors.png")
	sel_wide_tex = AtlasTexture.new()
	sel_wide_tex.atlas = sel_img
	sel_wide_tex.region = Rect2(96, 768, 48, 48)
	
	sel_narrow_tex = AtlasTexture.new()
	sel_narrow_tex.atlas = sel_img
	sel_narrow_tex.region = Rect2(144, 768, 48, 48)

	slots.clear()
	var container = $HBoxContainer
	for i in range(SLOT_COUNT):
		var slot_node = container.get_node_or_null("Slot" + str(i))
		if slot_node:
			slot_node.pivot_offset = slot_node.custom_minimum_size / 2.0
			slots.append(slot_node)
			
			# Setup mouse clicks directly on hotbar slots
			var slot_idx = i
			slot_node.gui_input.connect(func(event):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_set_active_slot(slot_idx)
			)
		
	# Setup initial visual state
	for i in range(slots.size()):
		_update_slot_visual(i, i == active_slot_index)
		
	if not InventoryManager.ui_slots_changed.is_connected(_on_ui_slots_changed):
		InventoryManager.ui_slots_changed.connect(_on_ui_slots_changed)
	if not InventoryManager.inventory_changed.is_connected(_on_inventory_changed):
		InventoryManager.inventory_changed.connect(_on_inventory_changed)

func _input(event: InputEvent) -> void:
	# Scroll wheel to cycle hotbar
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var idx = active_slot_index - 1
			if idx < 0: idx = slots.size() - 1
			_set_active_slot(idx)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var idx = (active_slot_index + 1) % slots.size()
			_set_active_slot(idx)
			get_viewport().set_input_as_handled()
			
	if event.is_action_pressed("ui_page_up"):
		var idx = active_slot_index - 1
		if idx < 0: idx = slots.size() - 1
		_set_active_slot(idx)
	elif event.is_action_pressed("ui_page_down"):
		var idx = (active_slot_index + 1) % slots.size()
		_set_active_slot(idx)
	
	# Number keys 1-6
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= (KEY_1 + slots.size() - 1):
			_set_active_slot(event.keycode - KEY_1)
			
	# Handle using/eating item on left click or interact button
	var is_use_pressed = false
	if event.is_action_pressed("interact"):
		is_use_pressed = true
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		# Don't consume if clicking on UI
		var ui_layer = get_tree().current_scene.get_node_or_null("UILayer")
		if ui_layer:
			var book = ui_layer.get_node_or_null("BookUI")
			if book and book.visible: return
			var storage = ui_layer.get_node_or_null("StorageUI")
			if storage and storage.visible: return
		is_use_pressed = true
		
	if is_use_pressed and active_slot_index != -1 and not PlacementManager.is_placing:
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
				GameStateManager.item_consumed.emit(item_id, p_color)
				get_viewport().set_input_as_handled()
				print("Съели ", item_data["name"])

func _set_active_slot(index: int) -> void:
	if index == active_slot_index:
		_animate_slot_selection(active_slot_index, false)
		active_slot_index = -1
		PlacementManager.stop_placement()
		return
	
	var old_index = active_slot_index
	active_slot_index = index
	
	if old_index != -1 and old_index < slots.size():
		_animate_slot_selection(old_index, false)
	
	if active_slot_index != -1 and active_slot_index < slots.size():
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
	if index < 0 or index >= slots.size(): return
	var slot = slots[index]
	var selector = slot.get_node_or_null("Selector") as TextureRect
	
	if selector_tweens.has(index) and selector_tweens[index]:
		selector_tweens[index].kill()
		selector_tweens.erase(index)
		
	if is_selected:
		# Quick punch on slot container
		var punch_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		punch_tween.tween_property(slot, "scale", Vector2(1.06, 1.06), 0.1)
		punch_tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.08)
		
		if selector:
			selector.show()
			selector.pivot_offset = selector.size / 2.0
			selector.scale = Vector2(0.94, 0.94)
			selector.texture = sel_narrow_tex
			
			var st = create_tween().set_loops()
			# Expand outward & use wide corners
			st.tween_callback(func():
				if selector: selector.texture = sel_wide_tex
			)
			st.tween_property(selector, "scale", Vector2(1.08, 1.08), 0.35)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			# Contract inward & use narrow corners
			st.tween_callback(func():
				if selector: selector.texture = sel_narrow_tex
			)
			st.tween_property(selector, "scale", Vector2(0.94, 0.94), 0.35)\
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
				
			selector_tweens[index] = st
	else:
		var exit_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		exit_tween.tween_property(slot, "scale", Vector2(1.0, 1.0), 0.08)
		if selector:
			selector.hide()
			selector.scale = Vector2.ONE

func _update_slot_visual(index: int, is_selected: bool) -> void:
	if index < 0 or index >= slots.size(): return
	var slot = slots[index]
	_animate_slot_selection(index, is_selected)
		
	var item_id = ""
	var amount = 0
	
	if index < InventoryManager.ui_slots.size():
		item_id = InventoryManager.ui_slots[index]
		amount = InventoryManager.get_item_amount(item_id) if item_id != "" else 0
		
	var icon = slot.get_node("Icon")
	var amount_label = slot.get_node("Amount")
	
	if amount > 0 and item_id != "":
		icon.texture = ItemDB.get_icon(item_id)
		amount_label.text = str(amount)
		if amount > 1:
			amount_label.show()
		else:
			amount_label.hide()
			
		var item_data = ItemDB.get_item(item_id)
		var item_name = item_data.get("name", item_id)
		var item_desc = item_data.get("desc", "")
		slot.tooltip_text = item_name if item_desc == "" else "%s\n%s" % [item_name, item_desc]
	else:
		icon.texture = null
		amount_label.hide()
		slot.tooltip_text = ""

func _on_ui_slots_changed(index: int) -> void:
	if index < slots.size():
		_update_slot_visual(index, index == active_slot_index)
		# Update placement if active slot changed
		if index == active_slot_index:
			var item_id = InventoryManager.ui_slots[active_slot_index]
			if item_id != "":
				var item_data = ItemDB.get_item(item_id)
				if item_data.get("placeable", false):
					PlacementManager.start_placement(item_id)
				else:
					PlacementManager.stop_placement()
			else:
				PlacementManager.stop_placement()

func _on_inventory_changed(_item_id: String, _amount: int) -> void:
	for i in range(slots.size()):
		_update_slot_visual(i, i == active_slot_index)
