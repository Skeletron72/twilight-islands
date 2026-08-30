import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Replace entire _refresh_inventory function
new_inv = """func _refresh_inventory() -> void:
	_show_item_details("")
	for child in inventory_grid.get_children():
		if child.has_method("_refresh"):
			child._refresh()"""

# We must be careful because _refresh_inventory ends when _show_item_details starts
content = re.sub(r'func _refresh_inventory\(\) -> void:.*?func _show_item_details', new_inv + '\n\nfunc _show_item_details', content, flags=re.DOTALL)

# Replace entire _refresh_character_tab function
new_char = """func _refresh_character_tab() -> void:
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

# _refresh_character_tab goes up to _refresh_craft_tab
content = re.sub(r'func _refresh_character_tab\(\) -> void:.*?func _refresh_craft_tab', new_char + '\n\nfunc _refresh_craft_tab', content, flags=re.DOTALL)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
