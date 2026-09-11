extends Area2D

class_name LadderDown

var no_highlight: bool = true

# Ladder leading down to the next floor in the mine/dungeon.

@onready var prompt_label: Label = get_node_or_null("PromptLabel")
var _prompt_tween: Tween

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")
	collision_layer = 2
	collision_mask = 1
	_setup_prompt_label()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _setup_prompt_label() -> void:
	if not prompt_label:
		prompt_label = Label.new()
		prompt_label.name = "PromptLabel"
		prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		prompt_label.position = Vector2(-75, -28)
		prompt_label.custom_minimum_size = Vector2(150, 16)
		_update_prompt_text()
		prompt_label.modulate.a = 0.0
		
		var font = load("res://assets/fonts/Chalkboard.ttf")
		if font:
			prompt_label.add_theme_font_override("font", font)
		prompt_label.add_theme_font_size_override("font_size", 9)
		prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
		prompt_label.add_theme_constant_override("outline_size", 3)
		add_child(prompt_label)

func _update_prompt_text() -> void:
	if not prompt_label: return
	prompt_label.text = "[E] Спуститься на этаж %d" % (DungeonManager.current_floor + 1)

var _player_in_range: bool = false

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		interact()
		get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = true
		_update_prompt_text()
		_fade_prompt(1.0)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = false
		_fade_prompt(0.0)

func _fade_prompt(target_alpha: float) -> void:
	if not prompt_label: return
	if _prompt_tween and _prompt_tween.is_valid():
		_prompt_tween.kill()
	_prompt_tween = create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_prompt_tween.tween_property(prompt_label, "modulate:a", target_alpha, 0.2)

func interact(player: Node2D = null) -> void:
	DungeonManager.next_floor()
