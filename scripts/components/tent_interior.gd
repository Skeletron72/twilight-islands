extends Node2D
class_name TentInterior

# Скрипт интерьера палатки:
# 1. z_index зафиксирован, чтобы персонаж никогда не исчезал.
# 2. Выход наружу осуществляется строго по кнопке взаимодействия (E / клик).

@onready var exit_door: Area2D = $ExitDoor

func _ready() -> void:
	z_index = 0
	z_as_relative = false
	
	if exit_door and not exit_door.is_in_group("interactable"):
		exit_door.add_to_group("interactable")

# Вызывается при нажатии E на выходной порог/коврик
func interact(player: Node2D) -> void:
	TentManager.exit_tent(player)
