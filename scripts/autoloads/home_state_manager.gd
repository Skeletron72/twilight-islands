extends Node

var destroyed_nodes: Array[NodePath] = []
var stump_nodes: Array[NodePath] = []

# NPC & Story Progress
var shipwright_rescued: bool = false
var shipwright_following: bool = false
var shipwright_wood_given: bool = false
var shipwright_spoken_once: bool = false
var shipwright_arrival_day: int = -1
var workshop_quest_started: bool = false
var spawn_on_shore: bool = false

# Shipwright Workshop & Fleet Progression
var workshop_built: bool = false
var workshop_under_construction: bool = false
var workshop_start_day: int = 1
var workshop_days_required: int = 2
var workshop_pos: Vector2 = Vector2.ZERO
var workshop_orientation: int = 0 # 0=South, 1=East, 2=North, 3=West
var workshop_level: int = 1

func is_workshop_ready() -> bool:
	return workshop_built and not workshop_under_construction

func check_workshop_progress() -> bool:
	if workshop_built and workshop_under_construction:
		if GameStateManager and GameStateManager.current_day >= workshop_start_day + workshop_days_required:
			workshop_under_construction = false
			return true # Just finished!
	return false

func get_days_remaining() -> int:
	if not workshop_under_construction:
		return 0
	if GameStateManager:
		var rem = (workshop_start_day + workshop_days_required) - GameStateManager.current_day
		return clampi(rem, 1, workshop_days_required)
	return workshop_days_required

func get_workshop_boat_pos() -> Vector2:
	if not is_workshop_ready() or workshop_pos == Vector2.ZERO:
		return Vector2(40, 160) # Default beach spawn
	match workshop_orientation:
		0: return workshop_pos + Vector2(30, 42)
		1: return workshop_pos + Vector2(50, 24)
		2: return workshop_pos + Vector2(30, -56)
		3: return workshop_pos + Vector2(-50, 24)
		_: return workshop_pos + Vector2(30, 42)

func get_workshop_npc_pos() -> Vector2:
	if not workshop_built or workshop_pos == Vector2.ZERO:
		return Vector2(90, 150)
	match workshop_orientation:
		0: return workshop_pos + Vector2(16, 10)
		1: return workshop_pos + Vector2(12, 16)
		2: return workshop_pos + Vector2(16, -12)
		3: return workshop_pos + Vector2(-12, 16)
		_: return workshop_pos + Vector2(16, 10)

func mark_stump(path: NodePath) -> void:
	if path not in stump_nodes:
		stump_nodes.append(path)

func is_stump(path: NodePath) -> bool:
	return path in stump_nodes

func mark_destroyed(path: NodePath) -> void:
	if path in stump_nodes:
		stump_nodes.erase(path)
	if path not in destroyed_nodes:
		destroyed_nodes.append(path)

func is_destroyed(path: NodePath) -> bool:
	return path in destroyed_nodes

func reset_state() -> void:
	destroyed_nodes.clear()
	stump_nodes.clear()
