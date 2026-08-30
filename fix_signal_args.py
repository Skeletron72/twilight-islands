import re

with open('scripts/components/storage_ui.gd', 'r') as f:
    content = f.read()

old_func = """func _on_inventory_changed() -> void:
	if visible:
		_refresh_ui()"""

new_func = """func _on_inventory_changed(item_id: String = "", new_amount: int = 0) -> void:
	if visible:
		_refresh_ui()"""

content = content.replace(old_func, new_func)

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(content)
