extends Sprite2D
class_name WetEffect

## WetEffect - эффект стекающих капель воды при намокании игрока
## Использует status_wet_sheet.png (последние 6 кадров: 8, 9, 10, 11, 12, 13)

const WET_TEXTURE = preload("res://assets/sprites/vfx/water/status_wet_sheet.png")
const LAST_6_FRAMES = [8, 9, 10, 11, 12, 13]

var anim_timer: float = 0.0
const FPS: float = 8.5

func _ready() -> void:
	texture = WET_TEXTURE
	hframes = 14
	vframes = 1
	frame = LAST_6_FRAMES[0]
	scale = Vector2(0.95, 0.95)
	position = Vector2(0, -10)
	z_index = 25
	z_as_relative = true
	modulate = Color(0.85, 0.95, 1.1, 0.0)

func _process(delta: float) -> void:
	var parent = get_parent()
	if not parent:
		return
		
	var is_wet = parent.get("is_wet") as bool
	var target_a = 0.85 if is_wet else 0.0
	modulate.a = move_toward(modulate.a, target_a, delta * 2.5)
	
	if modulate.a > 0.0:
		visible = true
		anim_timer += delta
		var f_idx = int(anim_timer * FPS) % LAST_6_FRAMES.size()
		frame = LAST_6_FRAMES[f_idx]
		
		# В сумеречный шторм капли с фиолетовым отливом
		if WeatherManager and WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM:
			modulate = Color(0.95, 0.75, 1.2, modulate.a)
		else:
			modulate = Color(0.85, 0.95, 1.1, modulate.a)
	else:
		visible = false

static func attach_to(target: Node2D) -> WetEffect:
	var existing = target.get_node_or_null("WetEffect") as WetEffect
	if existing:
		return existing
	var wet = WetEffect.new()
	wet.name = "WetEffect"
	target.add_child(wet)
	return wet
