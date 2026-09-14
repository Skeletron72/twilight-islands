extends CharacterBody2D
class_name EnemySkeleton

@export var speed: float = 26.0
@export var damage: int = 10
@export var max_hp: int = 65
@export var detection_radius: float = 130.0
@export var lose_aggro_radius: float = 185.0
@export var attack_range: float = 24.0
@export var attack_windup: float = 0.35
@export var mass: float = 1.6

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
	"attack_down": {"y": 240, "w": 64, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
	"attack_right": {"y": 304, "w": 64, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
	"attack_up": {"y": 368, "w": 64, "h": 32, "frames": 4, "fps": 8.0, "loop": false},
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
var is_aggro: bool = false
var attack_cooldown: float = 0.0
var attack_windup_timer: float = 0.0
var knockback_velocity: Vector2 = Vector2.ZERO

# Paralysis state
var is_paralyzed: bool = false
var paralysis_timer: float = 0.0

func apply_paralysis(duration: float, p_is_twilight: bool = false) -> void:
	if is_dead:
		return
	is_paralyzed = true
	paralysis_timer = max(paralysis_timer, duration)
	is_acting = false
	attack_windup_timer = 0.0
	ParalysisEffect.apply_to(self, duration, p_is_twilight)

var sfx_audio: AudioStreamPlayer2D

func _ready() -> void:
	hp = max_hp
	add_to_group("enemies")

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

	# Health bar (Cute Fantasy UI_Bars: 30x5 mob bar)
	hp_bar = ProgressBar.new()
	hp_bar.position = Vector2(-15, -26)
	hp_bar.custom_minimum_size = Vector2(30, 5)
	hp_bar.show_percentage = false
	hp_bar.z_index = 50
	hp_bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var ui_bars_tex = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Bars.png")
	
	var hp_bg = StyleBoxTexture.new()
	hp_bg.texture = ui_bars_tex
	hp_bg.region_rect = Rect2(1, 15, 30, 5)
	hp_bg.texture_margin_left = 1.0
	hp_bg.texture_margin_right = 1.0
	hp_bg.texture_margin_top = 1.0
	hp_bg.texture_margin_bottom = 1.0
	hp_bg.content_margin_left = 1.0
	hp_bg.content_margin_right = 1.0
	hp_bg.content_margin_top = 1.0
	hp_bg.content_margin_bottom = 1.0
	
	var hp_fill = StyleBoxTexture.new()
	hp_fill.texture = ui_bars_tex
	hp_fill.region_rect = Rect2(2, 7, 28, 3)
	hp_fill.texture_margin_left = 1.0
	hp_fill.texture_margin_right = 1.0
	hp_fill.texture_margin_top = 1.0
	hp_fill.texture_margin_bottom = 1.0
	hp_fill.expand_margin_left = -1.0
	hp_fill.expand_margin_top = -1.0
	hp_fill.expand_margin_right = -1.0
	hp_fill.expand_margin_bottom = -1.0
	hp_fill.modulate_color = Color(0.85, 0.15, 0.15, 1.0)
	
	hp_bar.add_theme_stylebox_override("background", hp_bg)
	hp_bar.add_theme_stylebox_override("fill", hp_fill)
	
	var frame_overlay = TextureRect.new()
	frame_overlay.name = "FrameOverlay"
	frame_overlay.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	frame_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_tex = AtlasTexture.new()
	frame_tex.atlas = ui_bars_tex
	frame_tex.region = Rect2(1, 21, 30, 5)
	frame_overlay.texture = frame_tex
	frame_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	frame_overlay.anchor_right = 1.0
	frame_overlay.anchor_bottom = 1.0
	hp_bar.add_child(frame_overlay)
	
	hp_bar.visible = false
	add_child(hp_bar)

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

	# Decay knockback
	if knockback_velocity.length_squared() > 1.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 350.0 * delta)
	else:
		knockback_velocity = Vector2.ZERO

	if is_dead:
		velocity = Vector2.ZERO
		_process_animation(delta)
		return

	if is_paralyzed:
		paralysis_timer -= delta
		if paralysis_timer <= 0.0:
			is_paralyzed = false
		velocity = knockback_velocity
		move_and_slide()
		return

	if is_acting:
		velocity = knockback_velocity
		move_and_slide()
		_process_animation(delta)
		return

	if not is_instance_valid(player):
		velocity = knockback_velocity
		move_and_slide()
		_play_anim("idle_" + facing_dir)
		_process_animation(delta)
		return

	var target_entity: Node2D = player
	var min_target_dist: float = global_position.distance_to(player.global_position)
	
	# Check if any ally in group 'allies' (e.g. conscious NPC) is closer or attacking
	var allies = get_tree().get_nodes_in_group("allies")
	for ally in allies:
		if is_instance_valid(ally) and ally.is_visible_in_tree():
			if ally.has_method("is_unconscious") and ally.is_unconscious():
				continue # Do NOT attack unconscious NPC!
			if ally.has_method("is_targetable_by_enemies") and not ally.is_targetable_by_enemies():
				continue
			var d_ally = global_position.distance_to(ally.global_position)
			if d_ally < min_target_dist:
				min_target_dist = d_ally
				target_entity = ally

	var dist = min_target_dist
	var dir = global_position.direction_to(target_entity.global_position)

	# Detection / Aggro handling
	if not is_aggro:
		if dist <= detection_radius:
			is_aggro = true
		else:
			# Outside detection radius: stay in idle without rotating toward player
			velocity = knockback_velocity
			move_and_slide()
			_play_anim("idle_" + facing_dir)
			_process_animation(delta)
			return
	else:
		if dist > lose_aggro_radius:
			is_aggro = false
			velocity = knockback_velocity
			move_and_slide()
			_play_anim("idle_" + facing_dir)
			_process_animation(delta)
			return

	# Update facing direction towards target
	_update_facing(dir)

	# Attack range check
	if dist <= attack_range and attack_cooldown <= 0.0:
		is_acting = true
		attack_cooldown = 1.8
		attack_windup_timer = attack_windup
		velocity = Vector2.ZERO
		_play_anim("attack_" + facing_dir)
	else:
		# Chase target with physical sliding
		if dist > attack_range - 4.0:
			velocity = dir * speed + knockback_velocity
			_play_anim("walk_" + facing_dir)
		else:
			velocity = knockback_velocity
			_play_anim("idle_" + facing_dir)

	# Gentle separation if overlapping with player (prevent sudden jitter or launch)
	if is_instance_valid(player) and not player.get("is_dead") and not player.get("is_rolling"):
		var to_player = global_position - player.global_position
		var d = to_player.length()
		if d < 12.0 and d > 0.1:
			velocity += to_player.normalized() * (12.0 - d) * 3.5

	# Clamp velocity to prevent physics glitching / unnatural launching
	if velocity.length() > 220.0:
		velocity = velocity.normalized() * 220.0

	move_and_slide()
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

	# Пауза на замахе перед нанесением удара
	if current_anim.begins_with("attack_") and attack_windup_timer > 0.0:
		attack_windup_timer -= delta
		if attack_windup_timer <= 0.0:
			_play_sound(SFX_SWORD_SWING, 0.9, 1.1)
		_apply_frame()
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
	var target_list: Array[Node2D] = []
	if is_instance_valid(player): target_list.append(player)
	var allies = get_tree().get_nodes_in_group("allies")
	for a in allies:
		if is_instance_valid(a) and a.is_visible_in_tree() and not (a.has_method("is_unconscious") and a.is_unconscious()):
			target_list.append(a)

	var attack_dir = Vector2.DOWN
	match facing_dir:
		"right":
			attack_dir = Vector2.LEFT if (sprite and sprite.scale.x < 0) else Vector2.RIGHT
		"up":
			attack_dir = Vector2.UP
		"down":
			attack_dir = Vector2.DOWN

	for target in target_list:
		var to_target = target.global_position - global_position
		var dist = to_target.length()
		if dist <= attack_range + 10.0:
			if to_target.is_zero_approx() or to_target.normalized().dot(attack_dir) > -0.2:
				var rolled_dmg = int(max(1.0, round(float(damage) * randf_range(0.85, 1.15))))
				if target.has_method("take_damage"):
					target.take_damage(rolled_dmg, global_position)
				elif target == player:
					GameStateManager.take_damage(rolled_dmg)
				break # Hit one target per swing

func _spawn_impact_dust(pos: Vector2) -> void:
	var dust_scene = load("res://scenes/vfx/impact_dust.tscn")
	if dust_scene:
		var dust = dust_scene.instantiate()
		dust.global_position = pos
		if get_tree() and get_tree().current_scene:
			get_tree().current_scene.add_child(dust)

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO, is_crit: bool = false) -> void:
	if is_dead:
		return

	hp -= amount
	is_aggro = true # Provoke aggro immediately on taking damage
	_play_sound(SFX_SKELETON_HURT, 0.9, 1.15)
	
	# Spawn impact dust VFX at hit point
	_spawn_impact_dust(global_position + Vector2(0, -6))

	# Всплывающий урон (обычный или критический)
	DamageNumber.spawn(get_parent(), global_position + Vector2(0, -18), amount, is_crit)

	# Red flash
	if sprite:
		var flash_tween = create_tween()
		sprite.modulate = Color(2.0, 0.4, 0.4, 1.0)
		flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.25)

	# Apply knockback based on mass
	if knockback_dir != Vector2.ZERO:
		var impulse = knockback_dir
		if impulse.length_squared() <= 1.5:
			impulse = impulse.normalized() * 180.0
		knockback_velocity = impulse / max(0.1, mass)

	if hp <= 0:
		is_dead = true
		is_acting = true
		attack_windup_timer = 0.0
		is_paralyzed = false
		var pfx = get_node_or_null("ParalysisEffect")
		if pfx:
			pfx.queue_free()
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
		{"id": "bone", "count": randi_range(1, 2)}
	]

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

func receive_push(push_dir: Vector2, push_speed: float, delta: float) -> void:
	if is_dead:
		return
	var push_impulse = push_dir * (push_speed / max(0.5, mass))
	knockback_velocity = knockback_velocity.move_toward(push_impulse, 250.0 * delta)
