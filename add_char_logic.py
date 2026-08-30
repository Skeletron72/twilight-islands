import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

new_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	if index == 0:
		_refresh_inventory()
	elif index == 1:
		_refresh_character_tab()"""

content = content.replace("""func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	if index == 0:
		_refresh_inventory()""", new_switch)


char_tab_logic = """
# --- TAB 2: CHARACTER LOGIC ---
@onready var char_equip_grid = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/LeftPage/EquipGrid
@onready var char_inv_grid = $DimBackground/CenterContainer/HBoxContainer/BookPanel/Pages/CharacterTab/HBoxContainer/RightPage/ScrollContainer/GridContainer

func _refresh_character_tab() -> void:
	# Clear both
	for child in char_equip_grid.get_children():
		child.queue_free()
	for child in char_inv_grid.get_children():
		child.queue_free()
		
	# Draw Equip Slots
	var slots = ["head", "chest", "boots", "tool"]
	for slot_name in slots:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.expand_icon = true
		btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var eq_id = InventoryManager.equipment.get(slot_name, "")
		if eq_id != "":
			btn.icon = ItemDB.get_icon(eq_id)
			btn.pressed.connect(func():
				InventoryManager.unequip(slot_name)
				_refresh_character_tab()
			)
		else:
			btn.text = slot_name # Empty slot text
		char_equip_grid.add_child(btn)
		
	# Draw Equippable Items in Inventory
	var combined = {}
	for id in InventoryManager.inventory: combined[id] = InventoryManager.inventory[id]
	for id in InventoryManager.temp_inventory:
		if combined.has(id): combined[id] += InventoryManager.temp_inventory[id]
		else: combined[id] = InventoryManager.temp_inventory[id]
		
	for id in combined:
		if combined[id] <= 0: continue
		var item = ItemDB.get_item(id)
		if not item.has("equip_slot"): continue # Only show equippables here
		
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(48, 48)
		btn.icon = ItemDB.get_icon(id)
		btn.expand_icon = true
		btn.pressed.connect(func():
			InventoryManager.equip(id)
			_refresh_character_tab()
		)
		char_inv_grid.add_child(btn)
"""

content += char_tab_logic

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
