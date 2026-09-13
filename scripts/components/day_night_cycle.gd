extends CanvasModulate

@export var morning_color: Color = Color(1.04, 0.96, 0.90)
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var dusk_color: Color = Color(0.88, 0.58, 0.48)
@export var night_color: Color = Color(0.20, 0.22, 0.42)
@export var transition_time: float = 2.5

func _ready() -> void:
	GameStateManager.time_changed.connect(_on_time_changed)
	if WeatherManager:
		WeatherManager.weather_changed.connect(func(_w, _info):
			_apply_color_for_time(GameStateManager.current_time, transition_time)
		)
		WeatherManager.twilight_storm_phase_changed.connect(func(_phase):
			_apply_color_for_time(GameStateManager.current_time, 3.5)
		)
	_apply_color_for_time(GameStateManager.current_time, 0.0)

func _on_time_changed(new_time: int) -> void:
	_apply_color_for_time(new_time, transition_time)

func _get_weather_mod() -> Color:
	if not WeatherManager:
		return Color.WHITE
		
	match WeatherManager.current_weather:
		WeatherManager.Weather.CLEAR:
			return Color(1.0, 1.0, 1.0)
		WeatherManager.Weather.CLOUDY:
			return Color(0.92, 0.93, 0.96)
		WeatherManager.Weather.FOG:
			# Солнце уходит, все становится серее
			return Color(0.72, 0.75, 0.80)
		WeatherManager.Weather.OVERCAST:
			# Просто все серое
			return Color(0.66, 0.68, 0.72)
		WeatherManager.Weather.RAIN:
			# Все темно
			return Color(0.48, 0.52, 0.62)
		WeatherManager.Weather.THUNDERSTORM:
			return Color(0.35, 0.38, 0.48)
		WeatherManager.Weather.TWILIGHT_STORM:
			# Фиолетовая пасмурность -> фиолетовая гроза
			if WeatherManager.twilight_storm_phase == 1:
				return Color(0.55, 0.35, 0.72)
			else:
				return Color(0.32, 0.18, 0.45)
	return Color.WHITE

func _apply_color_for_time(time: int, duration: float) -> void:
	var base_color: Color
	match time:
		GameStateManager.TimeOfDay.MORNING:
			base_color = morning_color
		GameStateManager.TimeOfDay.DAY:
			base_color = day_color
		GameStateManager.TimeOfDay.DUSK:
			base_color = dusk_color
		GameStateManager.TimeOfDay.NIGHT:
			base_color = night_color
			
	var target_color = base_color * _get_weather_mod()
	
	if duration <= 0.0:
		color = target_color
	else:
		var tween = create_tween()
		tween.tween_property(self, "color", target_color, duration)
