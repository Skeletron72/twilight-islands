extends StaticBody2D

var inventory: Dictionary = {}
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# Duplicate texture so opening one chest doesn't open all of them
	if sprite and sprite.texture:
		sprite.texture = sprite.texture.duplicate()

func interact(player: Node2D) -> void:
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
