extends Sprite2D
class_name SleepEffect

## SleepEffect - визуальный эффект сна ("Zzz") над головой персонажа.
## Использует statusfx_sleeping_sheet.png (19 кадров 50x50)

const SLEEP_TEXTURE = preload("res://assets/sprites/vfx/status/statusfx_sleeping_sheet.png")

var anim_timer: float = 0.0
var fps: float = 8.0
var base_pos_y: float = -26.0
var float_time: float = 0.0

func _init() -> void:
	texture = SLEEP_TEXTURE
	hframes = 19
	vframes = 1
	frame = 0
	position = Vector2(0, base_pos_y)
	z_index = 30
	z_as_relative = true
	modulate = Color(1.0, 1.0, 1.15, 0.9)
	scale = Vector2(0.8, 0.8)

func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= 1.0 / fps
		frame = (frame + 1) % hframes
		
	# Легкое покачивание в воздухе
	float_time += delta * 2.0
	position.y = base_pos_y + sin(float_time) * 2.0
