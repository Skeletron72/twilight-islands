extends Node

enum TimeOfDay { MORNING, DAY, DUSK, NIGHT }

var current_time: TimeOfDay = TimeOfDay.MORNING
var current_day: int = 1

var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(new_value: float, max_value: float)
signal player_died()
signal player_hurt()

func take_damage(amount: float) -> void:
	if current_health > 0:
		current_health -= amount
		if current_health > 0:
			player_hurt.emit()
		if current_health <= 0:
			current_health = 0
			player_died.emit()
		health_changed.emit(current_health, max_health)

func heal(amount: float) -> void:
	if current_health > 0 and current_health < max_health:
		current_health = min(current_health + amount, max_health)
		health_changed.emit(current_health, max_health)


var max_stamina: float = 100.0
var current_stamina: float = 100.0

signal stamina_changed(new_value: float, max_value: float)

var is_exhausted: bool = false

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount and not is_exhausted:
		current_stamina -= amount
		if current_stamina <= 0.5:
			is_exhausted = true
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func add_stamina(amount: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + amount, max_stamina)
		if is_exhausted and current_stamina >= 15.0:
			is_exhausted = false
		stamina_changed.emit(current_stamina, max_stamina)


signal time_changed(new_time: TimeOfDay)
signal day_changed(new_day: int)

func advance_time() -> void:
	match current_time:
		TimeOfDay.MORNING:
			set_time(TimeOfDay.DAY)
		TimeOfDay.DAY:
			set_time(TimeOfDay.DUSK)
		TimeOfDay.DUSK:
			set_time(TimeOfDay.NIGHT)
		TimeOfDay.NIGHT:
			advance_day()

func set_time(new_time: TimeOfDay) -> void:
	current_time = new_time
	time_changed.emit(current_time)

func advance_day() -> void:
	current_day += 1
	current_time = TimeOfDay.MORNING
	day_changed.emit(current_day)
	time_changed.emit(current_time)

var max_hunger: float = 100.0
var current_hunger: float = 100.0
signal hunger_changed(new_value: float, max_value: float)
signal item_consumed(color: Color)

func add_hunger(amount: float) -> void:
	current_hunger = min(current_hunger + amount, max_hunger)
	hunger_changed.emit(current_hunger, max_hunger)

func _process(delta: float) -> void:
	# Hunger drains over time. 1 in-game day (15 mins?) let's say 1 point every 10 seconds.
	if current_hunger > 0:
		current_hunger -= (0.1 * delta)
		if current_hunger < 0:
			current_hunger = 0
		hunger_changed.emit(current_hunger, max_hunger)
