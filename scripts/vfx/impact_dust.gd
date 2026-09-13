extends Node2D

@onready var sprite: Sprite2D = $Sprite2D

var fps: float = 18.0
var total_frames: int = 4
var current_frame: int = 0
var timer: float = 0.0

func _ready() -> void:
	if sprite:
		sprite.frame = 0
		total_frames = sprite.hframes

func _process(delta: float) -> void:
	timer += delta
	if timer >= 1.0 / fps:
		timer -= (1.0 / fps)
		current_frame += 1
		if current_frame >= total_frames:
			queue_free()
			return
		if sprite:
			sprite.frame = current_frame
