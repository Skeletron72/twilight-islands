extends Interactable
class_name ResourceNode

@export var resource_id: String = "twilight_ore"
@export var amount: int = 1
@export var single_use: bool = true

func _ready() -> void:
	super._ready()
	collision_layer = 2 # Matches Player's interaction mask

func interact(player: Node2D) -> void:
	InventoryManager.add_item(resource_id, amount)
	print("Mined %d x %s" % [amount, resource_id])
	super.interact(player)
	
	if single_use:
		queue_free()
