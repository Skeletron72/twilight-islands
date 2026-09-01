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
var fps: float = 6.0

# Define paperdoll layers
const LAYERS = ["Base", "Legs", "Feet", "Chest", "Head", "Hands"]

const ANIM_MAP = {
	"idle": { "row": 0, "frames": 6 },
	"walk": { "row": 3, "frames": 6 },
	"run": { "row": 3, "frames": 6 },
	"attack": { "row": 6, "frames": 4 }, # 6 = Sword L->R, 9 = Right L->R, 12 = Up L->R
	"hurt": { "row": 15, "frames": 4 }, # Using Fall Right (15) as hurt/death for now
	"death": { "row": 15, "frames": 4 },
	"axe": { "row": 32, "frames": 6 },
	"mining": { "row": 35, "frames": 6 },
	"swimming": { "row": 3, "frames": 6 }
}

var current_dir: int = 0 # 0=Down, 1=Right, 2=Up

func _ready() -> void:
	# Set up the sprite sheets
	var tex_base = preload("res://assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
	var tex_legs = preload("res://assets/new_assets/Cute_Fantasy/Player/Legs/Farmer_Pants/Farmer_Pants_1_Blue.png")
	var tex_feet = preload("res://assets/new_assets/Cute_Fantasy/Player/Feet/Shoes_1_Brown.png")
	var tex_chest = preload("res://assets/new_assets/Cute_Fantasy/Player/Chest/Farmer_Shirt/Farmer_Shirt_1_Red.png")
	var tex_head = preload("res://assets/new_assets/Cute_Fantasy/Player/Head/Hair_1/Hair_1_Brown.png")
	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	# Preload tools
	var tool_sprite = visuals.get_node_or_null("Tool")
	if tool_sprite:
		tool_sprite.visible = false
	
	for layer_name in LAYERS:
		var sprite = visuals.get_node_or_null(layer_name)
		if sprite:
			sprite.hframes = 9
			sprite.vframes = 56
			if layer_name == "Base": sprite.texture = tex_base
			if layer_name == "Legs": sprite.texture = tex_legs
			if layer_name == "Feet": sprite.texture = tex_feet
			if layer_name == "Chest": sprite.texture = tex_chest
			if layer_name == "Head": sprite.texture = tex_head
			if layer_name == "Hands": sprite.texture = tex_hands

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
	var current_biome = ""
	var current_scene = get_tree().current_scene
	var world_map = current_scene.get_node_or_null("WorldMap")
	if world_map:
		# Проверяем слои сверху вниз (от верхнего грунта к океану)
		var check_layers = ["RoadsLayer", "WaterLayer", "GroundLayer", "ShoreLayer", "OceanLayer"]
		for layer_name in check_layers:
			var layer = world_map.get_node_or_null(layer_name)
			if layer and layer is TileMapLayer:
				var map_pos = layer.local_to_map(global_position + Vector2(0, -4))
				var cell_data = layer.get_cell_tile_data(map_pos)
				if cell_data:
					# Нашли самый верхний тайл, на котором стоит игрок!
					in_water = cell_data.get_custom_data("is_water")
					
					# Если у вас есть кастомная дата "biome" (тип String), мы можем читать ее здесь:
					# current_biome = cell_data.get_custom_data("biome")
					
					break # Прерываем поиск, так как нашли поверхность под ногами

	if direction.length() > 0:
		# 0=Down, 1=Right, 2=Up
		if abs(direction.x) > abs(direction.y):
			current_dir = 1
			visuals.scale.x = -1 if direction.x < 0 else 1
		elif direction.y > 0:
			current_dir = 0
			visuals.scale.x = 1
		elif direction.y < 0:
			current_dir = 2
			visuals.scale.x = 1
			
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

var last_played_dir: int = -1

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_dir == last_played_dir:
		return
	
	if current_anim != anim_name:
		current_frame = 0
		anim_timer = 0.0
		
	current_anim = anim_name
	last_played_dir = current_dir
	
	# Immediately update sprite frame when changing animation or direction
	_update_sprites()

func get_last_direction() -> int:
	return current_dir

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	var fps_mult = 1.0
	if current_anim == "run": fps_mult = 1.5
	
	anim_timer += delta
	var frame_dur = 1.0 / (fps * fps_mult)
	
	if anim_timer >= frame_dur:
		anim_timer -= frame_dur
		var frames = ANIM_MAP[current_anim]["frames"]
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
		var hit_frame = 3 # New animations are shorter (6 or 4 frames), hit around frame 3
		if current_anim in ["axe", "mining", "attack"] and current_frame == hit_frame:
			if current_target and is_instance_valid(current_target):
				if current_target.has_method("interact"):
					current_target.interact(self)
		
		var row = ANIM_MAP[current_anim]["row"]
		# For attack (6, 9, 12), we multiply current_dir by 3.
		# For most others, it's just + current_dir
		var actual_row = row
		if current_anim == "attack":
			actual_row = row + (current_dir * 3)
		else:
			actual_row = row + current_dir
			
		_update_sprites()

func _update_sprites() -> void:
	var row = ANIM_MAP[current_anim]["row"]
	var actual_row = row
	if current_anim == "attack":
		actual_row = row + (current_dir * 3)
	else:
		actual_row = row + current_dir
		
	for layer_name in LAYERS:
		var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
		if sprite and sprite.texture:
			sprite.frame_coords = Vector2i(current_frame, actual_row)
			
	var tool_sprite: Sprite2D = visuals.get_node_or_null("Tool")
	if tool_sprite:
		if current_anim in ["attack", "axe", "mining"]:
			tool_sprite.visible = true
			if current_anim == "attack":
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Sword.png")
				tool_sprite.hframes = 4
				tool_sprite.vframes = 9
				# Attack row in player body is 6 + (dir*3). In sword it's 0 + (dir*3).
				var sword_row = actual_row - 6
				tool_sprite.frame_coords = Vector2i(current_frame, sword_row)
			elif current_anim in ["axe", "mining"]:
				tool_sprite.texture = load("res://assets/new_assets/Cute_Fantasy/Player/Tools/Iron/Iron_Tools.png")
				tool_sprite.hframes = 6
				tool_sprite.vframes = 12
				# Axe row in player body is 32 + dir. In tools it's 0 + dir.
				# Mining row in player body is 35 + dir. In tools it's 3 + dir.
				var tool_row = actual_row - 32
				tool_sprite.frame_coords = Vector2i(current_frame, tool_row)
		else:
			tool_sprite.visible = false

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
			
		if current_target is Stone or current_target is EnemySkeleton or current_target is TreeObject:
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
	else:
		_use_hoe()

func _update_equipment_visuals() -> void:
	var chest_sprite = visuals.get_node_or_null("Chest")
	var feet_sprite = visuals.get_node_or_null("Feet")
	
	if chest_sprite:
		chest_sprite.visible = (InventoryManager.equipment.get("chest", "") != "")
	if feet_sprite:
		feet_sprite.visible = (InventoryManager.equipment.get("boots", "") != "")

func _on_item_consumed(p_color: Color) -> void:
	var particle_scene = load("res://scenes/vfx/eat_particles.tscn")
	if particle_scene:
		var inst = particle_scene.instantiate()
		inst.color = p_color
		# Set at player's head/mouth height
		inst.position = Vector2(0, -10)
		add_child(inst)
# trigger cache rebuild

func _use_hoe() -> void:
	is_acting = true
	_play_anim("axe")
	var timer = get_tree().create_timer(0.3)
	await timer.timeout
	
	var world_map = get_tree().current_scene.get_node_or_null("WorldMap")
	if world_map:
		var ground = world_map.get_node_or_null("GroundLayer")
		if ground:
			var dir_vec = Vector2.ZERO
			if current_dir == 0: dir_vec = Vector2(0, 16)
			elif current_dir == 1: dir_vec = Vector2(16, 0)
			elif current_dir == 2: dir_vec = Vector2(0, -16)
			if visuals.scale.x < 0 and current_dir == 1: dir_vec.x = -16
			
			var target_pos = global_position + dir_vec
			var map_pos = ground.local_to_map(target_pos)
			
			var ts = ground.tile_set
			var farmland_id = -1
			if ts:
				for i in range(ts.get_terrains_count(0)):
					if ts.get_terrain_name(0, i) == "FarmLand":
						farmland_id = i
						break
						
			if farmland_id != -1:
				var cell_data = ground.get_cell_tile_data(map_pos)
				if cell_data and cell_data.get_custom_data("can_hoe") == true:
					ground.set_cells_terrain_connect([map_pos], 0, farmland_id)
				else:
					print("Здесь нельзя копать! Нужна земля.")
				
	is_acting = false
	_play_anim("idle")
