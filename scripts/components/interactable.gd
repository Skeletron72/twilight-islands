extends Area2D
class_name Interactable

signal interacted(player: Node2D)

@export var prompt_text: String = "Interact"

func _ready() -> void:
	# Ensure it monitors for bodies (the player)
	monitoring = true
	collision_layer = 0
	collision_mask = 1 # Assuming player is on layer 1

func interact(player: Node2D) -> void:
	interacted.emit(player)
