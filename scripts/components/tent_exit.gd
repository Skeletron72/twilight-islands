extends Area2D
class_name TentExit

# Точка выхода из палатки наружу по кнопке E / клику

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")

func interact(player: Node2D) -> void:
	TentManager.exit_tent(player)
