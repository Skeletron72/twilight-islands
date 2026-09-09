extends Node

var destroyed_nodes: Array[NodePath] = []
var stump_nodes: Array[NodePath] = []

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
