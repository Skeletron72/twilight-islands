extends Node

# ─── Audio Manager (Twilight Islands) ─────────────────────────────────────────
# Управляет фоновой музыкой (BGM), динамическим эмбиентом природы (день/ночь)
# и звуковыми эффектами.

# Музыкальные треки
const MUSIC_DAY = "res://assets/audio/music/music_island1.mp3"
const MUSIC_NIGHT = "res://assets/audio/music/music_night.mp3"
const MUSIC_FOREST = "res://assets/audio/music/music_forest.mp3"

# Эмбиент природы
const AMBIENCE_WIND = "res://assets/audio/sfx/ambience/ambience_wind.mp3"
const AMBIENCE_BIRDS = "res://assets/audio/sfx/ambience/ambience_birds.mp3"
const AMBIENCE_CRICKETS = "res://assets/audio/sfx/ambience/sfx_crickets.mp3"

var _music_player_a: AudioStreamPlayer
var _music_player_b: AudioStreamPlayer
var _active_music_player: AudioStreamPlayer = null
var _current_music_path: String = ""
var _music_tween: Tween = null

var _ambience_wind: AudioStreamPlayer
var _ambience_birds: AudioStreamPlayer
var _ambience_crickets: AudioStreamPlayer
var _ambience_tween: Tween = null

var is_in_interior: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_audio_players()
	
	# Подключаемся к смене времени суток
	if GameStateManager.has_signal("time_changed"):
		GameStateManager.time_changed.connect(_on_time_changed)
		
	# Запуск фонового звука и музыки
	call_deferred("_start_initial_audio")

func _setup_audio_players() -> void:
	# Музыка (2 плеера для мягкого кроссфейда)
	_music_player_a = AudioStreamPlayer.new()
	_music_player_a.name = "MusicPlayerA"
	_music_player_a.bus = &"Music"
	add_child(_music_player_a)
	
	_music_player_b = AudioStreamPlayer.new()
	_music_player_b.name = "MusicPlayerB"
	_music_player_b.bus = &"Music"
	add_child(_music_player_b)
	
	_music_player_a.finished.connect(func(): _on_music_finished(_music_player_a))
	_music_player_b.finished.connect(func(): _on_music_finished(_music_player_b))
	
	# Эмбиент ветра (постоянный мягкий шум бриза)
	_ambience_wind = AudioStreamPlayer.new()
	_ambience_wind.name = "AmbienceWind"
	_ambience_wind.bus = &"Ambience"
	_ambience_wind.stream = load(AMBIENCE_WIND)
	_ambience_wind.volume_db = -14.0
	add_child(_ambience_wind)
	_ambience_wind.finished.connect(func(): if not is_in_interior: _ambience_wind.play())
	
	# Дневной эмбиент (птицы)
	_ambience_birds = AudioStreamPlayer.new()
	_ambience_birds.name = "AmbienceBirds"
	_ambience_birds.bus = &"Ambience"
	_ambience_birds.stream = load(AMBIENCE_BIRDS)
	_ambience_birds.volume_db = -8.0
	add_child(_ambience_birds)
	_ambience_birds.finished.connect(func(): if not is_in_interior and _is_daytime(): _ambience_birds.play())
	
	# Ночной эмбиент (сверчки / цикады)
	_ambience_crickets = AudioStreamPlayer.new()
	_ambience_crickets.name = "AmbienceCrickets"
	_ambience_crickets.bus = &"Ambience"
	_ambience_crickets.stream = load(AMBIENCE_CRICKETS)
	_ambience_crickets.volume_db = -80.0
	add_child(_ambience_crickets)
	_ambience_crickets.finished.connect(func(): if not is_in_interior and not _is_daytime(): _ambience_crickets.play())

func _start_initial_audio() -> void:
	_ambience_wind.play()
	_ambience_birds.play()
	_ambience_crickets.play()
	
	var time = GameStateManager.current_time
	_update_time_audio(time, 0.0)

func _is_daytime() -> bool:
	return GameStateManager.current_time != GameStateManager.TimeOfDay.NIGHT

func _on_time_changed(new_time: int) -> void:
	_update_time_audio(new_time, 2.5)

func _update_time_audio(time: int, fade_duration: float) -> void:
	var target_music: String
	var is_night = (time == GameStateManager.TimeOfDay.NIGHT)
	
	if is_night:
		target_music = MUSIC_NIGHT
	else:
		target_music = MUSIC_DAY
		
	play_music(target_music, fade_duration)
	
	# Кроссфейд эмбиента птицы <-> сверчки
	if _ambience_tween and _ambience_tween.is_valid():
		_ambience_tween.kill()
	
	var target_birds_vol = -80.0 if (is_night or is_in_interior) else -8.0
	var target_crickets_vol = -80.0 if (not is_night or is_in_interior) else -6.0
	var target_wind_vol = -24.0 if is_in_interior else -14.0
	
	if fade_duration <= 0.0:
		_ambience_birds.volume_db = target_birds_vol
		_ambience_crickets.volume_db = target_crickets_vol
		_ambience_wind.volume_db = target_wind_vol
	else:
		_ambience_tween = create_tween().set_parallel(true)
		_ambience_tween.tween_property(_ambience_birds, "volume_db", target_birds_vol, fade_duration)
		_ambience_tween.tween_property(_ambience_crickets, "volume_db", target_crickets_vol, fade_duration)
		_ambience_tween.tween_property(_ambience_wind, "volume_db", target_wind_vol, fade_duration)

func play_music(music_path: String, fade_time: float = 2.0) -> void:
	if _current_music_path == music_path and _active_music_player and _active_music_player.playing:
		return
		
	_current_music_path = music_path
	var stream = load(music_path)
	if not stream: return
	
	var next_player = _music_player_b if _active_music_player == _music_player_a else _music_player_a
	var prev_player = _active_music_player
	
	next_player.stream = stream
	next_player.volume_db = -80.0
	next_player.play()
	_active_music_player = next_player
	
	if _music_tween and _music_tween.is_valid():
		_music_tween.kill()
	
	var target_vol = -10.0 if is_in_interior else -5.0
	if fade_time <= 0.0:
		next_player.volume_db = target_vol
		if prev_player: prev_player.stop()
	else:
		_music_tween = create_tween().set_parallel(true)
		_music_tween.tween_property(next_player, "volume_db", target_vol, fade_time).set_trans(Tween.TRANS_SINE)
		if prev_player and prev_player.playing:
			_music_tween.tween_property(prev_player, "volume_db", -80.0, fade_time).set_trans(Tween.TRANS_SINE)
			_music_tween.chain().tween_callback(prev_player.stop)

func _on_music_finished(player: AudioStreamPlayer) -> void:
	if player == _active_music_player and not is_in_interior:
		# Пауза перед повторным проигрыванием для естественности (2-4 секунды тишины)
		var t = get_tree().create_timer(randf_range(2.0, 4.0))
		t.timeout.connect(func():
			if player == _active_music_player:
				player.play()
		)

func set_interior(interior: bool) -> void:
	is_in_interior = interior
	_update_time_audio(GameStateManager.current_time, 1.0)

# ─── Проигрывание 2D объемных SFX ─────────────────────────────────────────────
func play_spatial_sfx(stream: AudioStream, global_pos: Vector2, pitch: float = 1.0, volume_db: float = 0.0, max_dist: float = 400.0) -> void:
	var sfx = AudioStreamPlayer2D.new()
	sfx.bus = &"SFX"
	sfx.stream = stream
	sfx.global_position = global_pos
	sfx.pitch_scale = pitch
	sfx.volume_db = volume_db
	sfx.max_distance = max_dist
	sfx.attenuation = 1.5
	sfx.panning_strength = 1.0
	
	var root = get_tree().current_scene
	if root:
		root.add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)

# ─── Прямое воспроизведение SFX (для действий игрока, подбора предметов и UI) ──
func play_sfx(stream: AudioStream, pitch: float = 1.0, volume_db: float = 0.0) -> void:
	if not stream: return
	var sfx = AudioStreamPlayer.new()
	sfx.bus = &"SFX"
	sfx.stream = stream
	sfx.pitch_scale = pitch
	sfx.volume_db = volume_db
	add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

