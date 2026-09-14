extends Node

var last_workshop_exit_pos: Vector2 = Vector2.ZERO
var _interior_instance: Node2D = null

const INTERIOR_POS: Vector2 = Vector2(6000, 4000)
const INTERIOR_SPAWN_OFFSET: Vector2 = Vector2(0, 34)

func enter_workshop(workshop_node: Node2D, player: Node2D) -> void:
	if not workshop_node or not player:
		return
	
	last_workshop_exit_pos = workshop_node.global_position + Vector2(0, 16)
	_ensure_interior()
	
	TransitionManager.play_iris_transition(func():
		_teleport_player(player, INTERIOR_POS + INTERIOR_SPAWN_OFFSET, 2)
		var audio_mgr = player.get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("set_interior"):
			audio_mgr.set_interior(true)
	)

func exit_workshop(player: Node2D) -> void:
	if not player:
		return
	
	TransitionManager.play_iris_transition(func():
		var target_pos = last_workshop_exit_pos if last_workshop_exit_pos != Vector2.ZERO else Vector2(100, 150)
		_teleport_player(player, target_pos, 0)
		var audio_mgr = player.get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("set_interior"):
			audio_mgr.set_interior(false)
	)

func _teleport_player(player: Node2D, target_pos: Vector2, direction: int) -> void:
	player.global_position = target_pos
	if "current_dir" in player:
		player.current_dir = direction
	if player.has_method("_play_anim"):
		player._play_anim("idle")
		
	var cam = player.get_node_or_null("Camera2D") as Camera2D
	if cam:
		cam.reset_smoothing()

func _ensure_interior() -> void:
	if _interior_instance and is_instance_valid(_interior_instance):
		return
		
	var scene = load("res://scenes/levels/workshop_interior.tscn") as PackedScene
	if scene:
		_interior_instance = scene.instantiate()
		_interior_instance.global_position = INTERIOR_POS
		get_tree().current_scene.add_child(_interior_instance)
