extends Node2D
class_name AnimatedVFX

@onready var sprite: Sprite2D = $Sprite2D

var fps: float = 20.0
var total_frames: int = 4
var current_frame: int = 0
var timer: float = 0.0

func setup(p_texture: Texture2D, p_hframes: int, p_fps: float = 20.0, p_scale: Vector2 = Vector2.ONE, p_rotation: float = 0.0, p_modulate: Color = Color.WHITE, p_z_index: int = 50, p_offset: Vector2 = Vector2.ZERO) -> void:
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
		if not sprite:
			sprite = Sprite2D.new()
			sprite.name = "Sprite2D"
			add_child(sprite)
			
	sprite.texture = p_texture
	sprite.hframes = p_hframes
	sprite.vframes = 1
	sprite.frame = 0
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = p_scale
	sprite.rotation = p_rotation
	sprite.modulate = p_modulate
	sprite.offset = p_offset
	z_index = p_z_index
	fps = p_fps
	total_frames = p_hframes
	current_frame = 0
	timer = 0.0

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
