extends TouchScreenButton

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	var ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	Input.parse_input_event(ev)
	
	# Release immediately for a tap
	await get_tree().process_frame
	var rev = InputEventAction.new()
	rev.action = "interact"
	rev.pressed = false
	Input.parse_input_event(rev)
