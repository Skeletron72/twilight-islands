extends Node2D
class_name FireflyManager

# Менеджер ночных светлячков. Спавнит редких светлячков вокруг игрока ночью и рассеивает их на рассвете.

@export var max_fireflies: int = 8
@export var spawn_radius_min: float = 70.0
@export var spawn_radius_max: float = 240.0
@export var despawn_distance: float = 380.0

var firefly_scene: PackedScene = preload("res://scenes/vfx/firefly.tscn")
var _spawn_timer: float = 0.0
var _active_fireflies: Array[Firefly] = []

func _ready() -> void:
	GameStateManager.time_changed.connect(_on_time_changed)

func _process(delta: float) -> void:
	# Очистка недействительных ссылок
	_active_fireflies = _active_fireflies.filter(func(f): return is_instance_valid(f))
	
	var is_night = GameStateManager.current_time == GameStateManager.TimeOfDay.NIGHT
	var is_dusk = GameStateManager.current_time == GameStateManager.TimeOfDay.DUSK
	
	if is_night or is_dusk:
		_process_night_fireflies(delta)
	else:
		# Если наступил день или утро — плавно рассеиваем светлячков
		if not _active_fireflies.is_empty():
			for f in _active_fireflies:
				f.fade_out_and_free(randf_range(1.5, 3.0))
			_active_fireflies.clear()

func _process_night_fireflies(delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player or not is_instance_valid(player):
		return
		
	var player_pos = player.global_position
	
	# Проверка дальности и удаление улетевших слишком далеко светлячков
	for f in _active_fireflies:
		if f.global_position.distance_to(player_pos) > despawn_distance:
			f.fade_out_and_free(1.5)
			
	# Спавн новых светлячков, если их меньше нормы
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_timer = randf_range(2.0, 4.0)
		if _active_fireflies.size() < max_fireflies:
			_spawn_firefly(player_pos)

func _spawn_firefly(center_pos: Vector2) -> void:
	if not firefly_scene: return
	
	var angle = randf() * TAU
	var dist = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_pos = center_pos + Vector2(cos(angle), sin(angle)) * dist
	
	var firefly = firefly_scene.instantiate() as Firefly
	firefly.global_position = spawn_pos
	add_child(firefly)
	_active_fireflies.append(firefly)

func _on_time_changed(new_time: int) -> void:
	if new_time == GameStateManager.TimeOfDay.MORNING or new_time == GameStateManager.TimeOfDay.DAY:
		for f in _active_fireflies:
			if is_instance_valid(f):
				f.fade_out_and_free(randf_range(1.5, 3.0))
		_active_fireflies.clear()
