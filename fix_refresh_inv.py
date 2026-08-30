import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Replace _refresh_inventory with a safe version
old_func = """func _refresh_inventory() -> void:
	for child in inventory_grid.get_children():
		child.queue_free()
		
	# Clear details
	_show_item_details("")
	
	var combined = {}
	for id in InventoryManager.inventory:
		combined[id] = InventoryManager.inventory[id]
	for id in InventoryManager.temp_inventory:
		if combined.has(id): combined[id] += InventoryManager.temp_inventory[id]
		else: combined[id] = InventoryManager.temp_inventory[id]
		
	for item_id in combined:
		if combined[item_id] <= 0: continue
		var btn = TextureButton.new()
		btn.texture_normal = ItemDB.get_icon(item_id)
		btn.custom_minimum_size = Vector2(48, 48)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		btn.ignore_texture_size = true
		
		# Show count if > 1
		if combined[item_id] > 1:
			var lbl = Label.new()
			lbl.text = str(combined[item_id])
			lbl.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
			lbl.theme_override_colors.font_shadow_color = Color(0,0,0,1)
			lbl.theme_override_constants.shadow_offset_x = 1
			lbl.theme_override_constants.shadow_offset_y = 1
			lbl.theme_override_font_sizes.font_size = 12
			lbl.position = Vector2(28, 30) # roughly bottom right
			btn.add_child(lbl)
			
		btn.pressed.connect(func(): _show_item_details(item_id))
		inventory_grid.add_child(btn)"""

new_func = """func _refresh_inventory() -> void:
	_show_item_details("")
	for child in inventory_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()"""

content = content.replace(old_func, new_func)

# We should also fix _refresh_character_tab because it probably deletes char_inv_grid!
old_char_func = """func _refresh_character_tab() -> void:
	for child in char_equip_grid.get_children():
		child.queue_free()
	for child in char_inv_grid.get_children():
		child.queue_free()
		
	var slots = ["chest", "boots", "weapon"]
	for s in slots:
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(48, 48)
		var icon = TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		
		var eq_id = InventoryManager.equipment.get(s, "")
		if eq_id != "":
			icon.texture = ItemDB.get_icon(eq_id)
			
		slot_panel.add_child(icon)
		
		if eq_id != "":
			var btn = Button.new()
			btn.text = "Снять"
			btn.pressed.connect(func(): 
				InventoryManager.unequip(s)
				_refresh_character_tab()
			)
			slot_panel.add_child(btn)
			
		char_equip_grid.add_child(slot_panel)
		
	# Populate char_inv_grid similarly
	var combined = {}
	for id in InventoryManager.inventory:
		combined[id] = InventoryManager.inventory[id]
	for item_id in combined:
		if combined[item_id] <= 0: continue
		var btn = TextureButton.new()
		btn.texture_normal = ItemDB.get_icon(item_id)
		btn.custom_minimum_size = Vector2(48, 48)
		btn.stretch_mode = TextureButton.STRETCH_KEEP_CENTERED
		btn.ignore_texture_size = true
		btn.pressed.connect(func():
			InventoryManager.equip(item_id)
			_refresh_character_tab()
		)
		char_inv_grid.add_child(btn)"""

new_char_func = """func _refresh_character_tab() -> void:
	# Keep char_inv_grid intact and just refresh its slots
	for child in char_inv_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()
			
	# Update equipment grid (rebuilding is fine for equip slots since we haven't ported them to drag-drop yet)
	for child in char_equip_grid.get_children():
		child.queue_free()
		
	var slots = ["chest", "boots", "weapon"]
	for s in slots:
		var slot_panel = PanelContainer.new()
		slot_panel.custom_minimum_size = Vector2(48, 48)
		var icon = TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		
		var eq_id = InventoryManager.equipment.get(s, "")
		if eq_id != "":
			icon.texture = ItemDB.get_icon(eq_id)
			
		slot_panel.add_child(icon)
		
		if eq_id != "":
			var btn = Button.new()
			btn.text = "Снять"
			btn.pressed.connect(func(): 
				InventoryManager.unequip(s)
				_refresh_character_tab()
			)
			slot_panel.add_child(btn)
			
		char_equip_grid.add_child(slot_panel)"""

content = content.replace(old_char_func, new_char_func)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
