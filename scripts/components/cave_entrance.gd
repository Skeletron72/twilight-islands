extends StaticBody2D

class_name CaveEntrance

var no_highlight: bool = true

# Interactive cave entrance placed on the island surface.
# Leads into the procedural dungeon / mine floors.

@export_range(1, 4) var cliff_style: int = 1:
	set(val):
		cliff_style = val
		_update_texture()

@onready var sprite: Sprite2D = $EntranceSprite
@onready var interaction_area: Area2D = $InteractionArea
@onready var prompt_label: Label = get_node_or_null("PromptLabel")

var _player_in_range: bool = false
var _prompt_tween: Tween

const CLIFF_TEXTURES = {
	1: preload("res://assets/new_assets/Cute_Fantasy/Tiles/Cliff/Stone_Cliff_1_Cave_Entrance.png"),
	2: preload("res://assets/new_assets/Cute_Fantasy/Tiles/Cliff/Stone_Cliff_2_Cave_Entrance.png"),
	3: preload("res://assets/new_assets/Cute_Fantasy/Tiles/Cliff/Stone_Cliff_3_Cave_Entrance.png"),
	4: preload("res://assets/new_assets/Cute_Fantasy/Tiles/Cliff/Stone_Cliff_4_Cave_Entrance.png")
}

func _ready() -> void:
	if not is_in_group("interactable"):
		add_to_group("interactable")
	_update_texture()
	_setup_prompt_label()
	
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)

func _update_texture() -> void:
	if not is_inside_tree() or not sprite:
		return
	if CLIFF_TEXTURES.has(cliff_style):
		sprite.texture = CLIFF_TEXTURES[cliff_style]

func _setup_prompt_label() -> void:
	if not prompt_label:
		prompt_label = Label.new()
		prompt_label.name = "PromptLabel"
		prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		prompt_label.position = Vector2(-60, 6)
		prompt_label.custom_minimum_size = Vector2(120, 16)
		prompt_label.z_index = 100
		prompt_label.text = "[E] Войти в пещеру"
		prompt_label.modulate.a = 0.0
		
		var font = load("res://assets/fonts/Chalkboard.ttf")
		if font:
			prompt_label.add_theme_font_override("font", font)
		prompt_label.add_theme_font_size_override("font_size", 9)
		prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
		prompt_label.add_theme_constant_override("outline_size", 3)
		add_child(prompt_label)

var _player_ref: Node2D = null

func _unhandled_input(event: InputEvent) -> void:
	if _player_in_range and event.is_action_pressed("interact"):
		var p = _player_ref
		if not p:
			p = get_tree().get_first_node_in_group("player")
		interact(p)
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
	if player == null:
		player = _player_ref
	if player == null:
		player = get_tree().get_first_node_in_group("player")
	DungeonManager.enter_dungeon(self, player)
