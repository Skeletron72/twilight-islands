extends Node

func _process(delta):
    var player = get_node_or_null("/root/HomeIsland/Player")
    if player:
        # Z-index is absolute. This bypasses all Godot Y-sorting bugs.
        player.z_index = int(player.global_position.y / 2.0)
        
    var interactables = get_node_or_null("/root/HomeIsland/Interactables")
    if interactables:
        for child in interactables.get_children():
            if child is Node2D:
                child.z_index = int(child.global_position.y / 2.0)
