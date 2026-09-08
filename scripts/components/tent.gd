extends StaticBody2D
class_name Tent

# Внешний объект палатки на острове.
# Вход внутрь осуществляется строго по кнопке взаимодействия (E / клик).

@onready var sprite: Sprite2D = $Sprite2D
@onready var door_area: Area2D = $DoorArea

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")

func interact(player: Node2D) -> void:
	TentManager.enter_tent(self, player)
