extends Node

## WeatherManager - менеджер погодных условий для Twilight Islands.
## Отвечает за состояние погоды, генерацию прогнозов и оповещение игровых систем.

enum Weather {
	CLEAR,          # Ясно
	CLOUDY,         # Облачно
	FOG,            # Туман
	OVERCAST,       # Пасмурно
	RAIN,           # Дождь
	THUNDERSTORM,   # Гроза
	TWILIGHT_STORM  # Сумеречный шторм
}

const WEATHER_DATA = {
	Weather.CLEAR: {
		"id": "clear",
		"name": "Ясно",
		"desc": "Чистое ясное небо и яркое солнце.",
		"color_mod": Color(1.0, 1.0, 1.0, 1.0),
		"precipitation": false,
		"wind": 0.1,
		"weight": 30,
		"ui_color": Color(1.0, 0.95, 0.65, 1.0)
	},
	Weather.CLOUDY: {
		"id": "cloudy",
		"name": "Облачно",
		"desc": "Легкие облака плывут по небу.",
		"color_mod": Color(0.96, 0.96, 0.98, 1.0),
		"precipitation": false,
		"wind": 0.25,
		"weight": 25,
		"ui_color": Color(0.88, 0.92, 0.98, 1.0)
	},
	Weather.FOG: {
		"id": "fog",
		"name": "Туман",
		"desc": "Густой туман окутывает острова и воду.",
		"color_mod": Color(0.86, 0.88, 0.92, 1.0),
		"precipitation": false,
		"wind": 0.05,
		"weight": 12,
		"ui_color": Color(0.78, 0.86, 0.92, 1.0)
	},
	Weather.OVERCAST: {
		"id": "overcast",
		"name": "Пасмурно",
		"desc": "Небо затянуто серыми тяжелыми тучами.",
		"color_mod": Color(0.82, 0.82, 0.86, 1.0),
		"precipitation": false,
		"wind": 0.35,
		"weight": 15,
		"ui_color": Color(0.80, 0.80, 0.84, 1.0)
	},
	Weather.RAIN: {
		"id": "rain",
		"name": "Дождь",
		"desc": "Свежий дождь увлажняет почву.",
		"color_mod": Color(0.72, 0.76, 0.85, 1.0),
		"precipitation": true,
		"wind": 0.45,
		"weight": 10,
		"ui_color": Color(0.55, 0.80, 1.0, 1.0)
	},
	Weather.THUNDERSTORM: {
		"id": "thunderstorm",
		"name": "Гроза",
		"desc": "Свирепый ливень с раскатами грома и молниями.",
		"color_mod": Color(0.55, 0.58, 0.70, 1.0),
		"precipitation": true,
		"wind": 0.75,
		"weight": 5,
		"ui_color": Color(0.85, 0.70, 1.0, 1.0)
	},
	Weather.TWILIGHT_STORM: {
		"id": "twilight_storm",
		"name": "Сумеречный шторм",
		"desc": "Аномальный шторм с фиолетовым свечением и сильным ветром.",
		"color_mod": Color(0.65, 0.45, 0.80, 1.0),
		"precipitation": true,
		"wind": 0.95,
		"weight": 3,
		"ui_color": Color(0.92, 0.52, 1.0, 1.0)
	}
}

signal weather_changed(new_weather: Weather, weather_info: Dictionary)
signal forecast_changed(tomorrow_weather: Weather, forecast_info: Dictionary)
signal twilight_storm_phase_changed(new_phase: int)

var current_weather: Weather = Weather.CLEAR
var next_weather: Weather = Weather.CLEAR
var is_weather_locked: bool = false
var twilight_storm_phase: int = 1 # 1 = Фиолетовая пасмурность, 2 = Фиолетовая гроза
var _twilight_timer: SceneTreeTimer = null

func _ready() -> void:
	if GameStateManager.has_signal("day_changed"):
		GameStateManager.day_changed.connect(_on_day_changed)
	
	next_weather = roll_weather()

func set_weather(w: Weather) -> void:
	if current_weather != w or not has_node("/root"):
		current_weather = w
		if current_weather == Weather.TWILIGHT_STORM:
			twilight_storm_phase = 1
			twilight_storm_phase_changed.emit(1)
			_start_twilight_storm_escalation()
		weather_changed.emit(current_weather, get_weather_info(current_weather))

func _start_twilight_storm_escalation() -> void:
	# Фаза 1 (фиолетовая пасмурность) длится 16 секунд, затем переходит в фазу 2 (фиолетовая гроза)
	await get_tree().create_timer(16.0).timeout
	if current_weather == Weather.TWILIGHT_STORM and twilight_storm_phase == 1:
		twilight_storm_phase = 2
		twilight_storm_phase_changed.emit(2)
		weather_changed.emit(current_weather, get_weather_info(current_weather))

func roll_weather() -> Weather:
	var total_weight = 0
	for key in WEATHER_DATA.keys():
		total_weight += WEATHER_DATA[key].get("weight", 10)
		
	var roll = randi_range(1, total_weight)
	var accum = 0
	for key in WEATHER_DATA.keys():
		accum += WEATHER_DATA[key].get("weight", 10)
		if roll <= accum:
			return key as Weather
			
	return Weather.CLEAR

func _on_day_changed(_new_day: int) -> void:
	if not is_weather_locked:
		set_weather(next_weather)
		next_weather = roll_weather()
		forecast_changed.emit(next_weather, get_weather_info(next_weather))

func get_weather_name(w: Weather = current_weather) -> String:
	if w == Weather.TWILIGHT_STORM and w == current_weather:
		if twilight_storm_phase == 1:
			return "Сумеречный шторм (Сгущение)"
		else:
			return "Сумеречный шторм"
	return WEATHER_DATA.get(w, {}).get("name", "Ясно")

func get_weather_desc(w: Weather = current_weather) -> String:
	return WEATHER_DATA.get(w, {}).get("desc", "")

func get_weather_info(w: Weather = current_weather) -> Dictionary:
	return WEATHER_DATA.get(w, {})

func get_color_tint(w: Weather = current_weather) -> Color:
	if w == Weather.TWILIGHT_STORM and w == current_weather:
		if twilight_storm_phase == 1:
			return Color(0.65, 0.45, 0.80, 1.0)
		else:
			return Color(0.45, 0.25, 0.65, 1.0)
	return WEATHER_DATA.get(w, {}).get("color_mod", Color.WHITE)

func get_ui_color(w: Weather = current_weather) -> Color:
	if w == Weather.TWILIGHT_STORM and w == current_weather and twilight_storm_phase == 1:
		return Color(0.85, 0.60, 1.0, 1.0)
	return WEATHER_DATA.get(w, {}).get("ui_color", Color.WHITE)

func is_precipitation(w: Weather = current_weather) -> bool:
	if w == Weather.TWILIGHT_STORM and w == current_weather:
		return twilight_storm_phase == 2
	return WEATHER_DATA.get(w, {}).get("precipitation", false)

func is_storm(w: Weather = current_weather) -> bool:
	return w in [Weather.THUNDERSTORM, Weather.TWILIGHT_STORM]

func get_wind_strength(w: Weather = current_weather) -> float:
	return WEATHER_DATA.get(w, {}).get("wind", 0.1)
