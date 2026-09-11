extends StaticBody2D
class_name CaveDoorway

# Interactive cave doorway exit on Floor 1, leading back to the surface.
# Matches the architecture and collision behavior of CaveEntrance.

var no_highlight: bool = true

@onready var interaction_area: Area2D = $InteractionArea
@onready var doorway_light: PointLight2D = get_node_or_null("DoorwayLight")
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

var _player_in_range: bool = false
var _prompt_tween: Tween
var _light_tween: Tween
var _player_ref: Node2D = null

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")
	_setup_prompt_label()
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
		
	if GameStateManager:
		GameStateManager.time_changed.connect(_on_time_changed)
		_update_light_for_time(GameStateManager.current_time, false)

func _on_time_changed(new_time) -> void:
	_update_light_for_time(new_time, true)

func _update_light_for_time(tod, animated: bool = false) -> void:
	if not doorway_light:
		return
		
	var target_color: Color = Color(1.0, 0.95, 0.88)
	var target_energy: float = 1.3
	
	if GameStateManager:
		match tod:
			GameStateManager.TimeOfDay.MORNING:
				target_color = Color(1.0, 0.88, 0.72)
				target_energy = 1.1
			GameStateManager.TimeOfDay.DAY:
				target_color = Color(1.0, 0.98, 0.90)
				target_energy = 1.5
			GameStateManager.TimeOfDay.DUSK:
				target_color = Color(1.0, 0.55, 0.25)
				target_energy = 0.95
			GameStateManager.TimeOfDay.NIGHT:
				target_color = Color(0.35, 0.45, 0.85)
				target_energy = 0.4
			
	if animated and is_inside_tree():
		if _light_tween and _light_tween.is_valid():
			_light_tween.kill()
		_light_tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_light_tween.tween_property(doorway_light, "color", target_color, 2.0)
		_light_tween.tween_property(doorway_light, "energy", target_energy, 2.0)
	else:
		doorway_light.color = target_color
		doorway_light.energy = target_energy

func _setup_prompt_label() -> void:
	if not prompt_label:
		prompt_label = Label.new()
		prompt_label.name = "PromptLabel"
		prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		prompt_label.position = Vector2(-75, -54)
		prompt_label.custom_minimum_size = Vector2(150, 16)
		prompt_label.z_index = 100
		prompt_label.text = "[E] Выйти на поверхность"
		prompt_label.modulate.a = 0.0
		
		var font = load("res://assets/fonts/Chalkboard.ttf")
		if font:
			prompt_label.add_theme_font_override("font", font)
		prompt_label.add_theme_font_size_override("font_size", 9)
		prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
		prompt_label.add_theme_constant_override("outline_size", 3)
		add_child(prompt_label)

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		interact()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_player_ref = body
		_fade_prompt(1.0)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		if _player_ref == body:
			_player_ref = null
		_fade_prompt(0.0)

func _fade_prompt(target_alpha: float) -> void:
	if not prompt_label: return
	if _prompt_tween and _prompt_tween.is_valid():
		_prompt_tween.kill()
	_prompt_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_prompt_tween.tween_property(prompt_label, "modulate:a", target_alpha, 0.2)

func interact(player: Node2D = null) -> void:
	if DungeonManager:
		DungeonManager.exit_to_surface()
