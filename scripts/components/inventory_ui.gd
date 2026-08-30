extends Control

@onready var container = $PanelContainer/HBoxContainer

func _ready() -> void:
	_update_ui()
	# For simplicity, poll inventory
	var timer = Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(_update_ui)
	add_child(timer)

func _update_ui() -> void:
	# Clear old
	for child in container.get_children():
		child.queue_free()
		
	# Combine both inventories
	var combined = {}
	for id in InventoryManager.inventory: combined[id] = InventoryManager.inventory[id]
	for id in InventoryManager.temp_inventory:
		if combined.has(id): combined[id] += InventoryManager.temp_inventory[id]
		else: combined[id] = InventoryManager.temp_inventory[id]
		
	# Stardew style hotbar (show up to 9 slots)
	var slots_to_show = 9
	var keys = combined.keys()
	
	for i in range(slots_to_show):
		var slot_panel = Panel.new()
		slot_panel.custom_minimum_size = Vector2(36, 36)
		
		# Simple style for each slot
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.8, 0.8, 0.8, 0.8)
		style.set_border_width_all(2)
		style.border_color = Color(0.3, 0.3, 0.3, 1)
		style.set_corner_radius_all(4)
		slot_panel.add_theme_stylebox_override("panel", style)
		
		if i < keys.size():
			var id = keys[i]
			var amount = combined[id]
			
			if amount > 0:
				var icon = TextureRect.new()
				icon.texture = ItemDB.get_icon(id)
				icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
				icon.set_anchors_preset(Control.PRESET_FULL_RECT)
				
				var label = Label.new()
				label.text = str(amount)
				label.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
				label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				label.add_theme_font_size_override("font_size", 12)
				label.add_theme_color_override("font_outline_color", Color.BLACK)
				label.add_theme_constant_override("outline_size", 4)
				
				if InventoryManager.temp_inventory.has(id) and InventoryManager.temp_inventory[id] > 0:
					label.modulate = Color.YELLOW
					
				slot_panel.add_child(icon)
				slot_panel.add_child(label)
		
		container.add_child(slot_panel)
