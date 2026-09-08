extends CPUParticles2D

func setup(item_id: String, p_color: Color) -> void:
	var icon = ItemDB.get_icon(item_id)
	if icon:
		texture = icon
		scale_amount_min = 0.2
		scale_amount_max = 0.35
		color = Color.WHITE
	else:
		color = p_color
		scale_amount_min = 1.0
		scale_amount_max = 2.0
	
	# Scale down smoothly before disappearing
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.6, 1))
	curve.add_point(Vector2(1, 0))
	scale_amount_curve = curve

func _ready() -> void:
	emitting = true
	var timer = get_tree().create_timer(lifetime + 0.2)
	timer.timeout.connect(queue_free)
