extends Area2D
class_name DroppedItem

var item_id: String = ""
var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D

# State
var is_in_air: bool = false
var pickup_delay: float = 0.5
var _is_pickup_ready: bool = false
var _is_collecting: bool = false
var _is_collected: bool = false
var _target_player: Node2D = null
var _suction_speed: float = 0.0

# Visual
var _float_timer: float = 0.0
var _shadow_radius: float = 7.0
var _shadow_alpha: float = 0.28

func setup(id: String, count: int, delay: float = -1.0) -> void:
	item_id = id
	amount = count
	if delay > 0.0:
		pickup_delay = delay

func _ready() -> void:
	body_entered.connect(_on_body_entered)

	if item_id != "":
		sprite.texture = ItemDB.get_icon(item_id)

	# Randomize bob phase so nearby items don't all pulse together
	_float_timer = randf_range(0.0, TAU)

	# Start invisible, tiny
	modulate.a = 0.0
	scale = Vector2(0.1, 0.1)

	# ---- Spawn arc: small hop like Stardew ----
	var hop_x   = randf_range(-20.0, 20.0)
	var hop_y   = randf_range(4.0, 16.0)
	var land_pos = position + Vector2(hop_x, hop_y)
	var arc_h   = randf_range(14.0, 22.0)

	var tw = create_tween().set_parallel(true)

	# Horizontal glide to landing spot
	tw.tween_property(self, "position", land_pos, 0.28)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Fade in immediately
	tw.tween_property(self, "modulate:a", 1.0, 0.06)

	# Scale pop: 0.1 → 0.85 → 0.65
	tw.tween_property(self, "scale", Vector2(0.85, 0.85), 0.12)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(self, "scale", Vector2(0.65, 0.65), 0.10)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Arc on sprite only
	tw.tween_property(sprite, "position:y", -arc_h, 0.13)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.chain().tween_property(sprite, "position:y", 0.0, 0.15)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	# Squish on land
	tw.chain().tween_property(self, "scale", Vector2(0.72, 0.52), 0.05)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.chain().tween_property(self, "scale", Vector2(0.65, 0.65), 0.09)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

	# Small tilt on launch
	sprite.rotation = randf_range(-0.3, 0.3)
	var rot_tw = create_tween()
	rot_tw.tween_property(sprite, "rotation", 0.0, 0.22)\
		.set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)

	# Pickup enabled after landing
	await get_tree().create_timer(pickup_delay).timeout
	if not is_inside_tree() or _is_collected: return
	_is_pickup_ready = true
	# Check if player is already standing here
	_check_overlap_now()

func _check_overlap_now() -> void:
	if not _is_pickup_ready or _is_collected: return
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			_start_collect(body)
			return

func _on_body_entered(body: Node2D) -> void:
	if _is_collecting or _is_collected or not _is_pickup_ready: return
	if body.is_in_group("player"):
		_start_collect(body)

func _start_collect(player: Node2D) -> void:
	if _is_collecting or _is_collected or not _is_pickup_ready: return
	_is_collecting  = true
	_target_player  = player
	_suction_speed  = 80.0

	sprite.position.y = 0.0

	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(0.80, 0.80), 0.05)\
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _process(delta: float) -> void:
	if _is_collected: return
	if _is_collecting:
		_process_collect(delta)
	else:
		_process_idle(delta)

func _process_idle(delta: float) -> void:
	_float_timer += delta * 2.6
	var hover = sin(_float_timer) * 2.5
	sprite.position.y = hover
	_shadow_radius = 7.0 - abs(hover) * 0.3
	_shadow_alpha  = 0.28 - abs(hover) * 0.01
	queue_redraw()

func _process_collect(delta: float) -> void:
	if _is_collected: return
	if not is_instance_valid(_target_player):
		_is_collecting = false
		return

	var dist = global_position.distance_to(_target_player.global_position)

	# Aggressive ramp — feels like Stardew
	_suction_speed = move_toward(_suction_speed, 900.0, delta * 2200.0)

	var dir = (_target_player.global_position - global_position).normalized()
	global_position += dir * _suction_speed * delta

	scale = scale.move_toward(Vector2(0.2, 0.2), delta * 3.5)

	if dist < 8.0:
		_collected()

func _collected() -> void:
	if _is_collected:
		return
	_is_collected = true
	set_process(false)
	monitoring = false
	monitorable = false

	if AudioManager:
		AudioManager.play_sfx(
			preload("res://assets/audio/ui/sfx_pop.mp3"),
			randf_range(1.0, 1.25), -1.5
		)

	InventoryManager.add_item(item_id, amount)
	if GameStateManager.has_method("register_item_gathered"):
		GameStateManager.register_item_gathered(amount)

	var tw = create_tween().set_parallel(true)
	tw.tween_property(self, "scale", Vector2(0.0, 0.0), 0.07)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.tween_property(self, "modulate:a", 0.0, 0.07)
	tw.chain().tween_callback(queue_free)

func _draw() -> void:
	if _is_collecting: return
	draw_set_transform(Vector2(0, 7), 0.0, Vector2(1.0, 0.22))
	draw_circle(Vector2.ZERO, _shadow_radius, Color(0.0, 0.0, 0.0, _shadow_alpha))

