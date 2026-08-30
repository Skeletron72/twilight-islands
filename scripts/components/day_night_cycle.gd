extends CanvasModulate

@export var morning_color: Color = Color(1.0, 1.0, 1.0)
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var dusk_color: Color = Color(0.7, 0.5, 0.5)
@export var night_color: Color = Color(0.2, 0.2, 0.4)
@export var transition_time: float = 2.0

func _ready() -> void:
	GameStateManager.time_changed.connect(_on_time_changed)
	_apply_color_for_time(GameStateManager.current_time, 0.0)

func _on_time_changed(new_time: int) -> void:
	_apply_color_for_time(new_time, transition_time)

func _apply_color_for_time(time: int, duration: float) -> void:
	var target_color: Color
	match time:
		GameStateManager.TimeOfDay.MORNING:
			target_color = morning_color
		GameStateManager.TimeOfDay.DAY:
			target_color = day_color
		GameStateManager.TimeOfDay.DUSK:
			target_color = dusk_color
		GameStateManager.TimeOfDay.NIGHT:
			target_color = night_color
			
	if duration <= 0.0:
		color = target_color
	else:
		var tween = create_tween()
		tween.tween_property(self, "color", target_color, duration)
