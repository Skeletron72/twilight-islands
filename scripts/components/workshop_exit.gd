extends Area2D
class_name WorkshopExit

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")

func interact(player: Node2D) -> void:
	var wm = get_node_or_null("/root/WorkshopManager")
	if wm and wm.has_method("exit_workshop"):
		wm.exit_workshop(player)
