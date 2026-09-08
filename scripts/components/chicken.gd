extends CharacterBody2D

@export var speed: float = 15.0

enum State {
	IDLE,
	WALKING,
	PECKING,
	SITTING,
	SLEEPING,
	WAKING_UP,
	STANDING,
	MOVING_TO_BUSH,
	PECKING_BUSH
}

# Строки спрайтшита (0-индексация, 8 кадров в строке)
const ROW_IDLE        = 0
const ROW_WALK        = 1
const ROW_PECK        = 2
const ROW_SIT_DOWN    = 3
const ROW_STAND_UP    = 4
const ROW_FALL_ASLEEP = 5
const ROW_SLEEP       = 6
# Строки 8-15 — те же анимации, но спиной (ROW_X + 8)

const FRAMES = {
	ROW_IDLE:        2,
	ROW_WALK:        6,
	ROW_PECK:        8,
	ROW_SIT_DOWN:    3,
	ROW_STAND_UP:    3,
	ROW_FALL_ASLEEP: 3,
	ROW_SLEEP:       8,
}

const FPS = {
	ROW_IDLE:        4.0,
	ROW_WALK:        8.0,
	ROW_PECK:        8.0,
	ROW_SIT_DOWN:    6.0,
	ROW_STAND_UP:    6.0,
	ROW_FALL_ASLEEP: 4.0,
	ROW_SLEEP:       5.0,
}

var current_state: State = State.IDLE
var direction: Vector2 = Vector2.ZERO
var last_safe_position: Vector2 = Vector2.ZERO
var state_timer: float = 0.0

# Физика веса и толкания
var push_velocity: Vector2 = Vector2.ZERO
var push_friction: float = 380.0
var push_contact_time: float = 0.0
var is_panicking: bool = false
var panic_timer: float = 0.0
var _squash_tween: Tween = null

# Анимация
var current_frame: int = 0
var anim_timer: float = 0.0
var facing_back: bool = false   # смотрит спиной (движение вверх)
var facing_right: bool = false  # смотрит вправо (flip_h)
var one_shot_done: bool = false # флаг завершения разовой анимации

var target_bush: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	add_to_group("chickens")
	_pick_new_state()
	last_safe_position = global_position

func _physics_process(delta: float) -> void:
	# Затухание импульса толкания (сильное трение о землю)
	if push_velocity.length() > 0.0:
		push_velocity = push_velocity.move_toward(Vector2.ZERO, push_friction * delta)
	
	# Постепенный сброс таймера контакта, если игрока рядом нет
	push_contact_time = max(0.0, push_contact_time - delta * 0.6)

	# Режим паники / испуга (быстрый отбег от игрока)
	if is_panicking:
		panic_timer -= delta
		velocity = direction * (speed * 2.2) + push_velocity + _get_flock_separation()
		_update_facing()
		_handle_water_avoidance()
		_handle_wall_avoidance()
		move_and_slide()
		_play_anim(delta, ROW_WALK, true)
		if panic_timer <= 0:
			is_panicking = false
			_pick_new_state()
		_ensure_water_safety()
		return

	state_timer -= delta

	match current_state:
		State.IDLE:
			velocity = push_velocity
			move_and_slide()
			_play_anim(delta, ROW_IDLE, true)
			if state_timer <= 0:
				_pick_new_state()

		State.WALKING:
			if state_timer <= 0:
				_pick_new_state()
			velocity = (direction * speed) + push_velocity + _get_flock_separation()
			_update_facing()
			_handle_water_avoidance()
			_handle_wall_avoidance()
			move_and_slide()
			_play_anim(delta, ROW_WALK, true)

		State.PECKING:
			velocity = push_velocity
			move_and_slide()
			_play_anim(delta, ROW_PECK, true)
			if state_timer <= 0:
				_pick_new_state()

		State.SITTING:
			velocity = push_velocity
			move_and_slide()
			if _play_oneshot(delta, ROW_SIT_DOWN):
				_enter_state(State.SLEEPING)

		State.SLEEPING:
			velocity = push_velocity
			move_and_slide()
			if not one_shot_done:
				if _play_oneshot(delta, ROW_FALL_ASLEEP):
					one_shot_done = true
					current_frame = 0
			else:
				_play_anim(delta, ROW_SLEEP, true)
			if state_timer <= 0:
				_enter_state(State.WAKING_UP)

		State.WAKING_UP:
			velocity = push_velocity
			move_and_slide()
			if _play_oneshot_reverse(delta, ROW_FALL_ASLEEP):
				_enter_state(State.STANDING)

		State.STANDING:
			velocity = push_velocity
			move_and_slide()
			if _play_oneshot(delta, ROW_STAND_UP):
				_enter_state(State.IDLE)

		State.MOVING_TO_BUSH:
			if state_timer <= 0 or not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:
				var dist = global_position.distance_to(target_bush.global_position)
				if dist < 24.0:
					current_state = State.PECKING_BUSH
					state_timer = 2.0
					velocity = push_velocity
					move_and_slide()
				else:
					direction = (target_bush.global_position - global_position).normalized()
					velocity = (direction * speed) + push_velocity + _get_flock_separation()
					_update_facing()
					_handle_water_avoidance()
					_handle_wall_avoidance()
					move_and_slide()
					_play_anim(delta, ROW_WALK, true)

		State.PECKING_BUSH:
			velocity = push_velocity
			move_and_slide()
			if not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:
				_play_anim(delta, ROW_PECK, true)
				if state_timer <= 0:
					target_bush.has_berries = false
					target_bush._update_visuals()
					var t = get_tree().create_timer(300.0)
					var b = target_bush
					t.timeout.connect(func():
						if is_instance_valid(b):
							b.has_berries = true
							b._update_visuals()
					)
					_pick_new_state()

	_ensure_water_safety()
	if current_state in [State.IDLE, State.PECKING, State.PECKING_BUSH, State.SLEEPING]:
		last_safe_position = global_position

# ──────────────────────────────────────────────────────────────────────────────
#  Анимация
# ──────────────────────────────────────────────────────────────────────────────

func _get_row(base_row: int) -> int:
	return base_row + (8 if facing_back else 0)

func _set_sprite_frame(row: int, frame: int) -> void:
	sprite.flip_h = facing_right
	sprite.frame = row * sprite.hframes + frame

# Зацикленная анимация. Возвращает true при переходе на новый кадр (не используем).
func _play_anim(delta: float, base_row: int, _loop: bool = true) -> void:
	var row = _get_row(base_row)
	var frame_count = FRAMES[base_row]
	var fps = FPS[base_row]

	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= 1.0 / fps
		current_frame = (current_frame + 1) % frame_count
	_set_sprite_frame(row, current_frame)

# Одноразовая анимация. Возвращает true когда доиграла до конца.
func _play_oneshot(delta: float, base_row: int) -> bool:
	var row = _get_row(base_row)
	var frame_count = FRAMES[base_row]
	var fps = FPS[base_row]

	_set_sprite_frame(row, current_frame)
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= 1.0 / fps
		if current_frame < frame_count - 1:
			current_frame += 1
		else:
			return true
	return false

# Одноразовая анимация в обратном порядке.
func _play_oneshot_reverse(delta: float, base_row: int) -> bool:
	var row = _get_row(base_row)
	var frame_count = FRAMES[base_row]
	var fps = FPS[base_row]

	_set_sprite_frame(row, current_frame)
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= 1.0 / fps
		if current_frame > 0:
			current_frame -= 1
		else:
			return true
	return false

# ──────────────────────────────────────────────────────────────────────────────
#  Состояния
# ──────────────────────────────────────────────────────────────────────────────

func _enter_state(new_state: State) -> void:
	current_state = new_state
	current_frame = 0
	anim_timer = 0.0
	one_shot_done = false

	match new_state:
		State.SLEEPING:
			state_timer = randf_range(5.0, 15.0)
		State.WAKING_UP:
			# reverse начинаем с последнего кадра
			current_frame = FRAMES[ROW_FALL_ASLEEP] - 1

func _pick_new_state() -> void:
	target_bush = null

	# 20% ищем куст
	if randf() < 0.2:
		var bushes = get_tree().get_nodes_in_group("interactable")
		var valid_bushes = []
		for b in bushes:
			if "has_berries" in b and b.has_berries and global_position.distance_to(b.global_position) < 150.0:
				valid_bushes.append(b)
		if valid_bushes.size() > 0:
			target_bush = valid_bushes[randi() % valid_bushes.size()]
			_enter_state(State.MOVING_TO_BUSH)
			state_timer = randf_range(3.5, 5.0)
			return

	var r = randf()
	if r < 0.08:
		# Редко ложимся спать
		_enter_state(State.SITTING)
	elif r < 0.3:
		_enter_state(State.PECKING)
		state_timer = randf_range(2.0, 4.0)
	elif r < 0.5:
		_enter_state(State.IDLE)
		state_timer = randf_range(1.0, 3.0)
	else:
		_enter_state(State.WALKING)
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		state_timer = randf_range(2.0, 5.0)

# ──────────────────────────────────────────────────────────────────────────────
#  Утилиты и механика веса / толкания
# ──────────────────────────────────────────────────────────────────────────────

# Вызывается игроком при навале / контакте
func receive_push(push_dir: Vector2, pusher_speed: float, delta: float) -> void:
	if _is_flying or is_panicking: return

	# Скорость толкания ограничена (курица сопротивляется сдвигу)
	var max_push_speed = 30.0
	var push_accel = 140.0
	push_velocity = (push_velocity + push_dir * push_accel * delta).limit_length(max_push_speed)

	push_contact_time += delta

	# Легкий сквош при контакте
	if push_contact_time < delta * 2.0:
		_trigger_squash()

	# Если толкают непрерывно дольше 0.35 секунды — птица пугается и убегает
	if push_contact_time > 0.35:
		_flee_from(push_dir)

func _trigger_squash() -> void:
	if not sprite: return
	if _squash_tween and _squash_tween.is_valid():
		_squash_tween.kill()
	_squash_tween = create_tween()
	_squash_tween.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.08)
	_squash_tween.tween_property(sprite, "scale", Vector2(0.95, 1.05), 0.08)
	_squash_tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.08)

func _flee_from(pusher_dir: Vector2) -> void:
	push_contact_time = 0.0
	is_panicking = true
	panic_timer = randf_range(1.0, 1.6)

	# Отбегает вбок/по диагонали от направления толчка
	var side_angle = (PI * 0.35) if randf() > 0.5 else (-PI * 0.35)
	direction = pusher_dir.rotated(side_angle).normalized()

	one_shot_done = true
	current_state = State.WALKING
	_trigger_squash()

# Избегание стен: мгновенно реагирует при столкновении со стеной
func _handle_wall_avoidance() -> void:
	if is_on_wall():
		var n = get_wall_normal()
		if n != Vector2.ZERO:
			# Отворачиваем от стены в сторону открытого пространства
			direction = (n + Vector2(randf_range(-0.4, 0.4), randf_range(-0.4, 0.4))).normalized()
		else:
			direction = -direction
		_update_facing()

		if current_state == State.MOVING_TO_BUSH:
			# Препятствие на пути к кусту — сразу сбрасываем цель, не упираясь в стену
			target_bush = null
			_pick_new_state()
		elif current_state == State.WALKING and not is_panicking:
			# Если просто гуляли — начинаем клевать или осматриваться
			if randf() < 0.45:
				_enter_state(State.PECKING)
				state_timer = randf_range(1.5, 3.0)
			else:
				state_timer = randf_range(1.0, 2.0)

# Разделение стада: мягкое отталкивание соседей, чтобы куры не слипались в одну точку
func _get_flock_separation() -> Vector2:
	var sep = Vector2.ZERO
	var chickens = get_tree().get_nodes_in_group("chickens")
	for chk in chickens:
		if chk != self and is_instance_valid(chk):
			var diff = global_position - chk.global_position
			var dist = diff.length()
			if dist > 0.1 and dist < 18.0:
				sep += (diff / dist) * (18.0 - dist) * 1.6
	return sep.limit_length(22.0)

func _update_facing() -> void:
	# Спина = движение вверх (velocity.y < -0.1)
	facing_back = velocity.y < -0.1
	# Флип = движение вправо
	if abs(velocity.x) > 0.1:
		facing_right = velocity.x > 0

# Единая функция проверки воды — такая же как у игрока (через кастомную дату is_water)
func _is_water_at(pos: Vector2) -> bool:
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if not world_map: return false
	
	var check_layers = ["RoadsLayer", "WaterLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]
	for layer_name in check_layers:
		var layer = world_map.get_node_or_null(layer_name)
		if layer and layer is TileMapLayer:
			var map_pos = layer.local_to_map(pos)
			var cell_data = layer.get_cell_tile_data(map_pos)
			if cell_data:
				return cell_data.get_custom_data("is_water")
	return false # Нет тайла вообще — тоже не ходим

func _handle_water_avoidance() -> void:
	var next_pos = global_position + direction * 12.0 + Vector2(0, -4)
	if _is_water_at(next_pos):
		direction = -direction
		if current_state == State.MOVING_TO_BUSH:
			_pick_new_state()

var _is_flying: bool = false

func _ensure_water_safety() -> void:
	if _is_flying: return
	
	if _is_water_at(global_position + Vector2(0, -4)):
		_do_panic_fly()
	else:
		last_safe_position = global_position

func _do_panic_fly() -> void:
	_is_flying = true
	var land_pos = last_safe_position
	
	# Прыжок вверх
	var fly_tween = create_tween()
	fly_tween.set_parallel(true)
	fly_tween.tween_property(self, "position:y", position.y - 40.0, 0.3)		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fly_tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.1)
	fly_tween.chain()
	
	# Плавный перелет к безопасной точке
	var fly2 = create_tween()
	fly2.tween_interval(0.3)
	fly2.tween_property(self, "global_position", land_pos - Vector2(0, 30), 0.3)		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Приземление
	var land = create_tween()
	land.tween_interval(0.6)
	land.tween_property(self, "global_position", land_pos, 0.2)		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	land.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.05)
	land.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	land.tween_callback(func():
		_is_flying = false
		_enter_state(State.IDLE)
		state_timer = 1.0
	)
