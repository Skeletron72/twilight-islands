extends Interactable
class_name ExtractionZone

@export_file("*.tscn") var target_scene: String
@export var is_raid_start: bool = false

func _ready() -> void:
	super._ready()
	collision_layer = 2

func interact(player: Node2D) -> void:
	# Fallbacks if properties were not set in the editor
	if target_scene == "":
		if get_tree().current_scene.name == "HomeIsland":
			target_scene = "res://scenes/levels/raid_island.tscn"
			is_raid_start = true
		else:
			target_scene = "res://scenes/levels/home_island.tscn"
			is_raid_start = false

	if is_raid_start:
		InventoryManager.set_mode(InventoryManager.Mode.RAID)
		print("Starting Raid!")
		TransitionManager.transition_to(target_scene, "Отплываем в экспедицию...")
	else:
		InventoryManager.commit_temp_inventory()
		InventoryManager.set_mode(InventoryManager.Mode.SAFE)
		print("Extracted Successfully! Loot saved.")
		TransitionManager.transition_to(target_scene, "Возвращаемся домой...")
