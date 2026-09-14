extends CharacterBody2D
class_name NPCBase

## NPCBase
## Базовый универсальный класс для любых NPC в Twilight Islands.
## Позволяет легко размещать NPC на картах, настраивать портреты, диалоги и поведение в Инспекторе.

enum NPCState {
	IDLE,           ## Стоит на месте, ждет разговора
	LYING_DOWN,     ## Лежит на земле (без сознания / ранен), пока игрок не поможет
	WANDERING,      ## Гуляет по окрестностям в радиусе wander_radius
	WORKING,        ## Занят делом (анимации работы)
	FOLLOWING,      ## Следует за игроком
	COMBAT,         ## Отбивается от монстров
	UNCONSCIOUS,    ## Временно нокаутирован в бою
	SLEEPING        ## Спит по ночам (в кровати или на земле с эффектом сна)
}

@export_group("Identity & Visuals")
@export var npc_id: String = "npc_generic"
@export var npc_name: String = "Незнакомец"
@export var portrait: Texture2D = null
@export var sprite_sheet: Texture2D = null
@export var interact_prompt: String = "[E] Поговорить"

@export_group("Dialogue")
@export_file("*.json") var dialogue_file: String = "res://dialogues/template_npc.json"
@export var initial_node_id: String = "start"
@export var embedded_dialogue: Dictionary = {}

@export_group("Behavior & Combat")
@export var initial_state: NPCState = NPCState.IDLE
@export var invulnerable_while_lying: bool = true
@export var can_fight: bool = true
@export var speed: float = 45.0
@export var wander_radius: float = 40.0
@export var max_hp: int = 30
@export var damage: int = 3
@export var detection_radius: float = 80.0
@export var attack_range: float = 22.0

var hp: int = max_hp
var current_state: NPCState = NPCState.IDLE
var player: CharacterBody2D = null
var current_target_enemy: CharacterBody2D = null

var home_origin: Vector2 = Vector2.ZERO
var wander_target: Vector2 = Vector2.ZERO
var wander_timer: float = 2.0
var unconscious_timer: float = 0.0
var attack_cooldown: float = 0.0
var is_attacking: bool = false
var is_standing_up: bool = false
var facing_dir: String = "down"
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var _float_time: float = 0.0

var current_bed: Node2D = null
var sleep_effect_node: Node2D = null
var state_before_sleep: NPCState = NPCState.IDLE
var is_going_to_bed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interact_area: Area2D = $InteractArea
@onready var prompt_label: Label = $PromptLabel
@onready var col_shape: CollisionShape2D = $CollisionShape2D

const ANIM_DATA_64 = {
	"idle_down": {"row": 0, "frames": 6, "fps": 6.0, "loop": true},
	"idle_right": {"row": 1, "frames": 6, "fps": 6.0, "loop": true},
	"idle_up": {"row": 2, "frames": 6, "fps": 6.0, "loop": true},
	"walk_down": {"row": 3, "frames": 6, "fps": 8.0, "loop": true},
	"walk_right": {"row": 4, "frames": 6, "fps": 8.0, "loop": true},
	"walk_up": {"row": 5, "frames": 6, "fps": 8.0, "loop": true},
	"lie_down": {"row": 6, "frames": 4, "fps": 0.0, "loop": false, "freeze_frame": 3},
	"stand_up": {"row": 6, "frames": 4, "fps": 6.0, "loop": false, "reverse": true},
	"work_idle": {"row": 7, "frames": 6, "fps": 5.0, "loop": true},
	"work_active": {"row": 8, "frames": 6, "fps": 6.0, "loop": true},
	"punch_down": {"row": 9, "frames": 4, "fps": 9.0, "loop": false},
	"punch_right": {"row": 10, "frames": 4, "fps": 9.0, "loop": false},
	"punch_up": {"row": 11, "frames": 4, "fps": 9.0, "loop": false},
}

func _ready() -> void:
	add_to_group("allies")
	hp = max_hp
	home_origin = global_position
	current_state = initial_state
	
	if sprite_sheet and sprite:
		sprite.texture = sprite_sheet
	if prompt_label:
		prompt_label.text = interact_prompt
		prompt_label.visible = false
		
	if interact_area:
		interact_area.body_entered.connect(_on_interact_body_entered)
		interact_area.body_exited.connect(_on_interact_body_exited)
		
	if GameStateManager and GameStateManager.has_signal("time_changed"):
		GameStateManager.time_changed.connect(_on_time_changed)
		if GameStateManager.current_time == GameStateManager.TimeOfDay.NIGHT and current_state != NPCState.LYING_DOWN:
			call_deferred("go_to_sleep")
		
	if current_state == NPCState.LYING_DOWN:
		_play_anim("lie_down")
		current_frame = 3
		_apply_frame()
	else:
		_play_anim("idle_down")
		
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	_update_animation(delta)
	
	if prompt_label and prompt_label.visible:
		_float_time += delta * 3.0
		prompt_label.position.y = -34.0 + sin(_float_time) * 2.0
		
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return
		
	if is_standing_up:
		velocity = Vector2.ZERO
		move_and_slide()
		return
		
	if current_state == NPCState.UNCONSCIOUS:
		_process_unconscious(delta)
		return
		
	if DialogueManager.is_in_dialogue and DialogueManager.current_npc == self:
		velocity = Vector2.ZERO
		if current_anim != "lie_down":
			_update_facing_towards(player.global_position)
			_play_anim("idle_" + facing_dir)
		move_and_slide()
		return
		
	match current_state:
		NPCState.IDLE:
			velocity = Vector2.ZERO
			if current_anim != "lie_down":
				_play_anim("idle_" + facing_dir)
			move_and_slide()
			
		NPCState.LYING_DOWN:
			velocity = Vector2.ZERO
			_play_anim("lie_down")
			move_and_slide()
			
		NPCState.WANDERING:
			_process_wander(delta)
			
		NPCState.WORKING:
			velocity = Vector2.ZERO
			move_and_slide()
			
		NPCState.FOLLOWING:
			if can_fight:
				var enemy = _find_nearest_enemy(detection_radius)
				if enemy:
					current_target_enemy = enemy
					current_state = NPCState.COMBAT
					return
			_process_follow(delta)
			
		NPCState.COMBAT:
			_process_combat(delta)
			
		NPCState.SLEEPING:
			_process_sleeping(delta)

func _process_wander(delta: float) -> void:
	wander_timer -= delta
	if wander_timer <= 0.0:
		var angle = randf() * TAU
		var dist = randf_range(10.0, wander_radius)
		wander_target = home_origin + Vector2(cos(angle), sin(angle))
		wander_timer = randf_range(3.0, 6.0)
		
	var to_tgt = wander_target - global_position
	if to_tgt.length() > 6.0:
		velocity = to_tgt.normalized() * (speed * 0.5)
		_update_facing_towards(wander_target)
		_play_anim("walk_" + facing_dir)
	else:
		velocity = Vector2.ZERO
		_play_anim("idle_" + facing_dir)
	move_and_slide()

func _process_follow(_delta: float) -> void:
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	if dist > 55.0:
		velocity = to_player.normalized() * speed
		_update_facing_towards(player.global_position)
		_play_anim("walk_" + facing_dir)
	elif dist <= 35.0:
		velocity = Vector2.ZERO
		_play_anim("idle_" + facing_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * _delta)
		if velocity.length() < 5.0:
			_play_anim("idle_" + facing_dir)
	move_and_slide()

func _process_combat(_delta: float) -> void:
	if not is_instance_valid(current_target_enemy) or (current_target_enemy.has_method("is_dead") and current_target_enemy.is_dead):
		current_target_enemy = null
		current_state = NPCState.FOLLOWING
		return
		
	var to_enemy = current_target_enemy.global_position - global_position
	var dist = to_enemy.length()
	if dist > detection_radius * 1.5:
		current_target_enemy = null
		current_state = NPCState.FOLLOWING
		return
		
	_update_facing_towards(current_target_enemy.global_position)
	if dist <= attack_range:
		velocity = Vector2.ZERO
		if attack_cooldown <= 0.0 and not is_attacking:
			_perform_punch()
	else:
		if not is_attacking:
			velocity = to_enemy.normalized() * (speed * 1.1)
			_play_anim("walk_" + facing_dir)
	move_and_slide()

func _perform_punch() -> void:
	is_attacking = true
	attack_cooldown = 0.9
	_play_anim("punch_" + facing_dir)
	
	get_tree().create_timer(0.22).timeout.connect(func():
		if is_instance_valid(current_target_enemy):
			var dist = (current_target_enemy.global_position - global_position).length()
			if dist <= attack_range + 10.0:
				var hit_dir = (current_target_enemy.global_position - global_position).normalized()
				var rolled_dmg = int(randf_range(damage, damage + 2))
				if current_target_enemy.has_method("take_damage"):
					current_target_enemy.take_damage(rolled_dmg, hit_dir * 80.0, false)
				_spawn_damage_number(rolled_dmg, current_target_enemy.global_position)
		is_attacking = false
	)

func _process_unconscious(delta: float) -> void:
	velocity = Vector2.ZERO
	unconscious_timer -= delta
	if unconscious_timer <= 0.0:
		hp = int(max_hp * 0.4)
		stand_up()
	move_and_slide()

## Действие: NPC встает на ноги
func stand_up() -> void:
	is_standing_up = true
	_play_anim("stand_up")
	get_tree().create_timer(0.6).timeout.connect(func():
		is_standing_up = false
		if current_state == NPCState.LYING_DOWN or current_state == NPCState.UNCONSCIOUS:
			current_state = NPCState.IDLE
		_play_anim("idle_" + facing_dir)
	)

## Действие: NPC начинает следовать за игроком
func start_following() -> void:
	current_state = NPCState.FOLLOWING
	if current_anim == "lie_down":
		stand_up()

func is_unconscious() -> bool:
	return current_state == NPCState.UNCONSCIOUS or current_state == NPCState.SLEEPING or (current_state == NPCState.LYING_DOWN and invulnerable_while_lying)

func is_targetable_by_enemies() -> bool:
	return not is_unconscious()

func _on_time_changed(new_time: int) -> void:
	if new_time == GameStateManager.TimeOfDay.NIGHT:
		go_to_sleep()
	else:
		if current_state == NPCState.SLEEPING:
			wake_up()

func go_to_sleep() -> void:
	if current_state in [NPCState.LYING_DOWN, NPCState.UNCONSCIOUS, NPCState.SLEEPING]:
		return
		
	state_before_sleep = current_state
	current_state = NPCState.SLEEPING
	
	# Ищем свободную кровать на локации
	var beds = get_tree().get_nodes_in_group("beds")
	var chosen_bed = null
	var min_dist = INF
	
	for bed in beds:
		if is_instance_valid(bed) and bed.has_method("is_occupied") and not bed.is_occupied():
			var d = global_position.distance_to(bed.global_position)
			if d < min_dist:
				min_dist = d
				chosen_bed = bed
				
	if chosen_bed:
		current_bed = chosen_bed
		chosen_bed.occupy(self)
		is_going_to_bed = true
	else:
		# Кровати нет - засыпаем на земле на текущем месте
		current_bed = null
		is_going_to_bed = false
		_start_sleeping_visuals()

func wake_up() -> void:
	if current_state != NPCState.SLEEPING:
		return
		
	if is_instance_valid(sleep_effect_node):
		sleep_effect_node.queue_free()
		sleep_effect_node = null
		
	if is_instance_valid(current_bed) and current_bed.has_method("vacate"):
		current_bed.vacate(self)
		current_bed = null
		
	is_going_to_bed = false
	stand_up()
	
	if state_before_sleep in [NPCState.IDLE, NPCState.WANDERING, NPCState.WORKING, NPCState.FOLLOWING]:
		current_state = state_before_sleep
	else:
		current_state = initial_state

func _process_sleeping(delta: float) -> void:
	if is_going_to_bed and is_instance_valid(current_bed):
		var target_pos = current_bed.global_position + Vector2(0, -6)
		var to_bed = target_pos - global_position
		if to_bed.length() > 8.0:
			velocity = to_bed.normalized() * speed
			_update_facing_towards(target_pos)
			_play_anim("walk_" + facing_dir)
			move_and_slide()
			return
		else:
			# Дошли до кровати
			global_position = target_pos
			velocity = Vector2.ZERO
			is_going_to_bed = false
			_start_sleeping_visuals()
			
	velocity = Vector2.ZERO
	_play_anim("lie_down")
	current_frame = 3
	_apply_frame()
	move_and_slide()

func _start_sleeping_visuals() -> void:
	_play_anim("lie_down")
	current_frame = 3
	_apply_frame()
	
	if not is_instance_valid(sleep_effect_node):
		var SleepClass = load("res://scripts/components/sleep_effect.gd")
		if SleepClass:
			sleep_effect_node = SleepClass.new()
			add_child(sleep_effect_node)

func take_damage(amount: int, _knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_unconscious():
		return
	hp -= amount
	_spawn_damage_number(amount, global_position + Vector2(0, -10), Color(1.0, 0.3, 0.3))
	
	if DialogueManager.is_in_dialogue and DialogueManager.current_npc == self:
		DialogueManager.end_dialogue()
		
	if hp <= 0:
		current_state = NPCState.UNCONSCIOUS
		unconscious_timer = randf_range(8.0, 14.0)
		is_attacking = false
		_play_anim("lie_down")
		current_frame = 3
		_apply_frame()
	else:
		if can_fight and (current_state == NPCState.IDLE or current_state == NPCState.FOLLOWING):
			var nearest = _find_nearest_enemy(detection_radius)
			if nearest:
				current_target_enemy = nearest
				current_state = NPCState.COMBAT

func _spawn_damage_number(dmg: int, pos: Vector2, color: Color = Color(0.3, 0.8, 1.0)) -> void:
	var float_scene = load("res://scenes/ui/floating_damage_number.tscn")
	if float_scene and get_tree() and get_tree().current_scene:
		var num = float_scene.instantiate()
		num.global_position = pos + Vector2(randf_range(-6, 6), -14)
		if num.has_method("setup"):
			num.setup(dmg, false, color)
		get_tree().current_scene.add_child(num)

func _find_nearest_enemy(radius: float) -> CharacterBody2D:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest: CharacterBody2D = null
	var min_dist = radius
	for e in enemies:
		if not is_instance_valid(e) or (e.has_method("is_dead") and e.is_dead) or (e.get("is_dead") == true):
			continue
		var d = global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			nearest = e
	return nearest

func _update_facing_towards(target_pos: Vector2) -> void:
	var diff = target_pos - global_position
	if abs(diff.x) > abs(diff.y):
		facing_dir = "right"
		if sprite: sprite.scale.x = -1.0 if diff.x < 0 else 1.0
	else:
		if sprite: sprite.scale.x = 1.0
		facing_dir = "up" if diff.y < 0 else "down"

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and not (is_attacking and current_frame >= ANIM_DATA_64[anim_name]["frames"] - 1):
		return
	current_anim = anim_name
	var data = ANIM_DATA_64.get(anim_name, {})
	if data.get("reverse", false):
		current_frame = data["frames"] - 1
	else:
		current_frame = data.get("freeze_frame", 0)
	anim_timer = 0.0
	_apply_frame()

func _update_animation(delta: float) -> void:
	if not ANIM_DATA_64.has(current_anim):
		return
	var data = ANIM_DATA_64[current_anim]
	if data["fps"] <= 0.0:
		return
	anim_timer += delta
	var frame_dur = 1.0 / data["fps"]
	if anim_timer >= frame_dur:
		anim_timer -= frame_dur
		if data.get("reverse", false):
			current_frame -= 1
			if current_frame < 0:
				current_frame = 0
		else:
			current_frame += 1
			if current_frame >= data["frames"]:
				if data["loop"]:
					current_frame = 0
				else:
					current_frame = data["frames"] - 1
					if is_attacking:
						is_attacking = false
						_play_anim("idle_" + facing_dir)
		_apply_frame()

func _apply_frame() -> void:
	if not sprite or not ANIM_DATA_64.has(current_anim):
		return
	var data = ANIM_DATA_64[current_anim]
	var row = data["row"]
	sprite.region_rect = Rect2(current_frame * 64, row * 64, 64, 64)

func _on_interact_body_entered(b: Node2D) -> void:
	if b.is_in_group("player") and prompt_label:
		if current_state == NPCState.SLEEPING:
			prompt_label.text = "[E] Спит... (Zzz)"
		else:
			prompt_label.text = interact_prompt
		prompt_label.visible = true

func _on_interact_body_exited(b: Node2D) -> void:
	if b.is_in_group("player") and prompt_label:
		prompt_label.visible = false

func interact(_p: Node2D) -> void:
	if current_state == NPCState.SLEEPING:
		if ExpeditionManager:
			ExpeditionManager.post_thought("%s сладко спит... Zzz (Не будем тревожить до утра)" % npc_name, Color(0.8, 0.85, 0.95))
		return
	_open_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if prompt_label and prompt_label.visible and event.is_action_pressed("interact"):
		if not DialogueManager.is_in_dialogue:
			interact(player)
			get_viewport().set_input_as_handled()

func _open_dialogue() -> void:
	if dialogue_file != "" and FileAccess.file_exists(dialogue_file):
		DialogueManager.start_dialogue_from_file(dialogue_file, initial_node_id, npc_name, portrait, self)
	elif not embedded_dialogue.is_empty():
		DialogueManager.start_dialogue(embedded_dialogue, initial_node_id, npc_name, portrait, self)
	else:
		push_warning("NPC %s: Нет диалога!" % npc_name)
