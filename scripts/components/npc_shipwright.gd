extends CharacterBody2D
class_name NpcShipwright

## NpcShipwright
## Корабельщик Финн (Shipwright / Boatbuilder).
## Состояния:
## - STRANDED_RAID: Потерпел крушение на берегу экспедиционного острова.
##   Изначально лежит на песке без сил (анимация lie_down). При первом разговоре встает.
## - FOLLOWING: Следует за игроком к лодке, защищая от монстров (умеренный урон, не имба).
## - COMBAT: Бьется с монстрами, защищая союзников.
## - UNCONSCIOUS: Оглушен/ранен монстрами (падает на землю на 7-14 сек, монстры деаггрятся, затем встает).
## - SETTLED_HOME: Живет на Домашнем Острове, занимается своими делами
##   (чинит снасти, патрулирует причал, периодически отдыхает).

enum State {
	STRANDED_RAID,
	FOLLOWING,
	COMBAT,
	UNCONSCIOUS,
	SETTLED_HOME,
	SLEEPING
}

enum RoutineState {
	IDLE,
	WALKING,
	WORKING
}

@export var max_hp: int = 60
@export var speed: float = 46.0
@export var combat_speed: float = 52.0
@export var damage: int = 3 # Умеренный урон (не выкашивает монстров в соло, мотивирует игрока драться)
@export var detection_radius: float = 85.0
@export var attack_range: float = 22.0
@export var follow_distance_stop: float = 36.0
@export var follow_distance_start: float = 55.0

const FIN_TEX = preload("res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Fisherman_Fin_Combat.png")
const FIN_PORTRAIT = preload("res://assets/new_assets/Cute_Fantasy/NPCs (Premade)/Fin_portrait_20.png")
const SFX_PUNCH = preload("res://assets/audio/sfx/combat/sfx_attack.mp3")

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

var hp: int = max_hp
var current_state: State = State.STRANDED_RAID
var player: CharacterBody2D = null
var current_target_enemy: CharacterBody2D = null

# Living routine on Home Island
var routine_state: RoutineState = RoutineState.IDLE
var routine_timer: float = 3.0
var home_origin: Vector2 = Vector2.ZERO
var routine_target: Vector2 = Vector2.ZERO
var is_standing_up: bool = false
var unconscious_timer: float = 0.0

var current_bed: Node2D = null
var sleep_effect_node: Node2D = null
var state_before_sleep: State = State.SETTLED_HOME
var is_going_to_bed: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var interactable_area: Area2D = $InteractArea
@onready var prompt_label: Label = $PromptLabel
@onready var col_shape: CollisionShape2D = $CollisionShape2D

var facing_dir: String = "down"
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var attack_cooldown: float = 0.0
var is_attacking: bool = false
var _float_time: float = 0.0

func _ready() -> void:
	add_to_group("allies")
	hp = max_hp
	home_origin = global_position
	_setup_sprite()
	_determine_initial_state()
	
	if interactable_area:
		interactable_area.body_entered.connect(_on_interact_body_entered)
		interactable_area.body_exited.connect(_on_interact_body_exited)
		
	if GameStateManager and GameStateManager.has_signal("time_changed"):
		GameStateManager.time_changed.connect(_on_time_changed)
		if GameStateManager.current_time == GameStateManager.TimeOfDay.NIGHT and current_state == State.SETTLED_HOME:
			call_deferred("go_to_sleep")
		
	# Find player
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

func _setup_sprite() -> void:
	if sprite:
		sprite.texture = FIN_TEX
		sprite.region_enabled = true
		sprite.region_rect = Rect2(0, 0, 64, 64)
		sprite.offset = Vector2(0, -18)

func _determine_initial_state() -> void:
	var cur_scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	
	if cur_scene_name == "HomeIsland":
		if HomeStateManager.shipwright_rescued:
			current_state = State.SETTLED_HOME
			visible = true
			set_process(true)
			set_physics_process(true)
			if interactable_area:
				interactable_area.monitoring = true
				interactable_area.monitorable = true
			if col_shape:
				col_shape.disabled = false
			_play_anim("idle_down")
		else:
			# Not yet rescued: COMPLETELY REMOVE from Home Island so no invisible interaction occurs!
			queue_free()
			return
	else:
		# RaidIsland
		if HomeStateManager.shipwright_rescued:
			# Already rescued in previous run -> remove from raid island
			queue_free()
			return
		elif HomeStateManager.shipwright_following:
			current_state = State.FOLLOWING
			_play_anim("idle_down")
		else:
			current_state = State.STRANDED_RAID
			if not HomeStateManager.shipwright_wood_given and not HomeStateManager.shipwright_spoken_once:
				# Initially lying exhausted on the beach
				_play_anim("lie_down")
				current_frame = 3
				_apply_frame()
			else:
				_play_anim("idle_down")

func _process(delta: float) -> void:
	_update_animation(delta)
	_update_prompt_float(delta)
	
	if attack_cooldown > 0.0:
		attack_cooldown -= delta

func _update_prompt_float(delta: float) -> void:
	if prompt_label and prompt_label.visible:
		_float_time += delta * 3.0
		prompt_label.position.y = -34.0 + sin(_float_time) * 2.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		return

	if is_standing_up:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if current_state == State.UNCONSCIOUS:
		_process_unconscious(delta)
		return

	if DialogueManager.is_in_dialogue and DialogueManager.current_speaker == "Корабельщик Финн":
		velocity = Vector2.ZERO
		if current_anim != "lie_down":
			_update_facing_towards(player.global_position)
			_play_anim("idle_" + facing_dir)
		move_and_slide()
		return

	match current_state:
		State.STRANDED_RAID:
			velocity = Vector2.ZERO
			if current_anim != "lie_down":
				_play_anim("idle_" + facing_dir)
			move_and_slide()

		State.SETTLED_HOME:
			_process_home_routine(delta)

		State.FOLLOWING:
			var nearby_enemy = _find_nearest_enemy(detection_radius)
			if nearby_enemy:
				current_target_enemy = nearby_enemy
				current_state = State.COMBAT
				return
			
			_process_following(delta)

		State.COMBAT:
			_process_combat(delta)
			
		State.SLEEPING:
			_process_sleeping(delta)

func _process_unconscious(delta: float) -> void:
	velocity = Vector2.ZERO
	unconscious_timer -= delta
	if unconscious_timer <= 0.0:
		# Recover from knockout!
		hp = int(max_hp * 0.4) # Recovers with 40% HP
		is_standing_up = true
		_play_anim("stand_up")
		if ExpeditionManager:
			ExpeditionManager.post_thought("Корабельщик Финн пришел в себя!", Color(0.4, 1.0, 0.6))
		get_tree().create_timer(0.6).timeout.connect(func():
			is_standing_up = false
			current_state = State.FOLLOWING
			_play_anim("idle_down")
		)
	move_and_slide()

func _process_home_routine(delta: float) -> void:
	routine_timer -= delta
	
	match routine_state:
		RoutineState.IDLE:
			velocity = Vector2.ZERO
			_play_anim("idle_" + facing_dir)
			if routine_timer <= 0.0:
				var roll = randf()
				if roll < 0.45:
					var angle = randf() * TAU
					var dist = randf_range(15.0, 35.0)
					routine_target = home_origin + Vector2(cos(angle), sin(angle))
					routine_state = RoutineState.WALKING
					routine_timer = randf_range(3.0, 5.0)
				elif roll < 0.8:
					routine_state = RoutineState.WORKING
					_play_anim("work_active" if randf() < 0.5 else "work_idle")
					routine_timer = randf_range(4.0, 7.0)
				else:
					routine_timer = randf_range(2.5, 4.5)
					
		RoutineState.WALKING:
			var to_tgt = routine_target - global_position
			if to_tgt.length() > 6.0 and routine_timer > 0.0:
				velocity = to_tgt.normalized() * (speed * 0.55)
				_update_facing_towards(routine_target)
				_play_anim("walk_" + facing_dir)
			else:
				velocity = Vector2.ZERO
				routine_state = RoutineState.IDLE
				routine_timer = randf_range(2.0, 4.0)
				_play_anim("idle_" + facing_dir)
				
		RoutineState.WORKING:
			velocity = Vector2.ZERO
			if routine_timer <= 0.0:
				routine_state = RoutineState.IDLE
				routine_timer = randf_range(2.5, 4.0)
				_play_anim("idle_" + facing_dir)

	move_and_slide()

func _process_following(_delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var to_player = player.global_position - global_position
	var dist = to_player.length()
	
	if dist > follow_distance_start:
		var dir = to_player.normalized()
		velocity = dir * speed
		_update_facing_towards(player.global_position)
		_play_anim("walk_" + facing_dir)
	elif dist <= follow_distance_stop:
		velocity = Vector2.ZERO
		_play_anim("idle_" + facing_dir)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, 300.0 * _delta)
		if velocity.length() < 5.0:
			_play_anim("idle_" + facing_dir)
			
	move_and_slide()

func _process_combat(_delta: float) -> void:
	if not is_instance_valid(current_target_enemy) or (current_target_enemy.has_method("is_dead") and current_target_enemy.is_dead) or (current_target_enemy.get("is_dead") == true):
		current_target_enemy = null
		current_state = State.FOLLOWING
		return
		
	var to_enemy = current_target_enemy.global_position - global_position
	var dist = to_enemy.length()
	
	if dist > detection_radius * 1.5:
		current_target_enemy = null
		current_state = State.FOLLOWING
		return
		
	_update_facing_towards(current_target_enemy.global_position)
	
	if dist <= attack_range:
		velocity = Vector2.ZERO
		if attack_cooldown <= 0.0 and not is_attacking:
			_perform_punch()
	else:
		if not is_attacking:
			velocity = to_enemy.normalized() * combat_speed
			_play_anim("walk_" + facing_dir)
			
	move_and_slide()

func _perform_punch() -> void:
	is_attacking = true
	attack_cooldown = 0.9 # Финн бьет с паузой, не заспамливая врага
	_play_anim("punch_" + facing_dir)
	
	if AudioManager and SFX_PUNCH:
		AudioManager.play_spatial_sfx(SFX_PUNCH, global_position, 0.9, 1.1)
		
	get_tree().create_timer(0.22).timeout.connect(func():
		if is_instance_valid(current_target_enemy):
			var dist = (current_target_enemy.global_position - global_position).length()
			if dist <= attack_range + 12.0:
				var hit_dir = (current_target_enemy.global_position - global_position).normalized()
				var rolled_dmg = int(randf_range(damage, damage + 2)) # 3..5 урона
				if current_target_enemy.has_method("take_damage"):
					current_target_enemy.take_damage(rolled_dmg, hit_dir * 90.0, false)
				_spawn_damage_number(rolled_dmg, current_target_enemy.global_position)
		is_attacking = false
	)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_unconscious() or (current_state == State.STRANDED_RAID and not HomeStateManager.shipwright_wood_given):
		return
		
	hp -= amount
	_spawn_damage_number(amount, global_position + Vector2(0, -10), Color(1.0, 0.3, 0.3))
	
	# Interrupt dialogue if hit during talk
	if DialogueManager and DialogueManager.is_in_dialogue and DialogueManager.current_speaker == "Корабельщик Финн":
		DialogueManager.end_dialogue()
		if ExpeditionManager:
			ExpeditionManager.post_thought("Корабельщика атаковали! Разговор прерван!", Color(1.0, 0.4, 0.4))
			
	if hp <= 0:
		_fall_unconscious()
	else:
		# Shift into combat to defend himself if attacked
		if current_state == State.STRANDED_RAID or current_state == State.FOLLOWING:
			var nearest = _find_nearest_enemy(detection_radius)
			if nearest:
				current_target_enemy = nearest
				current_state = State.COMBAT

func _fall_unconscious() -> void:
	current_state = State.UNCONSCIOUS
	unconscious_timer = randf_range(8.0, 14.0) # Лежит без сознания 8-14 секунд
	current_target_enemy = null
	is_attacking = false
	velocity = Vector2.ZERO
	_play_anim("lie_down")
	current_frame = 3
	_apply_frame()
	
	if ExpeditionManager:
		ExpeditionManager.post_thought("Корабельщик Финн без сознания! Защитите его!", Color(1.0, 0.3, 0.3))
		
	# Деаггрим монстров от Финна
	_deaggro_nearby_enemies()

func _deaggro_nearby_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e):
			# Если монстр целился в Финна, переключаем его на игрока или сбрасываем
			if e.get("target") == self:
				e.set("target", player)

func is_unconscious() -> bool:
	return current_state == State.UNCONSCIOUS or current_state == State.SLEEPING or (current_state == State.STRANDED_RAID and not HomeStateManager.shipwright_wood_given)

func is_targetable_by_enemies() -> bool:
	return not is_unconscious()

func _on_time_changed(new_time: int) -> void:
	if new_time == GameStateManager.TimeOfDay.NIGHT:
		if current_state == State.SETTLED_HOME:
			go_to_sleep()
	else:
		if current_state == State.SLEEPING:
			wake_up()

func go_to_sleep() -> void:
	if current_state in [State.STRANDED_RAID, State.UNCONSCIOUS, State.SLEEPING]:
		return
		
	state_before_sleep = current_state
	current_state = State.SLEEPING
	
	# Ищем свободную кровать на Домашнем Острове
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
		current_bed = null
		is_going_to_bed = false
		_start_sleeping_visuals()

func wake_up() -> void:
	if current_state != State.SLEEPING:
		return
		
	if is_instance_valid(sleep_effect_node):
		sleep_effect_node.queue_free()
		sleep_effect_node = null
		
	if is_instance_valid(current_bed) and current_bed.has_method("vacate"):
		current_bed.vacate(self)
		current_bed = null
		
	is_going_to_bed = false
	is_standing_up = true
	_play_anim("stand_up")
	get_tree().create_timer(0.6).timeout.connect(func():
		is_standing_up = false
		current_state = state_before_sleep
		_play_anim("idle_down")
	)

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
		if not is_instance_valid(e) or e.get("is_dead") == true:
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
		if sprite:
			sprite.scale.x = -1.0 if diff.x < 0 else 1.0
	else:
		if sprite:
			sprite.scale.x = 1.0
		if diff.y < 0:
			facing_dir = "up"
		else:
			facing_dir = "down"

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
				if is_standing_up:
					is_standing_up = false
					_play_anim("idle_down")
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
	var cell_x = current_frame * 64
	var cell_y = row * 64
	sprite.region_rect = Rect2(cell_x, cell_y, 64, 64)

# --- Interaction & Dialogues ---

func _on_interact_body_entered(b: Node2D) -> void:
	if not is_visible_in_tree() or current_state == State.UNCONSCIOUS:
		return
	if b.is_in_group("player") and prompt_label:
		if current_state == State.SLEEPING:
			prompt_label.text = "[E] Спит... (Zzz)"
		else:
			prompt_label.text = "[E] Финн"
		prompt_label.visible = true

func _on_interact_body_exited(b: Node2D) -> void:
	if b.is_in_group("player") and prompt_label:
		prompt_label.visible = false

func interact(_p: Node2D) -> void:
	if not is_visible_in_tree() or current_state == State.UNCONSCIOUS:
		return
	if current_state == State.SLEEPING:
		if ExpeditionManager:
			ExpeditionManager.post_thought("Корабельщик Финн сладко спит... Zzz (Не будем тревожить до утра)", Color(0.8, 0.85, 0.95))
		return
	_open_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if not is_visible_in_tree() or current_state == State.UNCONSCIOUS:
		return
	if prompt_label and prompt_label.visible and event.is_action_pressed("interact"):
		if not DialogueManager.is_in_dialogue:
			interact(player)
			get_viewport().set_input_as_handled()

func stand_up() -> void:
	if current_anim == "lie_down":
		is_standing_up = true
		_play_anim("stand_up")
		get_tree().create_timer(0.6).timeout.connect(func():
			is_standing_up = false
			_play_anim("idle_down")
		)

func start_following() -> void:
	current_state = State.FOLLOWING
	HomeStateManager.shipwright_following = true
	if current_anim == "lie_down":
		_play_anim("idle_down")
	if ExpeditionManager:
		ExpeditionManager.post_thought("Корабельщик Финн следует за вами!", Color(0.4, 0.9, 1.0))

func _open_dialogue() -> void:
	if current_state == State.UNCONSCIOUS:
		return
	HomeStateManager.shipwright_spoken_once = true
	DialogueManager.set_flag("shipwright_spoken_once", true)
	if current_anim == "lie_down":
		is_standing_up = true
		_play_anim("stand_up")
		get_tree().create_timer(0.5).timeout.connect(func():
			is_standing_up = false
			_play_anim("idle_down")
			_proceed_open_dialogue()
		)
	else:
		_proceed_open_dialogue()

func _proceed_open_dialogue() -> void:
	var cur_scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
	
	if cur_scene_name == "HomeIsland":
		var cur_day = GameStateManager.current_day
		var arr_day = HomeStateManager.shipwright_arrival_day
		if arr_day == -1 or cur_day <= arr_day:
			DialogueManager.start_dialogue_from_file("res://dialogues/shipwright_home.json", "first_day_rest", "Корабельщик Финн", FIN_PORTRAIT, self)
		else:
			DialogueManager.start_dialogue_from_file("res://dialogues/shipwright_home.json", "start", "Корабельщик Финн", FIN_PORTRAIT, self)
	else:
		DialogueManager.start_dialogue_from_file("res://dialogues/shipwright_stranded.json", "start", "Корабельщик Финн", FIN_PORTRAIT, self)

func _build_raid_dialogue() -> Dictionary:
	var tree: Dictionary = {}
	
	if not HomeStateManager.shipwright_wood_given:
		tree["start"] = {
			"speaker": "Корабельщик Финн",
			"text": "Ох... Голова раскалывается... Шхуну разбило в щепки об рифы... Проклятый сумеречный шторм налетел внезапно! Я едва выполз на этот песок.",
			"choices": [
				{
					"text": "Ты ранен? Чем я могу помочь?",
					"next": "ask_help"
				},
				{
					"text": "Держись, я осмотрюсь вокруг.",
					"next": "end"
				}
			]
		}
		tree["ask_help"] = {
			"speaker": "Корабельщик Финн",
			"text": "Мне бы пару крепких досок, чтобы смастерить временное снаряжение и защититься от тварей. Если у тебя найдется [color=#ffdd77]5 единиц древесины[/color], я буду по гроб жизни благодарен!",
			"choices": [
				{
					"text": "Вот, держи [Отдать 5 древесины]",
					"condition": Callable(self, "_can_give_wood"),
					"action": Callable(self, "_give_wood_action"),
					"next": "wood_given"
				},
				{
					"text": "У меня пока нет столько дерева, сейчас добуду.",
					"next": "end"
				}
			]
		}
		tree["wood_given"] = {
			"speaker": "Корабельщик Финн",
			"text": "Ого, отличный дуб! С такими досками мы не пропадем. Спасибо тебе, друг! Ты спас моряка от верной гибели.",
			"choices": [
				{
					"text": "Пойдем со мной к лодке, уплывем на мой домашний остров!",
					"action": Callable(self, "_start_following_action"),
					"next": "following_accepted"
				}
			]
		}
	else:
		if current_state == State.FOLLOWING:
			tree["start"] = {
				"speaker": "Корабельщик Финн",
				"text": "Я прикрою спину! Веди к лодке, пока шторм не накрыл нас с головой!",
				"choices": [
					{
						"text": "Вперед, прорываемся!",
						"next": "end"
					}
				]
			}
		else:
			tree["start"] = {
				"speaker": "Корабельщик Финн",
				"text": "Снаряжение готово. Куда держим путь, капитан?",
				"choices": [
					{
						"text": "Пойдем к лодке, отплываем домой!",
						"action": Callable(self, "_start_following_action"),
						"next": "following_accepted"
					},
					{
						"text": "Подожди пока здесь.",
						"next": "end"
					}
				]
			}
			
	tree["following_accepted"] = {
		"speaker": "Корабельщик Финн",
		"text": "С превеликим удовольствием! На берегу кишат твари, держись рядом — я пущу в ход свои кулаки!",
		"choices": [
			{
				"text": "За мной!",
				"next": "end"
			}
		]
	}
	return tree

func _can_give_wood() -> bool:
	return InventoryManager.has_item("wood", 5)

func _give_wood_action() -> void:
	if InventoryManager.remove_item("wood", 5):
		HomeStateManager.shipwright_wood_given = true
		QuestManager.report_event("custom", "wood", 5)
		if current_anim == "lie_down":
			is_standing_up = true
			_play_anim("stand_up")
			get_tree().create_timer(0.6).timeout.connect(func():
				is_standing_up = false
				_play_anim("idle_down")
			)
		if ExpeditionManager:
			ExpeditionManager.post_thought("Вы помогли Корабельщику древесиной!", Color(0.4, 1.0, 0.5))

func _start_following_action() -> void:
	current_state = State.FOLLOWING
	HomeStateManager.shipwright_following = true
	if current_anim == "lie_down":
		_play_anim("idle_down")
	if ExpeditionManager:
		ExpeditionManager.post_thought("Корабельщик Финн следует за вами!", Color(0.4, 0.9, 1.0))

func _build_home_dialogue() -> Dictionary:
	var tree: Dictionary = {}
	var cur_day = GameStateManager.current_day
	var arr_day = HomeStateManager.shipwright_arrival_day
	
	if arr_day == -1 or cur_day <= arr_day:
		tree["start"] = {
			"speaker": "Корабельщик Финн",
			"text": "Ах, твердая земля под ногами! Твой домашний остров просто прекрасен, друг. Дай мне дух перевести после этой бури, а завтра обсудим великие дела!",
			"choices": [
				{
					"text": "Отдыхай, Финн. Завтра поговорим.",
					"next": "end"
				}
			]
		}
	else:
		if not HomeStateManager.workshop_quest_started:
			tree["start"] = {
				"speaker": "Корабельщик Финн",
				"text": "Доброе утро, друг! Я осмотрел бухту. Место идеальное! Но чтобы строить надежные корабли и укреплять лодку для дальних экспедиций, нам нужна [color=#ffdd77]Корабельная мастерская[/color]. Поможешь собрать материалы?",
				"choices": [
					{
						"text": "Конечно! Что нужно принести?",
						"action": Callable(self, "_start_workshop_quest_action"),
						"next": "workshop_details"
					},
					{
						"text": "Позже, сейчас я занят.",
						"next": "end"
					}
				]
			}
			tree["workshop_details"] = {
				"speaker": "Корабельщик Финн",
				"text": "Принеси мне [color=#ffdd77]10 брёвен[/color] и [color=#ffdd77]6 камней[/color]. Я заложу фундамент прямо у воды, и мы начнем улучшать наш флот!",
				"choices": [
					{
						"text": "Договорились, скоро принесу!",
						"next": "end"
					}
				]
			}
		else:
			tree["start"] = {
				"speaker": "Корабельщик Финн",
				"text": "Как продвигается сбор материалов для верфи? Нам нужно 10 бревен и 6 камней.",
				"choices": [
					{
						"text": "Вот материалы для мастерской! [Сдать ресурсы]",
						"condition": Callable(self, "_can_turn_in_workshop"),
						"action": Callable(self, "_turn_in_workshop_action"),
						"next": "workshop_finished"
					},
					{
						"text": "Еще собираю, скоро вернусь.",
						"next": "end"
					}
				]
			}
			tree["workshop_finished"] = {
				"speaker": "Корабельщик Финн",
				"text": "Браво! С этими материалами я возведу лучшую мастерскую на всех Сумеречных Островах. Лови награду за труды!",
				"choices": [
					{
						"text": "Отличная работа, Финн!",
						"next": "end"
					}
				]
			}
	return tree

func _start_workshop_quest_action() -> void:
	HomeStateManager.workshop_quest_started = true
	QuestManager.activate_quest("build_workshop")
	if ExpeditionManager:
		ExpeditionManager.post_thought("Новое задание: Мастерская корабельщика!", Color(1.0, 0.9, 0.4))

func _can_turn_in_workshop() -> bool:
	return InventoryManager.has_item("wood", 10) and InventoryManager.has_item("stone", 6)

func _turn_in_workshop_action() -> void:
	if InventoryManager.remove_item("wood", 10) and InventoryManager.remove_item("stone", 6):
		QuestManager.claim_reward("build_workshop")
		if ExpeditionManager:
			ExpeditionManager.post_thought("Задание выполнено: Мастерская корабельщика заложена!", Color(0.3, 1.0, 0.5))
