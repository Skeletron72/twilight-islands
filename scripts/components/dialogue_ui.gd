extends Control
class_name DialogueUI

## DialogueUI
## Диалоговый оверлей с портретом, печатной машинкой текста, выборами и поддержкой катсцен.

@onready var letterbox_top: ColorRect = $LetterboxTop
@onready var letterbox_bottom: ColorRect = $LetterboxBottom
@onready var dialogue_box: Control = $DialogueBox
@onready var speaker_label: Label = $DialogueBox/ContentMargin/HBoxContainer/TextVBox/SpeakerLabel
@onready var text_label: RichTextLabel = $DialogueBox/ContentMargin/HBoxContainer/TextVBox/TextLabel
@onready var portrait_rect: TextureRect = $DialogueBox/ContentMargin/HBoxContainer/PortraitFrame/PortraitRect
@onready var choices_container: VBoxContainer = $ChoicesContainer
@onready var continue_prompt: Label = $DialogueBox/ContinuePrompt

@export_group("Customization")
@export var chars_per_second: float = 45.0
@export var choice_button_min_height: float = 24.0
@export var choice_button_min_width: float = 260.0
@export var choice_font_size: int = 10
@export var choice_sound: AudioStream = preload("res://assets/audio/ui/tap.mp3")
@export var click_sound: AudioStream = preload("res://assets/audio/ui/sfx_ui_button.mp3")

const FONT_WARM = preload("res://assets/fonts/WarmPixel.ttf")

var _current_full_text: String = ""
var _is_typing: bool = false
var _typewriter_tween: Tween = null
var _has_choices: bool = false

func _ready() -> void:
	visible = false
	modulate.a = 0.0
	
	if letterbox_top:
		letterbox_top.custom_minimum_size.y = 0
	if letterbox_bottom:
		letterbox_bottom.custom_minimum_size.y = 0
		
	if DialogueManager:
		DialogueManager.dialogue_started.connect(_on_dialogue_started)
		DialogueManager.dialogue_line_displayed.connect(_on_dialogue_line_displayed)
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		DialogueManager.cutscene_started.connect(_on_cutscene_started)
		DialogueManager.cutscene_ended.connect(_on_cutscene_ended)

func _input(event: InputEvent) -> void:
	if not visible:
		return
		
	if event.is_action_pressed("interact") or (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE) or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		# If choices are presented, don't auto-advance with mouse click outside buttons
		if _is_typing:
			# Complete typewriter instantly
			_complete_typing()
			get_viewport().set_input_as_handled()
		elif not _has_choices:
			DialogueManager.advance_dialogue()
			get_viewport().set_input_as_handled()

func _on_dialogue_started(_speaker: String) -> void:
	visible = true
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 1.0, 0.2)
	
	# Disable player action while talking
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.is_acting = true
		player.velocity = Vector2.ZERO

func _on_dialogue_line_displayed(line_info: Dictionary) -> void:
	speaker_label.text = line_info.get("speaker", "")
	_current_full_text = line_info.get("text", "")
	
	var portrait = line_info.get("portrait")
	if portrait:
		portrait_rect.texture = portrait
		portrait_rect.visible = true
	else:
		portrait_rect.visible = false
		
	_clear_choices()
	
	var choices: Array = line_info.get("choices", [])
	_has_choices = not choices.is_empty()
	if continue_prompt:
		continue_prompt.visible = not _has_choices
	
	# Start typewriter effect
	_start_typing(_current_full_text, choices)

func _start_typing(text: String, choices: Array) -> void:
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
		
	text_label.bbcode_enabled = true
	text_label.text = text
	text_label.visible_characters = 0
	_is_typing = true
	
	var char_count = text_label.get_total_character_count()
	var duration = max(0.15, char_count / max(1.0, chars_per_second))
	
	_typewriter_tween = create_tween()
	_typewriter_tween.tween_property(text_label, "visible_characters", char_count, duration)
	_typewriter_tween.tween_callback(func():
		_is_typing = false
		_display_choices(choices)
	)

func _complete_typing() -> void:
	if _typewriter_tween and _typewriter_tween.is_valid():
		_typewriter_tween.kill()
	text_label.visible_characters = -1
	_is_typing = false
	
	# If choices exist for current node, show them immediately
	var current_node = DialogueManager.current_dialogue.get(DialogueManager.current_node_id, {})
	var choices = current_node.get("choices", [])
	_display_choices(choices)

func _clear_choices() -> void:
	if not choices_container:
		return
	for child in choices_container.get_children():
		child.queue_free()

func _display_choices(choices: Array) -> void:
	_clear_choices()
	if choices.is_empty() or not choices_container:
		return
		
	for i in range(choices.size()):
		var choice = choices[i]
		var btn = Button.new()
		btn.text = choice.get("text", "...")
		btn.add_theme_font_override("font", FONT_WARM)
		btn.add_theme_font_size_override("font_size", choice_font_size)
		btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		btn.custom_minimum_size = Vector2(choice_button_min_width, choice_button_min_height)
		
		# Condition check (string condition, Callable, or bool)
		var is_enabled = true
		if choice.has("condition"):
			is_enabled = DialogueManager.evaluate_condition(choice["condition"])
			
		btn.disabled = not is_enabled
		if not is_enabled:
			btn.modulate = Color(0.7, 0.7, 0.7, 0.6)
			
		var choice_idx = i
		btn.pressed.connect(func():
			if AudioManager and click_sound:
				AudioManager.play_sfx(click_sound)
			DialogueManager.select_choice(choice_idx)
		)
		btn.mouse_entered.connect(func():
			if AudioManager and choice_sound:
				AudioManager.play_sfx(choice_sound)
		)
		choices_container.add_child(btn)

func _on_dialogue_ended(_speaker: String) -> void:
	_has_choices = false
	_clear_choices()
	var tw = create_tween()
	tw.tween_property(self, "modulate:a", 0.0, 0.2)
	tw.tween_callback(func():
		visible = false
		var player = get_tree().get_first_node_in_group("player")
		if player and not DialogueManager.is_in_cutscene:
			player.is_acting = false
	)

func _on_cutscene_started() -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_property(letterbox_top, "custom_minimum_size:y", 28.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(letterbox_bottom, "custom_minimum_size:y", 28.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func _on_cutscene_ended() -> void:
	var tw = create_tween().set_parallel(true)
	tw.tween_property(letterbox_top, "custom_minimum_size:y", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	tw.tween_property(letterbox_bottom, "custom_minimum_size:y", 0.0, 0.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	var player = get_tree().get_first_node_in_group("player")
	if player and not DialogueManager.is_in_dialogue:
		player.is_acting = false
