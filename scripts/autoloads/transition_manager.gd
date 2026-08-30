extends CanvasLayer

var target_path: String = ""
var message: String = ""

@onready var color_rect: ColorRect = ColorRect.new()
@onready var label: Label = Label.new()

var is_transitioning: bool = false

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

func transition_to(scene_path: String, text: String = "Loading...") -> void:
	if is_transitioning: return
	is_transitioning = true
	
	target_path = scene_path
	message = text
	label.text = message
	color_rect.show()
	
	# Disable player processing during transition
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(_load_scene)

func _load_scene() -> void:
	# Small delay to let the user read the text
	await get_tree().create_timer(1.0).timeout
	var err = get_tree().change_scene_to_file(target_path)
	if err != OK:
		print("ERROR loading scene: ", target_path, " code: ", err)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func():
		color_rect.hide()
		is_transitioning = false
		var player = get_tree().get_first_node_in_group("player")
		if player:
			player.set_physics_process(true)
	)
