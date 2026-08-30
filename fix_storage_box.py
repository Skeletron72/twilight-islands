import re

with open('scripts/components/storage_box.gd', 'r') as f:
    content = f.read()

new_content = """extends StaticBody2D

var inventory: Dictionary = {}

func interact() -> void:
	var storage_ui = get_tree().current_scene.get_node_or_null("UILayer/StorageUI")
	if storage_ui:
		storage_ui.open(self)
	else:
		print("Storage UI not found!")
"""

with open('scripts/components/storage_box.gd', 'w') as f:
    f.write(new_content)
