import re

# Update InventoryManager to 8 slots
with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    inv = f.read()

inv = inv.replace('var ui_slots: Array = ["", "", "", "", "", "", "", "", "", ""]',
                  'var ui_slots: Array = ["", "", "", "", "", "", "", ""]')
inv = inv.replace('for i in range(10):', 'for i in range(8):')

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write(inv)

# Update book_ui.gd to 8 slots
with open('scripts/components/book_ui.gd', 'r') as f:
    book = f.read()

book = book.replace('for i in range(10):', 'for i in range(8):')
book = book.replace('inventory_grid.columns = 5', 'inventory_grid.columns = 4')
book = book.replace('char_inv_grid.columns = 5', 'char_inv_grid.columns = 4')

# Also hide hotbar when book opens, show when it closes!
# Book opens via show(), but wait, Godot nodes use show()/hide().
# Let's override visibility_changed signal on book_ui!
visibility_logic = """
func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
"""
book = book.replace('func _ready() -> void:', visibility_logic)

visibility_func = """
func _on_visibility_changed() -> void:
	var hotbar = get_parent().get_node_or_null("HotbarUI")
	if hotbar:
		hotbar.visible = not self.visible
"""
book = book + '\n' + visibility_func

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(book)

