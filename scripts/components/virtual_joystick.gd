extends Control

@export var max_distance: float = 50.0

@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Base/Knob

var touch_id: int = -1
var output_vector: Vector2 = Vector2.ZERO
var base_default_pos: Vector2

func _ready() -> void:
	base_default_pos = base.position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and touch_id == -1:
			var rect = Rect2(global_position, size)
			if rect.has_point(event.position):
				touch_id = event.index
				base.global_position = event.position - base.size / 2.0
		elif not event.pressed and event.index == touch_id:
			_reset_joystick()
			
	elif event is InputEventScreenDrag:
		if event.index == touch_id:
			var center = base.global_position + base.size / 2.0
			var diff = event.position - center
			
			if diff.length() > max_distance:
				diff = diff.normalized() * max_distance
				
			knob.position = (base.size / 2.0) - (knob.size / 2.0) + diff
			output_vector = diff / max_distance
			
			# Simulate Input events for keyboard fallback/uniformity
			_simulate_action("move_right", output_vector.x > 0.5)
			_simulate_action("move_left", output_vector.x < -0.5)
			_simulate_action("move_up", output_vector.y < -0.5)
			_simulate_action("move_down", output_vector.y > 0.5)

func _reset_joystick() -> void:
	touch_id = -1
	output_vector = Vector2.ZERO
	base.position = base_default_pos
	knob.position = (base.size / 2.0) - (knob.size / 2.0)
	
	_simulate_action("move_right", false)
	_simulate_action("move_left", false)
	_simulate_action("move_up", false)
	_simulate_action("move_down", false)

func _simulate_action(action: String, pressed: bool) -> void:
	if pressed and not Input.is_action_pressed(action):
		var ev = InputEventAction.new()
		ev.action = action
		ev.pressed = true
		Input.parse_input_event(ev)
	elif not pressed and Input.is_action_pressed(action):
		var ev = InputEventAction.new()
		ev.action = action
		ev.pressed = false
		Input.parse_input_event(ev)
