extends Node2D
class_name WeatherEffects

## WeatherEffects - визуальный контроллер погодных эффектов для Twilight Islands.
## Управляет облаками, ветром, косым атмосферным дождем, брызгами, грозовыми молниями и объемным туманом.
## Все частицы и эффекты живут в МИРОВЫХ координатах (top_level = true).

const CLOUDS_TEXTURE = preload("res://assets/new_assets/Cute_Fantasy/Weather effects/Clouds.png")
const WIND_TEXTURE = preload("res://assets/new_assets/Cute_Fantasy/Weather effects/Wind_Anim.png")
const RAIN_DROP_TEXTURE = preload("res://assets/new_assets/Cute_Fantasy/Weather effects/Rain_Drop.png")
const RAIN_IMPACT_TEXTURE = preload("res://assets/new_assets/Cute_Fantasy/Weather effects/Rain_Drop_Impact.png")
const FOG_SHADER = preload("res://resources/shaders/volumetric_fog.gdshader")

# 4 вариации облаков из Clouds.png (128x128, 4 клетки 64x64)
const CLOUD_REGIONS = [
	Rect2(0, 0, 64, 64),
	Rect2(64, 0, 64, 64),
	Rect2(0, 64, 64, 64),
	Rect2(64, 64, 64, 64)
]

# Скорости для 4 видов облаков (разные типы летят с разной скоростью в мире)
const CLOUD_SPEEDS = [48.0, 36.0, 24.0, 32.0]

# Контейнеры слоев в мировом пространстве (top_level = true)
var clouds_container: Node2D
var wind_container: Node2D
var rain_container: Node2D
var impact_container: Node2D

# Экранные оверлеи
var fog_rect: ColorRect
var lightning_rect: ColorRect
var current_fog_density: float = 0.45

# Облака
var clouds: Array = []
const MAX_CLOUDS: int = 12

# Ветер
var wind_timer: float = 0.0
var active_wind_particles: Array = []

# Дождь (120 атмосферных капель с разной глубиной и скоростью)
const MAX_RAIN_DROPS: int = 120
var rain_drops: Array = [] # { sprite, active, pos, vx, vy, target_y, base_alpha, tier }

# Брызги на земле
const MAX_IMPACTS: int = 45
var impact_pool: Array = []

# Молнии
var lightning_timer: float = 0.0
var next_lightning_time: float = 7.0

# Размеры видимой области экрана
const VIEW_W: float = 680.0
const VIEW_H: float = 400.0

func _ready() -> void:
	add_to_group("weather_effects")
	z_index = 2000
	z_as_relative = false
	
	_setup_fog_rect()
	_setup_lightning()
	_setup_clouds()
	_setup_wind()
	_setup_rain()
	_setup_impacts()
	
	if WeatherManager:
		WeatherManager.weather_changed.connect(_on_weather_changed)
		WeatherManager.twilight_storm_phase_changed.connect(_on_twilight_phase_changed)
		_on_weather_changed(WeatherManager.current_weather, WeatherManager.get_weather_info())

func _setup_fog_rect() -> void:
	fog_rect = ColorRect.new()
	fog_rect.name = "FogRect"
	fog_rect.custom_minimum_size = Vector2(VIEW_W + 160, VIEW_H + 160)
	fog_rect.z_index = 2100
	fog_rect.z_as_relative = false
	fog_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var mat = ShaderMaterial.new()
	mat.shader = FOG_SHADER
	fog_rect.material = mat
	fog_rect.modulate.a = 0.0
	add_child(fog_rect)

func _setup_lightning() -> void:
	lightning_rect = ColorRect.new()
	lightning_rect.name = "LightningRect"
	lightning_rect.custom_minimum_size = Vector2(VIEW_W + 160, VIEW_H + 160)
	lightning_rect.z_index = 2900
	lightning_rect.z_as_relative = false
	lightning_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	lightning_rect.color = Color.WHITE
	lightning_rect.modulate.a = 0.0
	add_child(lightning_rect)

func _setup_clouds() -> void:
	clouds_container = Node2D.new()
	clouds_container.name = "CloudsContainer"
	clouds_container.top_level = true
	clouds_container.z_index = 2500
	add_child(clouds_container)
	
	var cam_pos = _get_camera_pos()
	
	for i in range(MAX_CLOUDS):
		var sp = Sprite2D.new()
		sp.texture = CLOUDS_TEXTURE
		sp.region_enabled = true
		var var_idx = i % 4
		sp.region_rect = CLOUD_REGIONS[var_idx]
		
		var sc = randf_range(1.6, 2.7)
		sp.scale = Vector2(sc, sc)
		sp.modulate = Color(1.0, 1.0, 1.0, randf_range(0.40, 0.65))
		
		var c_data = {
			"sprite": sp,
			"var_idx": var_idx,
			"speed": CLOUD_SPEEDS[var_idx] * randf_range(0.85, 1.15),
			"pos": cam_pos + Vector2(randf_range(-VIEW_W * 0.6, VIEW_W * 0.6), randf_range(-VIEW_H * 0.5, VIEW_H * 0.5))
		}
		sp.position = c_data["pos"]
		clouds_container.add_child(sp)
		clouds.append(c_data)
		sp.visible = false

func _setup_wind() -> void:
	wind_container = Node2D.new()
	wind_container.name = "WindContainer"
	wind_container.top_level = true
	wind_container.z_index = 2300
	add_child(wind_container)

func _setup_rain() -> void:
	rain_container = Node2D.new()
	rain_container.name = "RainContainer"
	rain_container.top_level = true
	rain_container.z_index = 2200
	add_child(rain_container)
	
	for i in range(MAX_RAIN_DROPS):
		var sp = Sprite2D.new()
		sp.texture = RAIN_DROP_TEXTURE
		sp.visible = false
		
		# 3 уровня глубины капель дождя для реалистичного объема:
		# 0 = фон/легкие быстрые капли, 1 = средний план, 2 = передний план/крупные капли
		var tier = i % 3
		var sc = 0.85 if tier == 0 else (1.15 if tier == 1 else 1.45)
		var base_a = 0.45 if tier == 0 else (0.75 if tier == 1 else 0.95)
		sp.scale = Vector2(sc, sc)
		
		rain_container.add_child(sp)
		rain_drops.append({
			"sprite": sp,
			"active": false,
			"pos": Vector2.ZERO,
			"vx": -240.0,
			"vy": 420.0,
			"target_y": 0.0,
			"base_alpha": base_a,
			"tier": tier
		})

func _setup_impacts() -> void:
	impact_container = Node2D.new()
	impact_container.name = "ImpactContainer"
	impact_container.top_level = true
	impact_container.z_index = 2050
	add_child(impact_container)
	
	for i in range(MAX_IMPACTS):
		var sp = Sprite2D.new()
		sp.texture = RAIN_IMPACT_TEXTURE
		sp.hframes = 7
		sp.frame = 0
		sp.visible = false
		sp.scale = Vector2(1.1, 1.1)
		impact_container.add_child(sp)
		impact_pool.append({
			"sprite": sp,
			"active": false,
			"frame": 0,
			"timer": 0.0
		})

func _process(delta: float) -> void:
	var cam_pos = _get_camera_pos()
	
	fog_rect.position = cam_pos - fog_rect.custom_minimum_size / 2.0
	lightning_rect.position = cam_pos - lightning_rect.custom_minimum_size / 2.0
	
	if fog_rect.material is ShaderMaterial:
		var mat = fog_rect.material as ShaderMaterial
		mat.set_shader_parameter("world_offset", cam_pos)
		mat.set_shader_parameter("view_size", Vector2(VIEW_W, VIEW_H))
		mat.set_shader_parameter("fog_density", current_fog_density)
	
	var w = WeatherManager.current_weather if WeatherManager else WeatherManager.Weather.CLEAR
	
	_process_clouds(delta, w, cam_pos)
	_process_wind(delta, w, cam_pos)
	_process_rain(delta, w, cam_pos)
	_process_impacts(delta)
	_process_lightning(delta, w, cam_pos)

func _get_camera_pos() -> Vector2:
	var cam = get_viewport().get_camera_2d()
	if cam:
		return cam.get_screen_center_position()
	var p = get_tree().get_first_node_in_group("player")
	if p and is_instance_valid(p):
		return p.global_position
	return global_position

func _on_weather_changed(w: int, _info: Dictionary) -> void:
	var target_fog_a = 0.0
	var fog_tint = Color(0.85, 0.88, 0.92, 0.45)
	
	# ОБЛАКА ЛЕТЯТ ТОЛЬКО В «ОБЛАЧНО» И «ПАСМУРНО»
	# В дождь, грозу, туман и сумеречный шторм летящие облака скрыты!
	var show_clouds = (w in [WeatherManager.Weather.CLOUDY, WeatherManager.Weather.OVERCAST])
	for c in clouds:
		c["sprite"].visible = show_clouds
		if w == WeatherManager.Weather.OVERCAST:
			c["sprite"].modulate = Color(0.78, 0.80, 0.85, 0.60)
		else:
			c["sprite"].modulate = Color(1.0, 1.0, 1.0, randf_range(0.45, 0.65))

	match w:
		WeatherManager.Weather.FOG:
			# Объемный белесый туман в стиле Project Zomboid
			target_fog_a = 1.0
			current_fog_density = 0.75
			fog_tint = Color(0.92, 0.94, 0.97, 0.85)
		WeatherManager.Weather.OVERCAST:
			# Серая пасмурная дымка (как прежний туман)
			target_fog_a = 0.82
			current_fog_density = 0.38
			fog_tint = Color(0.74, 0.77, 0.82, 0.48)
		WeatherManager.Weather.RAIN:
			# Эффект пасмурности при дожде
			target_fog_a = 0.88
			current_fog_density = 0.44
			fog_tint = Color(0.64, 0.68, 0.76, 0.55)
		WeatherManager.Weather.THUNDERSTORM:
			# Темная грозовая пасмурность
			target_fog_a = 0.95
			current_fog_density = 0.52
			fog_tint = Color(0.48, 0.52, 0.62, 0.65)
		WeatherManager.Weather.TWILIGHT_STORM:
			# Фиолетовая грозовая пасмурность
			target_fog_a = 0.86
			current_fog_density = 0.50
			fog_tint = Color(0.65, 0.30, 0.80, 0.55)
		_:
			target_fog_a = 0.0
			current_fog_density = 0.0
			
	var tw = create_tween()
	tw.tween_property(fog_rect, "modulate:a", target_fog_a, 2.5)
	if fog_rect.material is ShaderMaterial:
		fog_rect.material.set_shader_parameter("fog_color", fog_tint)

func _on_twilight_phase_changed(_phase: int) -> void:
	if WeatherManager and WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM:
		_on_weather_changed(WeatherManager.Weather.TWILIGHT_STORM, WeatherManager.get_weather_info())

func _process_clouds(delta: float, w: int, cam_pos: Vector2) -> void:
	if not (w in [WeatherManager.Weather.CLOUDY, WeatherManager.Weather.OVERCAST]):
		return
		
	var half_w = VIEW_W * 0.5 + 140.0
	var half_h = VIEW_H * 0.5 + 80.0
	
	for c in clouds:
		c["pos"].x -= c["speed"] * delta
		
		if c["pos"].x < cam_pos.x - half_w:
			c["pos"].x = cam_pos.x + half_w + randf_range(30, 120)
			c["pos"].y = cam_pos.y + randf_range(-half_h, half_h)
		elif c["pos"].x > cam_pos.x + half_w + 300.0:
			c["pos"].x = cam_pos.x + half_w + randf_range(10, 80)
			
		if abs(c["pos"].y - cam_pos.y) > half_h + 150.0:
			c["pos"].y = cam_pos.y + randf_range(-half_h, half_h)
			c["pos"].x = cam_pos.x + randf_range(-half_w, half_w)
			
		c["sprite"].position = c["pos"]

func _process_wind(delta: float, w: int, cam_pos: Vector2) -> void:
	var gust_rate = -1.0
	var gusts_per_tick = 1
	match w:
		WeatherManager.Weather.CLOUDY:
			gust_rate = 0.42
			gusts_per_tick = 1 if randf() < 0.6 else 2
		WeatherManager.Weather.OVERCAST:
			gust_rate = 0.70
			gusts_per_tick = 1 if randf() < 0.7 else 2
		WeatherManager.Weather.THUNDERSTORM:
			gust_rate = 0.22
			gusts_per_tick = 2 if randf() < 0.5 else 3
		WeatherManager.Weather.TWILIGHT_STORM:
			gust_rate = 0.22
			gusts_per_tick = 2 if randf() < 0.5 else 3
			
	if gust_rate > 0.0:
		wind_timer += delta
		if wind_timer >= gust_rate:
			wind_timer = 0.0
			for _k in range(gusts_per_tick):
				_spawn_wind_gust(w, cam_pos)
			
	for i in range(active_wind_particles.size() - 1, -1, -1):
		var p = active_wind_particles[i]
		p["timer"] += delta
		var frame = int(p["timer"] / 0.045)
		
		p["pos"].x += p["vx"] * delta
		p["pos"].y += p["vy"] * delta
		p["sprite"].position = p["pos"]
		
		if frame >= 14:
			p["sprite"].queue_free()
			active_wind_particles.remove_at(i)
		else:
			p["sprite"].frame = frame

func _spawn_wind_gust(w: int, cam_pos: Vector2) -> void:
	var sp = Sprite2D.new()
	sp.texture = WIND_TEXTURE
	sp.hframes = 14
	sp.frame = 0
	
	var blow_left = true
	var sc = randf_range(0.9, 1.45)
	sp.scale = Vector2(sc, sc) if blow_left else Vector2(-sc, sc)
	
	var is_storm = (w in [WeatherManager.Weather.THUNDERSTORM, WeatherManager.Weather.TWILIGHT_STORM])
	
	if w == WeatherManager.Weather.TWILIGHT_STORM:
		sp.modulate = Color(0.85, 0.45, 1.0, randf_range(0.75, 0.95))
	elif w == WeatherManager.Weather.THUNDERSTORM:
		sp.modulate = Color(0.85, 0.92, 1.0, randf_range(0.70, 0.90))
	else:
		sp.modulate = Color(1.0, 1.0, 1.0, randf_range(0.55, 0.75))
		
	var start_pos = cam_pos + Vector2(
		randf_range(-VIEW_W * 0.52, VIEW_W * 0.52),
		randf_range(-VIEW_H * 0.52, VIEW_H * 0.52)
	)
	sp.position = start_pos
	
	wind_container.add_child(sp)
	var speed = randf_range(130.0, 210.0) if is_storm else randf_range(85.0, 145.0)
	active_wind_particles.append({
		"sprite": sp,
		"timer": 0.0,
		"pos": start_pos,
		"vx": -speed if blow_left else speed,
		"vy": randf_range(-14.0, 14.0)
	})

func _process_rain(delta: float, w: int, cam_pos: Vector2) -> void:
	var is_raining = false
	if WeatherManager:
		is_raining = WeatherManager.is_precipitation()
		
	if not is_raining:
		for d in rain_drops:
			if d["active"]:
				d["active"] = false
				d["sprite"].visible = false
		return
		
	var is_twilight = (w == WeatherManager.Weather.TWILIGHT_STORM)
	
	var half_w = VIEW_W * 0.5 + 100.0
	var half_h = VIEW_H * 0.5 + 60.0
	
	for d in rain_drops:
		if not d["active"]:
			# Спавним каплю сверху и справа, учитывая наклон траектории (справа-сверху влево-вниз)
			d["active"] = true
			d["vx"] = -randf_range(210.0, 270.0)
			d["vy"] = randf_range(390.0, 470.0)
			
			# Начальная позиция со смещением вправо для компенсации угла падения
			d["pos"] = Vector2(
				cam_pos.x + randf_range(-half_w * 0.4, half_w * 1.5),
				cam_pos.y - half_h - randf_range(10, 90)
			)
			d["target_y"] = cam_pos.y + randf_range(-half_h * 0.45, half_h * 0.85)
			d["sprite"].position = d["pos"]
			
			# Точная ориентация спрайта по вектору падения
			var drop_angle = atan2(d["vy"], d["vx"]) - (3.0 * PI / 4.0)
			d["sprite"].rotation = drop_angle
			
			var drop_color: Color
			if is_twilight:
				drop_color = Color(0.85, 0.55, 1.0, d["base_alpha"])
			else:
				drop_color = Color(0.72, 0.88, 1.0, d["base_alpha"])
				
			d["sprite"].modulate = drop_color
			d["sprite"].visible = true
		else:
			# Косой полет капли из правого верхнего угла в левый нижний
			d["pos"].x += d["vx"] * delta
			d["pos"].y += d["vy"] * delta
			d["sprite"].position = d["pos"]
			
			if d["pos"].y >= d["target_y"]:
				d["active"] = false
				d["sprite"].visible = false
				_spawn_rain_impact(d["pos"], is_twilight)
			elif d["pos"].x < cam_pos.x - half_w - 60.0 or (d["pos"].y - cam_pos.y) > half_h + 100.0:
				d["active"] = false
				d["sprite"].visible = false

func _spawn_rain_impact(world_pos: Vector2, is_twilight: bool) -> void:
	for imp in impact_pool:
		if not imp["active"]:
			imp["active"] = true
			imp["frame"] = 0
			imp["timer"] = 0.0
			imp["sprite"].position = world_pos
			imp["sprite"].frame = 0
			imp["sprite"].modulate = Color(0.88, 0.6, 1.0, 0.95) if is_twilight else Color(0.75, 0.9, 1.0, 0.85)
			imp["sprite"].visible = true
			return

func _process_impacts(delta: float) -> void:
	var frame_time = 0.04
	for imp in impact_pool:
		if imp["active"]:
			imp["timer"] += delta
			var f = int(imp["timer"] / frame_time)
			if f >= 7:
				imp["active"] = false
				imp["sprite"].visible = false
			else:
				imp["sprite"].frame = f

func _process_lightning(delta: float, w: int, cam_pos: Vector2) -> void:
	var is_storm = (w == WeatherManager.Weather.THUNDERSTORM) or (w == WeatherManager.Weather.TWILIGHT_STORM and WeatherManager.twilight_storm_phase == 2)
	if not is_storm:
		return
		
	lightning_timer += delta
	if lightning_timer >= next_lightning_time:
		lightning_timer = 0.0
		next_lightning_time = randf_range(5.5, 9.5)
		_spawn_ground_lightning_strike(w == WeatherManager.Weather.TWILIGHT_STORM, cam_pos)

func _spawn_ground_lightning_strike(is_twilight: bool, cam_pos: Vector2) -> void:
	var player = get_tree().get_first_node_in_group("player")
	var target_pos = cam_pos
	
	if player and is_instance_valid(player):
		var p_pos = player.global_position
		var enemies = get_tree().get_nodes_in_group("enemies")
		var nearby_enemies = []
		for e in enemies:
			if is_instance_valid(e) and not e.get("is_dead") and p_pos.distance_to(e.global_position) <= 240.0:
				nearby_enemies.append(e)
				
		var roll = randf()
		if roll < 0.35:
			# Удар прямо в позицию, где сейчас стоит игрок!
			# Благодаря времени телеграфа (~0.92 сек) у игрока есть окно среагировать и сделать кувырок (Alt)!
			target_pos = p_pos
		elif roll < 0.65 and not nearby_enemies.is_empty():
			# Удар возле моба
			var chosen_enemy = nearby_enemies.pick_random()
			target_pos = chosen_enemy.global_position + Vector2(randf_range(-15, 15), randf_range(-15, 15))
		elif roll < 0.85:
			# Рядом с игроком (50-100 px)
			var angle = randf() * TAU
			var dist = randf_range(50.0, 100.0)
			target_pos = p_pos + Vector2(cos(angle), sin(angle)) * dist
		else:
			# Фоновый удар в поле зрения (110-200 px)
			var angle = randf() * TAU
			var dist = randf_range(110.0, 200.0)
			target_pos = p_pos + Vector2(cos(angle), sin(angle)) * dist
	else:
		target_pos = cam_pos + Vector2(randf_range(-140, 140), randf_range(-90, 90))
		
	var strike = LightningStrike.new()
	strike.is_twilight = is_twilight
	strike.global_position = target_pos
	if get_tree() and get_tree().current_scene:
		get_tree().current_scene.add_child(strike)

func trigger_lightning_flash(is_twilight: bool = false) -> void:
	var flash_color = Color(0.85, 0.40, 1.0) if is_twilight else Color(0.9, 0.95, 1.0)
	lightning_rect.color = flash_color
	
	var tw = create_tween()
	tw.tween_property(lightning_rect, "modulate:a", 0.85, 0.05)
	tw.tween_property(lightning_rect, "modulate:a", 0.15, 0.04)
	tw.tween_property(lightning_rect, "modulate:a", 0.95, 0.06)
	tw.tween_property(lightning_rect, "modulate:a", 0.0, 0.32).set_ease(Tween.EASE_OUT)
