import re

with open('scripts/components/storage_ui.gd', 'r') as f:
    content = f.read()

old_ready = """func _ready() -> void:
	visible = false
	GameStateManager.inventory_changed.connect(_on_inventory_changed)"""

new_ready = """func _ready() -> void:
	visible = false
	InventoryManager.inventory_changed.connect(_on_inventory_changed)"""

content = content.replace(old_ready, new_ready)

# Also wait, _on_inventory_changed in storage_ui.gd doesn't take arguments, but the signal passes (item_id: String, new_amount: int)!
# Let's check _on_inventory_changed signature!
