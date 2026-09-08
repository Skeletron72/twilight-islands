extends Area2D
class_name DroppedItem

var item_id: String = ""
var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

var float_timer: float = randf_range(0, TAU)
var is_pickup_ready: bool = false
var is_sucking: bool = false
var target_player: Node2D = null

var is_in_air: bool = true
var _shadow_scale: float = 1.0
var _hover_y: float = 0.0
var _suction_speed: float = 0.0 # Нарастает плавно

func setup(id: String, count: int) -> void:
	item_id = id
	amount = count

func _ready() -> void:
	if item_id != "":
		sprite.texture = ItemDB.get_icon(item_id)

	scale = Vector2(0.2, 0.2)
	modulate.a = 0.0

	# Разлет по земле вокруг источника (с легким смещением вперед к камере)
	var scatter_x = randf_range(-26.0, 26.0)
	var scatter_y = randf_range(6.0, 24.0)
	var arc_height = randf_range(18.0, 28.0)
	var target_pos = position + Vector2(scatter_x, scatter_y)

	var tween = create_tween()
	tween.set_parallel(true)

	# Горизонтальное и вертикальное перемещение базы на земле
	tween.tween_property(self, "position", target_pos, 0.45)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Вертикальная арка полета (поднимаем ТОЛЬКО спрайт предмета, не смещая координату земли!)
	tween.tween_property(sprite, "position:y", -arc_height, 0.2)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(sprite, "position:y", 0.0, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Появление
	tween.tween_property(self, "modulate:a", 1.0, 0.12)

	# Легкий наклон при полете
	sprite.rotation = randf_range(-0.25, 0.25)
	var rot_tween = create_tween()
	rot_tween.tween_interval(0.05)
	rot_tween.tween_property(sprite, "rotation", 0.0, 0.3)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Приземление — вырастаем до 0.75, потом оседаем до 0.6
	var land = create_tween()
	land.tween_interval(0.43)
	land.tween_property(self, "scale", Vector2(0.75, 0.75), 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	land.tween_property(self, "scale", Vector2(0.6, 0.6), 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	await get_tree().create_timer(0.45).timeout
	is_in_air = false # Приземлился — теперь честно сортируется по Y земли
	await get_tree().create_timer(0.25).timeout
	is_pickup_ready = true

func _process(delta: float) -> void:
	if not is_sucking:
		float_timer += delta * 3.0
		_hover_y = sin(float_timer) * 3.0
		sprite.position.y = _hover_y
		_shadow_scale = 1.0 + (_hover_y / 20.0)
		queue_redraw()

		if is_pickup_ready:
			for body in get_overlapping_bodies():
				if body is Player:
					_start_pickup(body)
					break
	else:
		if target_player and is_instance_valid(target_player):
			var dist = global_position.distance_to(target_player.global_position)

			# Как в Stardew: скорость нарастает плавно, а не мгновенно
			_suction_speed = move_toward(_suction_speed, 600.0, delta * 800.0)

			var dir = (target_player.global_position - global_position).normalized()
			global_position += dir * _suction_speed * delta

			# Немного уменьшаемся пока летим
			scale = scale.move_toward(Vector2(0.3, 0.3), delta * 1.5)

			if dist < 6.0:
				_on_collected()

func _start_pickup(player: Node2D) -> void:
	is_sucking = true
	target_player = player
	_suction_speed = 40.0 # Стартуем медленно — нарастает в _process

	# Маленький поп перед притяжением
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0.72, 0.72), 0.06)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _on_collected() -> void:
	if AudioManager:
		AudioManager.play_sfx(preload("res://assets/audio/sfx/player/sfx_item_pickup.mp3"), randf_range(1.0, 1.15), 0.0)
		
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2(0.0, 0.0), 0.08)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, 0.08)
	tween.chain().tween_callback(func():
		InventoryManager.add_item(item_id, amount)
		GameStateManager.register_item_gathered(amount)
		queue_free()
	)

func _draw() -> void:
	draw_set_transform(Vector2(0, 6), 0, Vector2(_shadow_scale, 0.25))
	draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.3))
