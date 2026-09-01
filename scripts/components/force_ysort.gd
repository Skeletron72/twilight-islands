extends Node

func _ready():
    _force_ysort(get_node("/root/HomeIsland"))

func _force_ysort(node):
    if node is CanvasItem:
        if node.name not in ["WaterLayer", "CanopyLayer"]:
            node.y_sort_enabled = true
    for child in node.get_children():
        _force_ysort(child)
