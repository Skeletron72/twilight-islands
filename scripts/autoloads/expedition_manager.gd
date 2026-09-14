extends Node

## ExpeditionManager
## Управляет механикой сумеречного шторма на острове экспедиции (RaidIsland),
## таймерами начала бури (4-8 минут), фазами нарастания, уроном по игроку,
## и отправляет мысли персонажа в лог мыслей (ThoughtLog / Чат).

signal thought_posted(text: String, color: Color)
signal storm_state_changed(is_storm: bool, phase: int)

# Времена в секундах
var raid_duration: float = 0.0
var storm_start_time: float = 360.0 # 6 минут по умолчанию (рандомизируется от 240 до 480)
var storm_severe_time: float = 600.0 # 10 минут (когда урон становится сильным)

var is_in_raid: bool = false
var storm_phase: int = 0 # 0 = ясно/обычно, 1 = начало бури (легкий урон), 2 = сильная буря (тяжелый урон)

var _damage_timer: float = 0.0
var _warning_3m_given: bool = false
var _warning_1m_given: bool = false
var _storm_start_given: bool = false
var _storm_severe_given: bool = false

# Реплики персонажа в стиле Stardew Valley
const COLOR_NORMAL = Color(0.95, 0.95, 0.90, 1.0)
const COLOR_THOUGHT = Color(0.75, 0.85, 1.0, 1.0) # Светло-голубой / раздумья
const COLOR_WARNING = Color(1.0, 0.78, 0.28, 1.0) # Золотисто-желтый / тревога
const COLOR_DANGER = Color(1.0, 0.38, 0.42, 1.0)  # Красно-коралловый / опасность
const COLOR_TWILIGHT = Color(0.85, 0.55, 1.0, 1.0) # Фиолетовый / мистика

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().scene_changed.connect(_on_scene_changed)
	_check_current_scene()

func _check_current_scene() -> void:
	var current_scene = get_tree().current_scene
	if not current_scene:
		return
		
	var scene_name = current_scene.name
	if scene_name == "RaidIsland":
		_start_expedition()
	else:
		_end_expedition()

func _on_scene_changed() -> void:
	# Небольшая задержка, чтобы сцена успела инициализироваться
	call_deferred("_check_current_scene")

func _start_expedition() -> void:
	is_in_raid = true
	raid_duration = 0.0
	storm_phase = 0
	_damage_timer = 0.0
	_warning_3m_given = false
	_warning_1m_given = false
	_storm_start_given = false
	_storm_severe_given = false
	
	# Случайный таймер начала бури: от 4 до 8 минут (240..480 секунд)
	storm_start_time = randf_range(240.0, 480.0)
	# Сильная буря наступает через 10 минут (600 секунд) от высадки, либо через 2-3 минуты после начала бури
	storm_severe_time = max(600.0, storm_start_time + 150.0)
	
	print("[ExpeditionManager] Экспедиция началась! Буря начнется через %.1f сек (сильная через %.1f сек)" % [storm_start_time, storm_severe_time])
	
	# Приветственная мысль при высадке
	get_tree().create_timer(3.0).timeout.connect(func():
		if is_in_raid and storm_phase == 0:
			post_thought("Остров выглядит диким... Нужно собрать припасы и не задерживаться.", COLOR_THOUGHT)
	)

func _end_expedition() -> void:
	if is_in_raid:
		print("[ExpeditionManager] Экспедиция завершена. Возврат на безопасную территорию.")
	is_in_raid = false
	storm_phase = 0
	_damage_timer = 0.0
	
	# Если была погода сумеречного шторма и мы дома — возвращаем ясную/обычную погоду
	var current_scene = get_tree().current_scene
	if current_scene and current_scene.name == "HomeIsland" and WeatherManager:
		if WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM:
			WeatherManager.set_weather(WeatherManager.Weather.CLEAR)

func _process(delta: float) -> void:
	if not is_in_raid:
		return
		
	var player = get_tree().get_first_node_in_group("player")
	if not player or player.get("is_dead"):
		return
		
	raid_duration += delta
	
	# Предупреждение за 2 минуты до бури
	if not _warning_3m_given and raid_duration >= (storm_start_time - 120.0):
		_warning_3m_given = true
		post_thought("Небо затягивает фиолетовой дымкой... Ветер переменился.", COLOR_WARNING)
		
	# Предупреждение за 30 секунд до бури
	if not _warning_1m_given and raid_duration >= (storm_start_time - 30.0):
		_warning_1m_given = true
		post_thought("Кажется, начинается буря... Воздух становится тяжелым.", COLOR_WARNING)
		
	# Начало бури (Фаза 1: 4-8 минут)
	if not _storm_start_given and raid_duration >= storm_start_time:
		_storm_start_given = true
		storm_phase = 1
		storm_state_changed.emit(true, 1)
		if WeatherManager:
			WeatherManager.set_weather(WeatherManager.Weather.TWILIGHT_STORM)
		post_thought("Буря усиливается... Сумрак начинает разъедать силы! Нужно спешить к лодке!", COLOR_DANGER)
		
	# Усиление бури (Фаза 2: 10 минут)
	if not _storm_severe_given and raid_duration >= storm_severe_time:
		_storm_severe_given = true
		storm_phase = 2
		storm_state_changed.emit(true, 2)
		post_thought("Мне нехорошо... Шторм разбушевался вовсю! Скорее к лодке, иначе я погибну!", COLOR_DANGER)

	# Нанесение урона в бурю
	if storm_phase > 0:
		_damage_timer += delta
		var tick_interval = 2.0 if storm_phase == 1 else 1.0
		if _damage_timer >= tick_interval:
			_damage_timer = 0.0
			_apply_storm_damage(player)

func _apply_storm_damage(player: Node2D) -> void:
	if GameStateManager.is_god_mode:
		return
		
	if storm_phase == 1:
		# Медленный периодический урон (2 HP каждые 2 сек)
		GameStateManager.take_damage(2.0)
		if player.has_method("_flash_red"):
			player._flash_red()
		if randf() < 0.15:
			post_thought("Сумрак жжет кожу... Силы уходят.", COLOR_TWILIGHT)
	elif storm_phase == 2:
		# Сильный урон (6 HP каждую 1 сек)
		GameStateManager.take_damage(6.0)
		if player.has_method("_flash_red"):
			player._flash_red()
		if player.has_method("shake_camera"):
			player.shake_camera(1.8, 0.1)
		if randf() < 0.22:
			post_thought("Теряю сознание... Скорее к лодке!", COLOR_DANGER)

func post_thought(text: String, color: Color = COLOR_NORMAL) -> void:
	print("[Thought] ", text)
	thought_posted.emit(text, color)
