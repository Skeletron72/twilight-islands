extends Area2D
class_name EnemySkeleton

@export var speed: float = 22.0
@export var damage: int = 8
@export var max_hp: int = 40
@export var detection_radius: float = 160.0
@export var attack_range: float = 26.0

const SKELETON_TEX = preload("res://assets/new_assets/Cute_Fantasy/Enemies/Skeleton/Skeleton_Swordman.png")
const SFX_SWORD_SWING = preload("res://assets/audio/sfx/combat/sfx_sword_swing.mp3")
const SFX_SKELETON_HURT = preload("res://assets/audio/sfx/entities/sfx_skeleton_hurt.mp3")
const DROPPED_ITEM_SCENE = preload("res://scenes/objects/dropped_item.tscn")

const ANIM_DATA = {
	"idle_down": {"y": 0, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"idle_right": {"y": 32, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"idle_up": {"y": 64, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"walk_down": {"y": 96, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"walk_right": {"y": 128, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"walk_up": {"y": 160, "w": 32, "h": 32, "frames": 6, "fps": 6.0, "loop": true},
	"death": {"y": 192, "w": 32, "h": 32, "frames": 4, "fps": 5.0, "loop": false},
	"attack_down": {"y": 240, "w": 64, "h": 32, "frames": 4, "fps": 7.0, "loop": false},
	"attack_right": {"y": 304, "w": 64, "h": 32, "frames": 4, "fps": 7.0, "loop": false},
	"attack_up": {"y": 368, "w": 64, "h": 32, "frames": 4, "fps": 7.0, "loop": false},
	"hurt_down": {"y": 416, "w": 32, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
	"hurt_right": {"y": 448, "w": 32, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
	"hurt_up": {"y": 480, "w": 32, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
}

var hp: int = max_hp
var hp_bar: ProgressBar
var player: Node2D = null
@onready var sprite: Sprite2D = $Sprite2D

var facing_dir: String = "down"
var current_anim: String = ""
var current_frame: int = 0
var anim_timer: float = 0.0

var is_acting: bool = false
var is_dead: bool = false
var attack_cooldown: float = 0.0
var sfx_audio: AudioStreamPlayer2D

func _ready() -> void:
	hp = max_hp

	# Setup sprite
	if sprite:
		sprite.texture = SKELETON_TEX
		sprite.region_enabled = true
		sprite.centered = true
		sprite.offset = Vector2(0, -8)

	# Audio
	sfx_audio = AudioStreamPlayer2D.new()
	sfx_audio.bus = "Master"
	sfx_audio.max_distance = 300.0
	add_child(sfx_audio)

	# Health bar
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-16, -26)
	hp_bar.custom_minimum_size = Vector2(32, 4)
	hp_bar.show_percentage = false
	hp_bar.z_index = 50
	var hp_bg = StyleBoxFlat.new()
	hp_bg.anti_aliasing = false
	hp_bg.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	hp_bg.border_width_left = 1; hp_bg.border_width_top = 1; hp_bg.border_width_right = 1; hp_bg.border_width_bottom = 1
	hp_bg.border_color = Color(0, 0, 0, 1)
	var hp_fill = StyleBoxFlat.new()
	hp_fill.anti_aliasing = false
	hp_fill.bg_color = Color(0.85, 0.15, 0.15, 1)
	hp_fill.border_width_left = 1; hp_fill.border_width_top = 1; hp_fill.border_width_right = 1; hp_fill.border_width_bottom = 1
	hp_fill.border_color = Color(0, 0, 0, 0)
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	hp_bar.visible = false
	add_child(hp_bar)

	add_to_group("interactable")
	collision_layer = 4
	collision_mask = 1

	_play_anim("idle_down")

	await get_tree().create_timer(0.3).timeout
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	if hp_bar:
		hp_bar.max_value = max_hp
		hp_bar.value = hp
		hp_bar.visible = (hp < max_hp and hp > 0 and not is_dead)

func _physics_process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta

	if is_dead or is_acting:
		_process_animation(delta)
		return

	if not is_instance_valid(player):
		_play_anim("idle_" + facing_dir)
		_process_animation(delta)
		return

	var dist = global_position.distance_to(player.global_position)
	var dir = global_position.direction_to(player.global_position)

	# Update direction based on vector to player
	_update_facing(dir)

	# If player is outside detection radius, idle
	if dist > detection_radius:
		_play_anim("idle_" + facing_dir)
		_process_animation(delta)
		return

	# Attack range check
	if dist <= attack_range and attack_cooldown <= 0.0:
		is_acting = true
		attack_cooldown = 1.8
		_play_sound(SFX_SWORD_SWING, 0.9, 1.1)
		_play_anim("attack_" + facing_dir)
	else:
		# Chase player
		if dist > attack_range - 4.0:
			global_position += dir * speed * delta
			_play_anim("walk_" + facing_dir)
		else:
			_play_anim("idle_" + facing_dir)

	_process_animation(delta)

func _update_facing(dir: Vector2) -> void:
	if abs(dir.x) > abs(dir.y):
		facing_dir = "right"
		if sprite:
			sprite.scale.x = -1.0 if dir.x < 0 else 1.0
	else:
		if sprite:
			sprite.scale.x = 1.0
		if dir.y > 0:
			facing_dir = "down"
		else:
			facing_dir = "up"

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name:
		return

	current_anim = anim_name
	current_frame = 0
	anim_timer = 0.0
	_apply_frame()

func _apply_frame() -> void:
	if not ANIM_DATA.has(current_anim) or not sprite:
		return
	var data = ANIM_DATA[current_anim]
	var w = data["w"]
	var h = data["h"]
	var y = data["y"]
	sprite.region_rect = Rect2(current_frame * w, y, w, h)

func _process_animation(delta: float) -> void:
	if current_anim == "" or not ANIM_DATA.has(current_anim):
		return

	var data = ANIM_DATA[current_anim]
	var anim_fps: float = data["fps"]
	var total_frames: int = data["frames"]
	var loop: bool = data["loop"]

	anim_timer += delta
	if anim_timer >= 1.0 / anim_fps:
		anim_timer -= (1.0 / anim_fps)
		current_frame += 1

		# Attack hit point (frame 2 is strike impact)
		if current_anim.begins_with("attack_") and current_frame == 2:
			_perform_attack_hit()

		if current_frame >= total_frames:
			if current_anim == "death":
				current_frame = total_frames - 1
				_apply_frame()
				_finish_death()
				return
			elif not loop:
				is_acting = false
				current_frame = 0
				_play_anim("idle_" + facing_dir)
				return
			else:
				current_frame = current_frame % total_frames

		_apply_frame()

func _perform_attack_hit() -> void:
	if is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range + 10.0:
			if player.has_method("take_damage"):
				player.take_damage(damage, global_position)
			else:
				GameStateManager.take_damage(damage)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	if is_dead:
		return

	hp -= amount
	_play_sound(SFX_SKELETON_HURT, 0.9, 1.15)

	# Red flash
	if sprite:
		var flash_tween = create_tween()
		sprite.modulate = Color(2.0, 0.4, 0.4, 1.0)
		flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

	# Knockback
	if knockback_dir != Vector2.ZERO:
		global_position += knockback_dir * 12.0

	if hp <= 0:
		is_dead = true
		is_acting = true
		collision_layer = 0
		collision_mask = 0
		if hp_bar:
			hp_bar.visible = false
		GameStateManager.register_monster_killed()
		_spawn_loot()
		_play_anim("death")
	else:
		is_acting = true
		_play_anim("hurt_" + facing_dir)

func _finish_death() -> void:
	# Fade out corpse smoothly
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.8)
	fade_tween.tween_callback(queue_free)

func _spawn_loot() -> void:
	var items = [
		{"id": "coin", "count": randi_range(2, 5)},
		{"id": "stone", "count": randi_range(1, 2)}
	]
	if randf() < 0.4:
		items.append({"id": "cloth_basic", "count": 1})

	for item_info in items:
		var drop = DROPPED_ITEM_SCENE.instantiate()
		drop.setup(item_info["id"], item_info["count"])
		drop.position = global_position
		get_parent().call_deferred("add_child", drop)

func interact(actor: Node2D) -> void:
	if is_dead:
		return
	var dir = actor.global_position.direction_to(global_position) if actor else Vector2.ZERO
	var dmg = 12 if InventoryManager.get_item_amount("stone_sword") > 0 else 6
	take_damage(dmg, dir)

func _play_sound(stream: AudioStream, min_pitch: float = 0.9, max_pitch: float = 1.1) -> void:
	if sfx_audio and stream:
		sfx_audio.stream = stream
		sfx_audio.pitch_scale = randf_range(min_pitch, max_pitch)
		sfx_audio.play()
