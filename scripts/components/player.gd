extends CharacterBody2D
class_name Player

@export var speed: float = 40.0
@export var hairstyle_index: int = 0 # 0 to 5 for different hairs

@onready var visuals: Node2D = $Visuals
@onready var interaction_area: Area2D = $InteractionArea

var current_target: Node2D = null
var hp_bar: ProgressBar
var stamina_bar: ProgressBar
var hunger_bar: ProgressBar
var hunger_wrapper: Control
var is_acting: bool = false
var is_dead: bool = false

# Animation State
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 10.0

# Define paperdoll layers
const LAYERS = ["base", "boots", "cloth", "hair", "tools"]

var anim_data = {
	"idle": {
		"frames": 9,
		"base": preload("res://assets/sprites/characters/Human/IDLE/base_idle_strip9.png"),
		"boots": preload("res://assets/sprites/characters/Human/IDLE/boots1_idle_strip9.png"),
		"cloth": preload("res://assets/sprites/characters/Human/IDLE/cloth1_idle_strip9.png"),
		"hair": preload("res://assets/sprites/characters/Human/IDLE/hair_merged_idle_strip9.png"),
		"tools": preload("res://assets/sprites/characters/Human/IDLE/tools_idle_strip9.png")
	},
	"run": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/RUN/base_run_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/RUN/boots1_run_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/RUN/cloth1_run_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/RUN/hair_merged_run_strip8.png"),
		"tools": preload("res://assets/sprites/characters/Human/RUN/tools_run_strip8.png")
	},
	"walk": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/WALK/base_walk_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/WALK/boots1_walk_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/WALK/cloth1_walk_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/WALK/hair_merged_walk_strip8.png"),
		"tools": preload("res://assets/sprites/characters/Human/WALK/tools_walk_strip8.png")
	},
	"swimming": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/SWIMMING/base_swimming_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/SWIMMING/boots1_swimming_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/SWIMMING/cloth1_swimming_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/SWIMMING/hair_merged_swimming_strip8.png"),
		"tools": preload("res://assets/sprites/characters/Human/SWIMMING/tools_swimming_strip8.png")
	},

			"death": {
		"frames": 13,
		"base": preload("res://assets/sprites/characters/Human/DEATH/base_death_strip13.png"),
		"boots": preload("res://assets/sprites/characters/Human/DEATH/boots1_death_strip13.png"),
		"cloth": preload("res://assets/sprites/characters/Human/DEATH/cloth1_death_strip13.png"),
		"hair": preload("res://assets/sprites/characters/Human/DEATH/hair_merged_death_strip13.png"),
		"tools": preload("res://assets/sprites/characters/Human/DEATH/tools_death_strip13.png")
	},
	"attack": {
		"frames": 10,
		"base": preload("res://assets/sprites/characters/Human/ATTACK/base_attack_strip10.png"),
		"boots": preload("res://assets/sprites/characters/Human/ATTACK/boots1_attack_strip10.png"),
		"cloth": preload("res://assets/sprites/characters/Human/ATTACK/cloth1_attack_strip10.png"),
		"hair": preload("res://assets/sprites/characters/Human/ATTACK/hair_merged_attack_strip10.png"),
		"tools": preload("res://assets/sprites/characters/Human/ATTACK/tools_attack_strip10.png")
	},
	"hurt": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/HURT/base_hurt_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/HURT/boots1_hurt_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/HURT/cloth1_hurt_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/HURT/hair_merged_hurt_strip8.png"),
		"tools": preload("res://assets/sprites/characters/Human/HURT/tools_hurt_strip8.png")
	},
	"axe": {
		"frames": 10,
		"base": preload("res://assets/sprites/characters/Human/AXE/base_axe_strip10.png"),
		"boots": preload("res://assets/sprites/characters/Human/AXE/boots1_axe_strip10.png"),
		"cloth": preload("res://assets/sprites/characters/Human/AXE/cloth1_axe_strip10.png"),
		"hair": preload("res://assets/sprites/characters/Human/AXE/hair_merged_axe_strip10.png"),
		"tools": preload("res://assets/sprites/characters/Human/AXE/tools_axe_strip10.png")
	},
	"mining": {
		"frames": 10,
		"base": preload("res://assets/sprites/characters/Human/MINING/base_mining_strip10.png"),
		"boots": preload("res://assets/sprites/characters/Human/MINING/boots1_mining_strip10.png"),
		"cloth": preload("res://assets/sprites/characters/Human/MINING/cloth1_mining_strip10.png"),
		"hair": preload("res://assets/sprites/characters/Human/MINING/hair_merged_mining_strip10.png"),
		"tools": preload("res://assets/sprites/characters/Human/MINING/tools_mining_strip10.png")
	}
}

func _ready() -> void:

	var stats_ui = VBoxContainer.new()
	stats_ui.position = Vector2(-16, -35)
	stats_ui.custom_minimum_size = Vector2(32, 8)
	stats_ui.add_theme_constant_override("separation", 1)
	stats_ui.z_index = 50
	
	hp_bar = ProgressBar.new()
	hp_bar.custom_minimum_size = Vector2(32, 4)
	hp_bar.show_percentage = false
	var hp_bg = StyleBoxFlat.new()
	hp_bg.anti_aliasing = false
	hp_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.border_width_left = 1; hp_bg.border_width_top = 1; hp_bg.border_width_right = 1; hp_bg.border_width_bottom = 1
	hp_bg.border_color = Color(0,0,0,1)
	var hp_fill = StyleBoxFlat.new()
	hp_fill.anti_aliasing = false
	hp_fill.bg_color = Color(0.85, 0.15, 0.15, 1)
	hp_fill.border_width_left = 1; hp_fill.border_width_top = 1; hp_fill.border_width_right = 1; hp_fill.border_width_bottom = 1
	hp_fill.border_color = Color(0,0,0,0)
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	
	stamina_bar = ProgressBar.new()
	stamina_bar.custom_minimum_size = Vector2(32, 4)
	stamina_bar.show_percentage = false
	var st_bg = StyleBoxFlat.new()
	st_bg.anti_aliasing = false
	st_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	st_bg.border_width_left = 1; st_bg.border_width_top = 1; st_bg.border_width_right = 1; st_bg.border_width_bottom = 1
	st_bg.border_color = Color(0,0,0,1)
	var st_fill = StyleBoxFlat.new()
	st_fill.anti_aliasing = false
	st_fill.bg_color = Color(0.15, 0.85, 0.25, 1)
	st_fill.border_width_left = 1; st_fill.border_width_top = 1; st_fill.border_width_right = 1; st_fill.border_width_bottom = 1
	st_fill.border_color = Color(0,0,0,0)
	stamina_bar.add_theme_stylebox_override("background", st_bg)

	stamina_bar.add_theme_stylebox_override("background", st_bg)
	stamina_bar.add_theme_stylebox_override("fill", st_fill)
	
	hunger_wrapper = Control.new()
	hunger_wrapper.custom_minimum_size = Vector2(32, 4)
	hunger_bar = ProgressBar.new()
	hunger_bar.custom_minimum_size = Vector2(32, 4)
	hunger_bar.show_percentage = false
	var hu_bg = StyleBoxFlat.new()
	hu_bg.anti_aliasing = false
	hu_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hu_bg.border_width_left = 1; hu_bg.border_width_top = 1; hu_bg.border_width_right = 1; hu_bg.border_width_bottom = 1
	hu_bg.border_color = Color(0,0,0,1)
	var hu_fill = StyleBoxFlat.new()
	hu_fill.anti_aliasing = false
	hu_fill.bg_color = Color(0.9, 0.6, 0.1, 1) # Orange
	hu_fill.border_width_left = 1; hu_fill.border_width_top = 1; hu_fill.border_width_right = 1; hu_fill.border_width_bottom = 1
	hu_fill.border_color = Color(0,0,0,0)
	hunger_bar.add_theme_stylebox_override("background", hu_bg)
	hunger_bar.add_theme_stylebox_override("fill", hu_fill)
	hunger_wrapper.add_child(hunger_bar)
	
	stats_ui.add_child(hp_bar)
	stats_ui.add_child(stamina_bar)
	stats_ui.add_child(hunger_wrapper)
	add_child(stats_ui)

	GameStateManager.player_hurt.connect(_on_hurt)
	GameStateManager.player_died.connect(_on_died)
	GameStateManager.item_consumed.connect(_on_item_consumed)
	InventoryManager.equipment_changed.connect(_update_equipment_visuals)
	_update_equipment_visuals()

	add_to_group("player")

	_play_anim("idle")


func _on_hurt() -> void:
	if is_dead: return
	if current_anim == "attack": return # Hyper Armor: не прерываем атаку при получении урона
	is_acting = true
	_play_anim("hurt")

func _on_died() -> void:
	is_dead = true
	is_acting = true
	_play_anim("death")


func _process(delta: float) -> void:
	if hp_bar and stamina_bar and hunger_bar:
		hp_bar.max_value = GameStateManager.max_health
		hp_bar.value = GameStateManager.current_health
		stamina_bar.max_value = GameStateManager.max_stamina
		stamina_bar.value = GameStateManager.current_stamina
		hunger_bar.max_value = GameStateManager.max_hunger
		hunger_bar.value = GameStateManager.current_hunger
		
		# Hunger logic
		var hunger_pct = GameStateManager.current_hunger / GameStateManager.max_hunger
		if hunger_pct <= 0.25:
			hunger_wrapper.visible = true
			if hunger_pct <= 0.05:
				hunger_bar.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
				# Flicker
				if randi() % 10 < 2:
					hunger_bar.modulate = Color(1.5, 0.5, 0.5)
				else:
					hunger_bar.modulate = Color.WHITE
			else:
				hunger_bar.position = Vector2.ZERO
				hunger_bar.modulate = Color.WHITE
		else:
			hunger_wrapper.visible = false

		
		hp_bar.visible = (hp_bar.value < hp_bar.max_value)
		stamina_bar.visible = (stamina_bar.value < stamina_bar.max_value)
		
		var style = stamina_bar.get_theme_stylebox("fill")
		if GameStateManager.is_exhausted:
			style.bg_color = Color(0.8, 0.2, 0.2, 1)
		else:
			style.bg_color = Color(0.15, 0.85, 0.25, 1)

func _physics_process(delta: float) -> void:
	if is_dead:
		_process_animation(delta)
		return

	if is_acting:
		velocity = Vector2.ZERO
		move_and_slide()
		_process_animation(delta)
		return
		
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_sprinting = Input.is_action_pressed("sprint")
	
	# Mobile analog override
	var mobile_controls = get_tree().current_scene.get_node_or_null("MobileControls/VirtualJoystick")
	if mobile_controls and mobile_controls.touch_id != -1:
		direction = mobile_controls.output_vector
		is_sprinting = direction.length() > 0.6
		
	var in_water = false
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		var water_layer = world_map.get_node_or_null("WaterLayer")
		if water_layer:
			var map_pos = water_layer.local_to_map(global_position + Vector2(0, -4))
			if water_layer.get_cell_source_id(map_pos) != -1:
				in_water = true
				for child in world_map.get_children():
					if child is TileMapLayer and child != water_layer:
						if child.get_cell_source_id(map_pos) != -1:
							in_water = false
							break

	if direction.length() > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1
			
		if in_water:
			velocity = direction.normalized() * (speed * 0.5)
			_play_anim("swimming")
		elif is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted:
			GameStateManager.consume_stamina(10.0 * delta)
			velocity = direction.normalized() * (speed * 1.5)
			_play_anim("run")
		else:
			velocity = direction.normalized() * speed
			_play_anim("walk")
	else:
		velocity = Vector2.ZERO
		if in_water:
			_play_anim("swimming")
		else:
			_play_anim("idle")

	_update_auto_target()
		
	if Input.is_action_just_pressed("interact"):
		_try_interact()

	# Stamina regeneration
	if not is_acting and not (direction.length() > 0 and is_sprinting and GameStateManager.current_stamina > 0.5 and not GameStateManager.is_exhausted):
		GameStateManager.add_stamina(3.5 * delta)
		
	move_and_slide()
	_process_animation(delta)

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name:
		return
	current_anim = anim_name
	current_frame = 0
	anim_timer = 0.0
	
	var data = anim_data[anim_name]
	for layer_name in LAYERS:
		var sprite: Sprite2D = visuals.get_node(layer_name.capitalize())
		var tex = data[layer_name]
		if tex:
			sprite.texture = tex
			sprite.hframes = data["frames"]
			
			if layer_name == "hair":
				sprite.vframes = int(tex.get_height() / 64)
			else:
				sprite.vframes = 1
				
			sprite.frame_coords = Vector2i(0, hairstyle_index if layer_name == "hair" else 0)

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= (1.0 / fps)
		var frames = anim_data[current_anim]["frames"]
		current_frame += 1
		
		# Handle animation end
		if current_frame >= frames:
			if current_anim == "death":
				current_frame = frames - 1 # Зависаем на последнем кадре смерти
			elif current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame
		if current_anim in ["axe", "mining", "attack"] and current_frame == 6:
			if current_target and is_instance_valid(current_target):
				current_target.interact(self)
		
		for layer_name in LAYERS:
			var sprite: Sprite2D = visuals.get_node(layer_name.capitalize())
			if sprite.texture:
				sprite.frame_coords = Vector2i(current_frame, hairstyle_index if layer_name == "hair" else 0)

func _update_auto_target() -> void:
	var interactables: Array[Node2D] = []
	for a in interaction_area.get_overlapping_areas(): interactables.append(a)
	for b in interaction_area.get_overlapping_bodies(): interactables.append(b)
	var closest_target = null
	var closest_dist: float = INF
	
	for node in interactables:
		if node == self: continue
		if node.has_method("interact"):
			var dist = global_position.distance_to(node.global_position)
			if dist < closest_dist:
				closest_dist = dist
				closest_target = node
				
	# Reset old target modulate
	if current_target and is_instance_valid(current_target):
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color.WHITE
		
	current_target = closest_target
	
	# Highlight new target
	if current_target and is_instance_valid(current_target):
		var sprite = current_target.get_node_or_null("Sprite2D")
		if sprite: sprite.modulate = Color(1.4, 1.4, 1.4, 1.0)

func _try_interact() -> void:
	if current_target:
		var dir_to_target = global_position.direction_to(current_target.global_position)
		if dir_to_target.x != 0:
			visuals.scale.x = -1 if dir_to_target.x < 0 else 1
			
		if current_target is Destructible or current_target is EnemySkeleton:
			var has_tool = false
			
			if current_target is EnemySkeleton:
				if InventoryManager.get_item_amount("stone_sword") > 0:
					has_tool = true
			elif current_target.get("resource_id") == "wood":
				if InventoryManager.get_item_amount("stone_axe") > 0 or InventoryManager.get_item_amount("wooden_axe") > 0:
					has_tool = true
			else:
				if InventoryManager.get_item_amount("stone_pickaxe") > 0 or InventoryManager.get_item_amount("wooden_pickaxe") > 0:
					has_tool = true
					
			if not has_tool:
				print("Необходим инструмент для этого действия!")
				return
				
			if GameStateManager.consume_stamina(15.0):
				is_acting = true
				if current_target is EnemySkeleton:
					_play_anim("attack")
				elif current_target.get("resource_id") == "wood":
					_play_anim("axe")
				else:
					_play_anim("mining")
			else:
				# Cannot swing due to no stamina
				pass
		else:
			# Instant interact (like Boat)
			current_target.interact(self)

func _update_equipment_visuals() -> void:
	var cloth_sprite = visuals.get_node("Cloth")
	var boots_sprite = visuals.get_node("Boots")
	
	cloth_sprite.visible = (InventoryManager.equipment.get("chest", "") != "")
	boots_sprite.visible = (InventoryManager.equipment.get("boots", "") != "")

func _on_item_consumed(p_color: Color) -> void:
	var particle_scene = load("res://scenes/vfx/eat_particles.tscn")
	if particle_scene:
		var inst = particle_scene.instantiate()
		inst.color = p_color
		# Set at player's head/mouth height
		inst.position = Vector2(0, -10)
		add_child(inst)
