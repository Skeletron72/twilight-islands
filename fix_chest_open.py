import re

with open('scripts/components/storage_box.gd', 'r') as f:
    content = f.read()

new_content = """extends StaticBody2D

var inventory: Dictionary = {}
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Duplicate texture so opening one chest doesn't open all of them
	if sprite and sprite.texture:
		sprite.texture = sprite.texture.duplicate()

func interact() -> void:
	var storage_ui = get_tree().current_scene.get_node_or_null("UILayer/StorageUI")
	if storage_ui:
		if sprite and sprite.texture is AtlasTexture:
			sprite.texture.region = Rect2(560, 144, 16, 16)
		storage_ui.open(self)
	else:
		print("Storage UI not found!")

func close_chest() -> void:
	if sprite and sprite.texture is AtlasTexture:
		sprite.texture.region = Rect2(560, 160, 16, 16)
"""

with open('scripts/components/storage_box.gd', 'w') as f:
    f.write(new_content)


with open('scripts/components/storage_ui.gd', 'r') as f:
    ui_content = f.read()

old_close = """func close() -> void:
	visible = false
	current_chest = null
	get_tree().paused = false"""

new_close = """func close() -> void:
	visible = false
	if current_chest and current_chest.has_method("close_chest"):
		current_chest.close_chest()
	current_chest = null
	get_tree().paused = false"""

ui_content = ui_content.replace(old_close, new_close)

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(ui_content)
