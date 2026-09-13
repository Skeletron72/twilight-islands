class_name WaterFoamAmbient
extends Node2D

## Анимированная морская / озёрная пена на свободной воде.
## Правило формы: минимум 2х2 тайла (32х32 px) — никаких одиночных 1х1 кусочков ("уродства").
## Все выступы и ответвления имеют ширину не менее 2х2 тайлов, образуя произвольные органические формы.
## Плавно появляется (fade in), переливается 4-кадровой анимацией, слегка дрейфует и плавно растворяется (fade out).

const FOAM_TEXTURE = preload("res://assets/new_assets/Cute_Fantasy/Tiles/Water/Water_Foam_Animation.png")

enum FoamShape {
	BLOCK_2X2,        # 32x32 px — компактная волна 2х2
	WIDE_3X2,         # 48x32 px — вытянутая по горизонтали волна 3х2
	TALL_2X3,         # 32x48 px — вытянутая по вертикали волна 2х3
	FULL_3X3,         # 48x48 px — округлое пятно пены 3х3
	ORGANIC_COMPOUND  # Составная органическая волна (3х2 тело + выступ 2х2, все части >= 2х2)
}

var current_shape: FoamShape = FoamShape.FULL_3X3
var current_frame_idx: int = 0
var anim_timer: float = 0.0
const FRAME_DURATION: float = 0.16 # ~6.25 FPS
const TOTAL_FRAMES: int = 4
const STRIDE_X: int = 80 # 5 тайлов по 16px на кадр

var drift_dir: Vector2 = Vector2.ZERO
var is_fading_out: bool = false
var lifetime_timer: float = 3.0

class SpritePart:
	var sprite: Sprite2D
	var base_offset: Vector2
	var size: Vector2

var _parts: Array[SpritePart] = []

func _ready() -> void:
	z_as_relative = true
	z_index = 1
	
	# Выбор формы: минимум 2х2, произвольные органические очертания
	var roll = randf()
	if roll < 0.25:
		current_shape = FoamShape.BLOCK_2X2
	elif roll < 0.50:
		current_shape = FoamShape.WIDE_3X2
	elif roll < 0.65:
		current_shape = FoamShape.TALL_2X3
	elif roll < 0.85:
		current_shape = FoamShape.FULL_3X3
	else:
		current_shape = FoamShape.ORGANIC_COMPOUND

	_build_sprites()
	
	# Небольшая вариативность масштаба и отражения
	if randf() < 0.5:
		scale.x = -1.0
	if randf() < 0.3:
		scale.y = -1.0
	scale *= randf_range(0.92, 1.08)
	
	# Медленный океанический / водный дрейф
	drift_dir = Vector2(randf_range(-0.6, 1.2), randf_range(0.4, 1.6)).normalized() * randf_range(1.5, 3.2)
	
	lifetime_timer = randf_range(2.6, 4.2)
	current_frame_idx = randi() % TOTAL_FRAMES
	_update_frame_regions()
	
	# Плавное появление (fade in)
	modulate.a = 0.0
	var target_alpha = randf_range(0.70, 0.90)
	var in_duration = randf_range(0.8, 1.4)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", target_alpha, in_duration)

func _build_sprites() -> void:
	match current_shape:
		FoamShape.BLOCK_2X2:
			# 32x32 px (2x2 тайла)
			var sub_offsets = [Vector2(0, 0), Vector2(16, 0), Vector2(0, 16), Vector2(16, 16)]
			var off = sub_offsets[randi() % sub_offsets.size()]
			_create_part(off, Vector2(32, 32), Vector2.ZERO)

		FoamShape.WIDE_3X2:
			# 48x32 px (3x2 тайла)
			var off_y = 0 if randf() < 0.5 else 16
			_create_part(Vector2(0, off_y), Vector2(48, 32), Vector2.ZERO)

		FoamShape.TALL_2X3:
			# 32x48 px (2x3 тайла)
			var off_x = 0 if randf() < 0.5 else 16
			_create_part(Vector2(off_x, 0), Vector2(32, 48), Vector2.ZERO)

		FoamShape.FULL_3X3:
			# 48x48 px (3x3 тайла)
			_create_part(Vector2(0, 0), Vector2(48, 48), Vector2.ZERO)

		FoamShape.ORGANIC_COMPOUND:
			# Тело 3х2 + выступ 2х2 (каждая секция >= 2х2)
			_create_part(Vector2(0, 0), Vector2(48, 32), Vector2(-8, 0))
			var protrude_y = -8 if randf() < 0.5 else 8
			_create_part(Vector2(16, 16), Vector2(32, 32), Vector2(16, protrude_y))

func _create_part(tex_offset: Vector2, size: Vector2, local_pos: Vector2) -> void:
	var spr = Sprite2D.new()
	spr.texture = FOAM_TEXTURE
	spr.region_enabled = true
	spr.centered = true
	spr.position = local_pos
	add_child(spr)
	
	var part = SpritePart.new()
	part.sprite = spr
	part.base_offset = tex_offset
	part.size = size
	_parts.append(part)

func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= FRAME_DURATION:
		anim_timer -= FRAME_DURATION
		current_frame_idx = (current_frame_idx + 1) % TOTAL_FRAMES
		_update_frame_regions()

	global_position += drift_dir * delta

	if not is_fading_out:
		lifetime_timer -= delta
		if lifetime_timer <= 0.0:
			fade_out_and_free(randf_range(1.0, 1.6))

func _update_frame_regions() -> void:
	for part in _parts:
		if is_instance_valid(part.sprite):
			var rx = current_frame_idx * STRIDE_X + int(part.base_offset.x)
			var ry = int(part.base_offset.y)
			part.sprite.region_rect = Rect2(rx, ry, part.size.x, part.size.y)

func fade_out_and_free(duration: float = 1.2) -> void:
	if is_fading_out:
		return
	is_fading_out = true
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "modulate:a", 0.0, duration)
	tween.tween_callback(queue_free)
