extends Node

var destroyed_nodes: Array[NodePath] = []

func mark_destroyed(path: NodePath) -> void:
	if path not in destroyed_nodes:
		destroyed_nodes.append(path)

func is_destroyed(path: NodePath) -> bool:
	return path in destroyed_nodes
