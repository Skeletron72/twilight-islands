extends Area2D

@export var fade_alpha: float = 0.25
@export var fade_time: float = 0.2

var original_alpha: float = 1.0
var target_node: CanvasItem

func _ready() -> void:
	# Assume the parent is the node we want to fade
	target_node = get_parent() as CanvasItem
	if target_node:
		original_alpha = target_node.modulate.a
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body is Player and target_node:
		_fade_to(fade_alpha)

func _on_body_exited(body: Node2D) -> void:
	if body is Player and target_node:
		_fade_to(original_alpha)

func _fade_to(alpha: float) -> void:
	var tween = create_tween()
	tween.tween_property(target_node, "modulate:a", alpha, fade_time)
