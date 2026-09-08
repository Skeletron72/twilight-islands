extends Node2D

# Индикатор выносливости — круглый спрайт рядом с игроком
# Текстура: 256x64, кадр 16x16, hframes=16, vframes=4
# Строка 0 (frame 0..15) — от пустой до полной

const FRAME_COUNT = 16
const HIDE_DELAY = 1.5     # Секунд до скрытия при полной выносливости
const OFFSET = Vector2(14, -20)
const RETRO_FPS = 8.0      # Покадровая "резкость" — меньше FPS = более ретро

@onready var sprite: Sprite2D = $Sprite2D

var _hide_timer: float = 0.0
var _is_full: bool = true
var _shake_tween: Tween
var _fade_tween: Tween

# Для retro-обновления кадра
var _target_frame: int = 15
var _displayed_frame: int = 15
var _retro_timer: float = 0.0

func _ready() -> void:
	sprite.modulate.a = 0.0
	GameStateManager.stamina_changed.connect(_on_stamina_changed)

func _process(delta: float) -> void:
	position = OFFSET

	# Покадровое обновление (retro step)
	_retro_timer += delta
	if _retro_timer >= 1.0 / RETRO_FPS:
		_retro_timer = 0.0
		if _displayed_frame != _target_frame:
			# Двигаем на один кадр в сторону цели
			_displayed_frame += sign(_target_frame - _displayed_frame)
			sprite.frame = _displayed_frame  # row 0: frame 0..15

	# Таймер скрытия
	if _is_full:
		_hide_timer -= delta
		if _hide_timer <= 0.0 and sprite.modulate.a > 0.0:
			_fade_to(0.0)

func _on_stamina_changed(current: float, maximum: float) -> void:
	var ratio = current / maximum
	# Целевой кадр в строке 0 (frame index 0..15)
	_target_frame = int(round(ratio * (FRAME_COUNT - 1)))
	_target_frame = clamp(_target_frame, 0, FRAME_COUNT - 1)

	_is_full = (current >= maximum)

	if _is_full:
		_stop_shake()
		_hide_timer = HIDE_DELAY
	else:
		_hide_timer = 0.0
		_fade_to(1.0)
		if GameStateManager.is_exhausted:
			_start_shake()
		else:
			_stop_shake()

func _fade_to(target_alpha: float) -> void:
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(sprite, "modulate:a", target_alpha, 0.3)

func _start_shake() -> void:
	if _shake_tween and _shake_tween.is_valid() and _shake_tween.is_running():
		return
	_shake_tween = create_tween()
	_shake_tween.set_loops()
	_shake_tween.tween_property(sprite, "position", Vector2(1.5, 0), 0.04)
	_shake_tween.tween_property(sprite, "position", Vector2(-1.5, 0), 0.04)
	_shake_tween.tween_property(sprite, "position", Vector2(0, 0), 0.04)

func _stop_shake() -> void:
	if _shake_tween and _shake_tween.is_valid():
		_shake_tween.kill()
	sprite.position = Vector2.ZERO
