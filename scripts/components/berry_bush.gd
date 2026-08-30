extends StaticBody2D

@export var resource_id: String = "red_bush" # or "yellow_bush"
@export var is_permanent: bool = false # used by spawner

var has_berries: bool = true

@onready var sprite = $Sprite2D

func _ready() -> void:
	sprite.texture = sprite.texture.duplicate()
	_update_visuals()
	
func interact(player: Node2D) -> void:
	if has_berries:
		has_berries = false
		var amount = randi() % 5 + 1 # 1 to 5
		if resource_id == "red_bush":
			InventoryManager.add_item("red_berry", amount)
		else:
			InventoryManager.add_item("yellow_berry", amount)
		_update_visuals()
		
		# Simple regrowth timer just to be nice, maybe 300 seconds?
		# For now, it stays empty until next game load (Stardew style, regrows next day)
		# But since we don't have full day logic implemented yet, a timer is good.
		var t = get_tree().create_timer(300.0)
		t.timeout.connect(func():
			has_berries = true
			_update_visuals()
		)

func _update_visuals() -> void:
	if has_berries:
		if resource_id == "red_bush":
			sprite.texture.region = Rect2(784, 48, 32, 32)
		else:
			sprite.texture.region = Rect2(784, 80, 32, 32)
	else:
		sprite.texture.region = Rect2(784, 16, 32, 32)
