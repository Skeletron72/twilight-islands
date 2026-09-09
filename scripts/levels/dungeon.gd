extends Node2D
class_name DungeonLevel

# Controller for the procedural dungeon / mine floor scene.

const DungeonGeneratorClass = preload("res://scripts/components/dungeon_generator.gd")

@onready var floor_layer: TileMapLayer = $FloorLayer
@onready var wall_layer: TileMapLayer = $WallLayer
@onready var boundary_walls: StaticBody2D = $BoundaryWalls
@onready var interactables: Node2D = $Interactables
@onready var player: Player = $Player
@onready var floor_label: Label = $DungeonHUD/FloorBadge/MarginContainer/FloorLabel

func _ready() -> void:
	# Update HUD floor display
	if floor_label:
		floor_label.text = "Шахта • Этаж %d" % DungeonManager.current_floor

	# Generate procedural cave floor
	var generator = DungeonGeneratorClass.new()
	generator.generate(
		DungeonManager.current_floor,
		floor_layer,
		wall_layer,
		boundary_walls,
		interactables,
		player
	)

	# Cave atmosphere and music
	if AudioManager:
		AudioManager.set_interior(true)
		AudioManager.play_music("res://assets/audio/music/cave.mp3", 0.5)

func _exit_tree() -> void:
	if AudioManager:
		AudioManager.set_interior(false)
