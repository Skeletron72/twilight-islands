extends Interactable
class_name Gatherable

@export var resource_id: String = "stick"
@export var drop_amount: int = 1
@export var is_permanent: bool = false # True for HomeBase objects

func _ready() -> void:
	super._ready()
	collision_layer = 2
	$Sprite2D.texture = ItemDB.get_icon(resource_id)
	$Sprite2D.scale = Vector2(0.6, 0.6)


	
	if is_permanent and HomeStateManager.is_destroyed(get_path()):
		queue_free()

func interact(player: Node2D) -> void:
	_gather()

func _gather() -> void:
	# Add directly to inventory
	InventoryManager.add_item(resource_id, drop_amount)
	
	if is_permanent:
		HomeStateManager.mark_destroyed(get_path())
		
	queue_free()
