extends Node2D
class_name DamageNumber

## Анимированные всплывающие цифры урона для боевой системы.
## Поддерживают обычные удары и яркие критические удары.

@onready var label: Label = $Label

var velocity: Vector2 = Vector2.ZERO
var gravity: float = 48.0
var lifetime: float = 0.75
var elapsed: float = 0.0

static func spawn(parent: Node, world_pos: Vector2, amount: int, is_crit: bool = false) -> DamageNumber:
	if not parent:
		return null
	var scene = load("res://scenes/vfx/damage_number.tscn")
	if not scene:
		return null
	var inst: DamageNumber = scene.instantiate()
	inst.global_position = world_pos + Vector2(randf_range(-4.0, 4.0), randf_range(-2.0, 2.0))
	parent.add_child(inst)
	inst.setup(amount, is_crit)
	return inst

func setup(amount: int, is_crit: bool) -> void:
	if not label:
		label = get_node_or_null("Label")
	if not label:
		return
		
	var font_res = preload("res://assets/fonts/WarmPixel.ttf")
	label.add_theme_font_override("font", font_res)
	
	if is_crit:
		label.text = "%d" % amount
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color(1.0, 0.72, 0.15, 1.0)) # Яркое золото / оранжевый
		label.add_theme_color_override("font_outline_color", Color(0.45, 0.08, 0.0, 1.0)) # Бордово-красная обводка
		label.add_theme_constant_override("outline_size", 4)
		
		velocity = Vector2(randf_range(-20.0, 20.0), -68.0)
		lifetime = 0.85
		
		# Сочный крит-поп: резкий старт -> сильное увеличение -> отскок в норму
		scale = Vector2(0.4, 0.4)
		var tw = create_tween()
		tw.tween_property(self, "scale", Vector2(1.55, 1.55), 0.09).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2(1.2, 1.2), 0.12).set_trans(Tween.TRANS_SINE)
	else:
		label.text = "%d" % amount
		label.add_theme_font_size_override("font_size", 9)
		label.add_theme_color_override("font_color", Color(1.0, 0.96, 0.84, 1.0)) # Мягкий кремово-белый
		label.add_theme_color_override("font_outline_color", Color(0.12, 0.08, 0.05, 1.0)) # Темная обводка
		label.add_theme_constant_override("outline_size", 3)
		
		velocity = Vector2(randf_range(-14.0, 14.0), -46.0)
		lifetime = 0.65
		
		# Мягкий аккуратный поп для обычного урона
		scale = Vector2(0.6, 0.6)
		var tw = create_tween()
		tw.tween_property(self, "scale", Vector2(1.15, 1.15), 0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.09)

func _process(delta: float) -> void:
	elapsed += delta
	position += velocity * delta
	velocity.y += gravity * delta
	velocity.x = move_toward(velocity.x, 0.0, 18.0 * delta)
	
	# Плавное затухание к концу жизни
	var fade_start = lifetime * 0.52
	if elapsed >= fade_start:
		var progress = (elapsed - fade_start) / (lifetime - fade_start)
		modulate.a = clampf(1.0 - progress, 0.0, 1.0)
		
	if elapsed >= lifetime:
		queue_free()
