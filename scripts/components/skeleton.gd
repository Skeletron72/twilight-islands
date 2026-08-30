extends Area2D
class_name EnemySkeleton

@export var speed: float = 35.0
@export var damage: int = 8
@export var max_hp: int = 40

var hp: int = max_hp
var hp_bar: ProgressBar
var player: Node2D = null
@onready var sprite: Sprite2D = $Sprite2D

var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 10.0

var is_acting: bool = false
var is_dead: bool = false
var attack_cooldown: float = 0.0

var anim_data = {
	"walk": {"frames": 8, "tex": preload("res://assets/sprites/characters/Skeleton/skeleton_walk_strip8.png")},
	"attack": {"frames": 7, "tex": preload("res://assets/sprites/characters/Skeleton/skeleton_attack_strip7.png")},
	"hurt": {"frames": 7, "tex": preload("res://assets/sprites/characters/Skeleton/skeleton_hurt_strip7.png")},
	"death": {"frames": 10, "tex": preload("res://assets/sprites/characters/Skeleton/skeleton_death_strip10.png")}
}

func _ready() -> void:

	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-16, -30)
	hp_bar.custom_minimum_size = Vector2(32, 4)
	hp_bar.show_percentage = false
	hp_bar.z_index = 50
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
	add_child(hp_bar)

	add_to_group("interactable") 
	collision_layer = 4
	collision_mask = 1
	
	_play_anim("walk")
	
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group("player")


func _process(delta: float) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.visible = (hp < max_hp and hp > 0 and not is_dead)

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	if is_dead:
		_process_animation(delta)
		return
		
	if is_acting:
		_process_animation(delta)
		return
		
	if not is_instance_valid(player):
		_process_animation(delta)
		return
		
	var dist = global_position.distance_to(player.global_position)
	# Бежим к игроку, если далеко ИЛИ если атака на перезарядке
	if dist > 22.0 or attack_cooldown > 0:
		# Если мы слишком близко, можно даже немного сбросить скорость или просто стоять.
		# Но пусть пока просто медленно подходит или толкает.
		var dir = global_position.direction_to(player.global_position)
		global_position += dir * speed * delta
		sprite.scale.x = -1 if dir.x < 0 else 1
		_play_anim("walk")
	else:
		# Начинаем атаку!
		_play_anim("attack")
		is_acting = true
		attack_cooldown = 1.5 # 1.5 секунды до следующей атаки
		
	_process_animation(delta)

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name:
		return
	current_anim = anim_name
	current_frame = 0
	anim_timer = 0.0
	
	var data = anim_data[anim_name]
	sprite.texture = data["tex"]
	sprite.hframes = data["frames"]
	sprite.frame = 0

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= (1.0 / fps)
		var frames = anim_data[current_anim]["frames"]
		current_frame += 1
		
		# Удар по игроку на 4-м кадре атаки
		if current_anim == "attack" and current_frame == 4:
			if is_instance_valid(player) and global_position.distance_to(player.global_position) < 30.0:
				GameStateManager.take_damage(damage)
				
		# Конец анимации
		if current_frame >= frames:
			if current_anim == "death":
				queue_free()
				return
			elif current_anim in ["attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("walk")
			else:
				current_frame = current_frame % frames
				
		sprite.frame = current_frame

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead: return
	
	hp -= amount
	global_position += knockback_dir * 10.0 # Небольшой отброс
	
	if hp <= 0:
		is_dead = true
		_play_anim("death")
	else:
		is_acting = true
		_play_anim("hurt")

func interact(actor: Node2D) -> void:
	if is_dead: return
	var dir = actor.global_position.direction_to(global_position)
	take_damage(10, dir)
