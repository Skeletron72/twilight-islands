extends CanvasLayer

var target_path: String = ""
var message: String = ""

@onready var color_rect: ColorRect = ColorRect.new()
@onready var label: Label = Label.new()

var is_transitioning: bool = false

var iris_rect: ColorRect = null
var iris_mat: ShaderMaterial = null

func _ready() -> void:
	layer = 100 # On top of everything
	
	color_rect.color = Color.BLACK
	color_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	color_rect.modulate.a = 0.0 # Start invisible
	add_child(color_rect)
	
	# Set label to also be FULL_RECT so the text can center properly without clipping
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	color_rect.add_child(label)
	
	color_rect.hide()
	_ensure_iris_setup()

func _ensure_iris_setup() -> void:
	if iris_rect: return
	iris_rect = ColorRect.new()
	iris_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	iris_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	iris_mat = ShaderMaterial.new()
	iris_mat.shader = load("res://shaders/iris_transition.gdshader")
	iris_mat.set_shader_parameter("progress", 0.0)
	iris_rect.material = iris_mat
	add_child(iris_rect)
	iris_rect.hide()

func transition_to(scene_path: String, text: String = "Loading...") -> void:
	if is_transitioning: return
	is_transitioning = true
	
	target_path = scene_path
	message = text
	label.text = message
	color_rect.show()
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector2.ZERO
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	tween.tween_callback(_load_scene)

func _load_scene() -> void:
	await get_tree().create_timer(0.4).timeout
	var err = get_tree().change_scene_to_file(target_path)
	if err != OK:
		print("ERROR loading scene: ", target_path, " code: ", err)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.4)
	tween.tween_callback(func():
		color_rect.hide()
		is_transitioning = false
	)

# Специальный кинематографичный переход палатки:
# Мир НЕ ставится на паузу, все процессы и анимации продолжают жить в реальном времени!
func play_iris_transition(on_covered_callback: Callable, duration: float = 0.38) -> void:
	if is_transitioning: return
	is_transitioning = true
	
	_ensure_iris_setup()
	iris_rect.show()
	iris_mat.set_shader_parameter("progress", 0.0)
	
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.velocity = Vector2.ZERO
		
	# 1. Сужение в круг и затемнение экрана (0.0 -> 1.0)
	var tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	tween.tween_method(func(val: float):
		iris_mat.set_shader_parameter("progress", val)
	, 0.0, 1.0, duration)
	
	# 2. Мгновенная смена позиции в момент пика темноты
	tween.tween_callback(func():
		if on_covered_callback.is_valid():
			on_covered_callback.call()
	)
	
	# Микро-пауза (0.06 сек)
	tween.tween_interval(0.06)
	
	# 3. Обратный эффект — круг расширяется и экран осветляется (1.0 -> 0.0)
	tween.tween_method(func(val: float):
		iris_mat.set_shader_parameter("progress", val)
	, 1.0, 0.0, duration)
	
	# 4. Завершение перехода
	tween.tween_callback(func():
		iris_rect.hide()
		is_transitioning = false
	)
