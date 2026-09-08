extends Node2D
class_name Firefly

# Пиксельный светлячок с плавным медитативным парением и идеально симметричным пиксельным светом.

@export var base_speed: float = 11.0
@export var flee_distance: float = 24.0

var velocity: Vector2 = Vector2.ZERO
var _wander_angle: float = 0.0
var _target_speed: float = 11.0

var _time_alive: float = 0.0
var _pulse_freq: float = 1.0
var _blink_phase: float = 0.0

var glow_intensity: float = 0.0
var _target_alpha: float = 1.0
var _is_fading_out: bool = false
var _cur_glow: float = 0.0

@onready var point_light: PointLight2D = $PointLight2D

func _ready() -> void:
	z_index = 6
	_wander_angle = randf() * TAU
	_blink_phase = randf() * TAU
	_pulse_freq = randf_range(0.7, 1.1) # Медленное дыхание (~6 сек цикл)
	_target_speed = randf_range(base_speed * 0.75, base_speed * 1.25)
	
	if point_light:
		point_light.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Очень мягкое плавное появление без вспышек
	glow_intensity = 0.0
	var tween = create_tween()
	tween.tween_property(self, "glow_intensity", 1.0, randf_range(2.0, 3.5)).set_trans(Tween.TRANS_SINE)

func _process(delta: float) -> void:
	_time_alive += delta
	
	# Плавное «дыхание» света вместо резкого мигания
	var raw_sine = (sin(_time_alive * _pulse_freq + _blink_phase) + 1.0) * 0.5
	var pulse = pow(raw_sine, 1.5)
	
	_cur_glow = lerp(0.12, 0.85, pulse) * glow_intensity * _target_alpha
	
	if point_light:
		point_light.energy = _cur_glow * 0.22
		point_light.enabled = _cur_glow > 0.02
		
	queue_redraw()

func _physics_process(delta: float) -> void:
	# Непрерывное плавное подруливание угла полета
	_wander_angle += randf_range(-1.0, 1.0) * delta
	var target_vel = Vector2(cos(_wander_angle), sin(_wander_angle)) * _target_speed
	
	# Мягкое избегание игрока при сближении
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var to_player = global_position - player.global_position
		var dist = to_player.length()
		if dist < flee_distance and dist > 0.5:
			var flee_dir = to_player.normalized()
			target_vel = target_vel.lerp(flee_dir * (base_speed * 1.5), 0.5)
			
	# Плавная инерция движения
	velocity = velocity.lerp(target_vel, delta * 1.2)
	
	# Очень нежное покачивание в воздухе
	var hover = Vector2(0.0, sin(_time_alive * 1.2 + _blink_phase) * 2.0 * delta)
	global_position += (velocity * delta) + hover

func _draw() -> void:
	var alpha = _cur_glow
	if alpha <= 0.02: return
	
	# Аккуратная пиксельная точка с нежным ореолом
	var halo_col = Color(0.82, 0.98, 0.38, alpha * 0.35)
	draw_rect(Rect2(-2.0, -1.0, 1.0, 2.0), halo_col)
	draw_rect(Rect2(1.0, -1.0, 1.0, 2.0), halo_col)
	draw_rect(Rect2(-1.0, -2.0, 2.0, 1.0), halo_col)
	draw_rect(Rect2(-1.0, 1.0, 2.0, 1.0), halo_col)
	
	# Тельце 2x2 (тёплое светлое)
	var body_col = Color(0.92, 1.0, 0.65, alpha * 0.85)
	draw_rect(Rect2(-1.0, -1.0, 2.0, 2.0), body_col)
	
	# Центральная яркая искорка (1x1)
	var core_col = Color(1.0, 1.0, 0.95, alpha)
	draw_rect(Rect2(-0.5, -0.5, 1.0, 1.0), core_col)

func fade_out_and_free(duration: float = 2.5) -> void:
	if _is_fading_out: return
	_is_fading_out = true
	var tween = create_tween()
	tween.tween_property(self, "_target_alpha", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(queue_free)
