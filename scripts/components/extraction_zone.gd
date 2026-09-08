extends Interactable
class_name ExtractionZone

@export_file("*.tscn") var target_scene: String
@export var is_raid_start: bool = false

var anim_timer: float = 0.0
var fps: float = 6.0
var float_time: float = 0.0

var prompt_label: Label = null
var is_home: bool = false

func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	# Determine if this boat is on HomeIsland or RaidIsland
	var cur_scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	is_home = (cur_scene_name == "HomeIsland" or is_raid_start or cur_scene_name == "")
	
	if target_scene == "":
		if is_home:
			target_scene = "res://scenes/levels/raid_island.tscn"
			is_raid_start = true
		else:
			target_scene = "res://scenes/levels/home_island.tscn"
			is_raid_start = false

	_create_floating_label()
	_update_visuals()

	if GameStateManager.has_signal("boat_upgraded"):
		GameStateManager.boat_upgraded.connect(_on_boat_upgraded)

func _create_floating_label() -> void:
	prompt_label = Label.new()
	prompt_label.name = "PromptLabel"
	prompt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	prompt_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	prompt_label.position = Vector2(-75, -34)
	prompt_label.custom_minimum_size = Vector2(150, 20)
	
	# Load font
	var font = load("res://assets/fonts/Chalkboard.ttf")
	if font:
		prompt_label.add_theme_font_override("font", font)
	prompt_label.add_theme_font_size_override("font_size", 9)
	prompt_label.add_theme_color_override("font_outline_color", Color.BLACK)
	prompt_label.add_theme_constant_override("outline_size", 3)
	
	add_child(prompt_label)

func _update_visuals() -> void:
	if is_home:
		var level = GameStateManager.boat_level
		if level == 0:
			# Broken boat: tilted, weathered dark modulate
			rotation_degrees = -5.5
			self.modulate = Color(0.68, 0.62, 0.55, 0.95)
			if prompt_label:
				prompt_label.text = "🔨 [E] Остов лодки (Сломана)"
				prompt_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.45))
		else:
			# Repaired boat
			rotation_degrees = 0.0
			self.modulate = Color.WHITE
			var tier = GameStateManager.get_current_boat_tier()
			var tier_name = tier.get("name", "Лодка")
			if prompt_label:
				prompt_label.text = "⛵ [E] %s (Ур. %d)" % [tier_name, level]
				prompt_label.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	else:
		# Raid island: extraction boat
		rotation_degrees = 0.0
		self.modulate = Color.WHITE
		if prompt_label:
			prompt_label.text = "⛵ [E] Эвакуация домой"
			prompt_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))

func _on_boat_upgraded(_new_level: int) -> void:
	_update_visuals()
	_play_repair_particles()

func _play_repair_particles() -> void:
	# Subtle pop animation
	var tw = create_tween()
	tw.tween_property(self, "scale", Vector2(1.15, 1.15), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)

func interact(player: Node2D) -> void:
	if is_home:
		# Open Boat UI
		var boat_ui = get_tree().current_scene.get_node_or_null("UILayer/BoatUI")
		if boat_ui:
			boat_ui.open(self)
		else:
			# Fallback if BoatUI node not directly found under UILayer
			var ui_layer = get_tree().get_first_node_in_group("ui_layer")
			if ui_layer and ui_layer.has_node("BoatUI"):
				ui_layer.get_node("BoatUI").open(self)
			else:
				# Direct sail if boat is already repaired
				if GameStateManager.boat_level >= 1:
					start_departure()
				else:
					print("Boat is broken! Repair it first.")
	else:
		# Raid Island -> Extract home
		extract()

func start_departure() -> void:
	if GameStateManager.boat_level <= 0:
		print("Cannot depart with broken boat!")
		return
	InventoryManager.set_mode(InventoryManager.Mode.RAID)
	print("Starting Raid with boat level: ", GameStateManager.boat_level)
	TransitionManager.transition_to(target_scene, "Отплываем в экспедицию...")

func extract() -> void:
	InventoryManager.commit_temp_inventory()
	InventoryManager.set_mode(InventoryManager.Mode.SAFE)
	print("Extracted Successfully! Loot saved.")
	TransitionManager.transition_to(target_scene, "Возвращаемся домой...")

func _process(delta: float) -> void:
	# Water bobbing sprite animation
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer = 0.0
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.frame = (sprite.frame + 1) % sprite.hframes

	# Floating prompt gentle sine wave
	if prompt_label:
		float_time += delta * 2.5
		prompt_label.position.y = -34.0 + sin(float_time) * 2.5
		prompt_label.rotation = -rotation
