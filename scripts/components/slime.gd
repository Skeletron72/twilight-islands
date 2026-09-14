extends CharacterBody2D
class_name SlimeEnemy

enum SlimeSize { BIG, MEDIUM, SMALL }
enum SlimeColor { BLUE, GREEN, PINK, RED, YELLOW }

@export var slime_size: SlimeSize = SlimeSize.BIG
@export var slime_color: SlimeColor = SlimeColor.GREEN
@export var detection_radius: float = 140.0
@export var lose_aggro_radius: float = 200.0

const COLOR_NAMES = {
	SlimeColor.BLUE: "синий",
	SlimeColor.GREEN: "зелёный",
	SlimeColor.PINK: "розовый",
	SlimeColor.RED: "красный",
	SlimeColor.YELLOW: "жёлтый"
}

const COLOR_FILES = {
	SlimeColor.BLUE: "Blue",
	SlimeColor.GREEN: "Green",
	SlimeColor.PINK: "Pink",
	SlimeColor.RED: "Red",
	SlimeColor.YELLOW: "Yellow"
}

const SIZE_DIRS = {
	SlimeSize.BIG: "Slime_Big",
	SlimeSize.MEDIUM: "Slime_Medium",
	SlimeSize.SMALL: "Slime_Small"
}

const SIZE_PREFIXES = {
	SlimeSize.BIG: "Большой ",
	SlimeSize.MEDIUM: "",
	SlimeSize.SMALL: "Маленький "
}

const SIZE_FRAME_DIMS = {
	SlimeSize.BIG: 64,
	SlimeSize.MEDIUM: 32,
	SlimeSize.SMALL: 16
}

const SIZE_STATS = {
	SlimeSize.BIG: {
		"hp": 55,
		"damage": 13,
		"speed": 28.0,
		"col_radius": 11.0,
		"offset": Vector2(0, -14),
		"bar_pos": Vector2(-16, -30),
		"bar_w": 32.0,
		"mass": 2.4
	},
	SlimeSize.MEDIUM: {
		"hp": 26,
		"damage": 8,
		"speed": 34.0,
		"col_radius": 7.0,
		"offset": Vector2(0, -8),
		"bar_pos": Vector2(-12, -19),
		"bar_w": 24.0,
		"mass": 1.1
	},
	SlimeSize.SMALL: {
		"hp": 12,
		"damage": 4,
		"speed": 38.0,
		"col_radius": 4.0,
		"offset": Vector2(0, -4),
		"bar_pos": Vector2(-8, -12),
		"bar_w": 16.0,
		"mass": 0.6
	}
}

const ANIM_ROWS = {
	"idle": {"row": 0, "frames": 4, "fps": 5.0, "loop": true},
	"jump": {"row": 1, "frames": 8, "fps": 9.0, "loop": false},
	"death": {"row": 2, "frames": 8, "fps": 9.0, "loop": false},
	"hurt": {"row": 3, "frames": 4, "fps": 10.0, "loop": false}
}

var max_hp: int = 40
var hp: int = 40
var damage: int = 8
var speed: float = 35.0
var mass: float = 1.0
var slime_name: String = "Слизень"

var player: Node2D = null
var is_dead: bool = false
var has_split: bool = false
var is_acting: bool = false
var is_jumping: bool = false
var is_aggro: bool = false

var jump_cooldown: float = 0.5
var touch_cooldown: float = 0.0
var jump_target_dir: Vector2 = Vector2.ZERO
var knockback_velocity: Vector2 = Vector2.ZERO

# Paralysis state
var is_paralyzed: bool = false
var paralysis_timer: float = 0.0

func apply_paralysis(duration: float, p_is_twilight: bool = false) -> void:
	if is_dead:
		return
	is_paralyzed = true
	paralysis_timer = max(paralysis_timer, duration)
	is_jumping = false
	is_acting = false
	ParalysisEffect.apply_to(self, duration, p_is_twilight)

var current_anim: String = "idle"
var current_frame: int = 0
var anim_timer: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hurtbox_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
var hp_bar: ProgressBar

func _ready() -> void:
	add_to_group("enemies")

	_apply_size_and_color()
	_setup_hp_bar()

	_play_anim("idle")

	await get_tree().create_timer(0.3).timeout
	player = get_tree().get_first_node_in_group("player")

func setup_slime(p_size: SlimeSize, p_color: SlimeColor) -> void:
	slime_size = p_size
	slime_color = p_color
	_apply_size_and_color()
	if is_node_ready():
		_setup_hp_bar()

func _apply_size_and_color() -> void:
	var stats = SIZE_STATS[slime_size]
	max_hp = stats["hp"]
	hp = max_hp
	damage = stats["damage"]
	speed = stats["speed"]
	mass = stats.get("mass", 1.0)

	# Calculate localized name
	var color_name = COLOR_NAMES[slime_color]
	var prefix = SIZE_PREFIXES[slime_size]
	if prefix == "":
		slime_name = color_name.capitalize() + " слизень"
	else:
		slime_name = prefix + color_name + " слизень"

	# Load texture
	var folder = SIZE_DIRS[slime_size]
	var col_file = COLOR_FILES[slime_color]
	var tex_path = "res://assets/new_assets/Cute_Fantasy/Enemies/Slime/%s/%s_%s.png" % [folder, folder, col_file]
	var tex = load(tex_path)

	if sprite:
		sprite.texture = tex
		sprite.region_enabled = true
		sprite.centered = true
		sprite.offset = stats["offset"]

	if collision_shape and collision_shape.shape:
		var circle = collision_shape.shape.duplicate() as CircleShape2D
		circle.radius = stats["col_radius"]
		collision_shape.shape = circle
		collision_shape.position = Vector2(0, -circle.radius * 0.6)

	if hurtbox_shape and hurtbox_shape.shape:
		var hurt_circle = hurtbox_shape.shape.duplicate() as CircleShape2D
		hurt_circle.radius = stats["col_radius"] + 4.0
		hurtbox_shape.shape = hurt_circle
		hurtbox_shape.position = Vector2(0, -hurt_circle.radius * 0.5)

	_apply_frame()

func _setup_hp_bar() -> void:
	var stats = SIZE_STATS[slime_size]
	if not hp_bar:
		hp_bar = ProgressBar.new()
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
		
		add_child(hp_bar)

	hp_bar.position = Vector2(-15, stats["bar_pos"].y)
	hp_bar.custom_minimum_size = Vector2(30, 5)
	hp_bar.max_value = max_hp
	hp_bar.value = hp
	hp_bar.visible = false

func _process(delta: float) -> void:
	if hp_bar:
		hp_bar.value = hp
		hp_bar.visible = (hp < max_hp and hp > 0 and not is_dead)

func _physics_process(delta: float) -> void:
	if touch_cooldown > 0:
		touch_cooldown -= delta

	if jump_cooldown > 0:
		jump_cooldown -= delta

	# Decay knockback
	if knockback_velocity.length_squared() > 1.0:
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 380.0 * delta)
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

	if is_acting: # Hurt or recovery
		velocity = knockback_velocity
		move_and_slide()
		_process_animation(delta)
		return

	if not is_instance_valid(player):
		velocity = knockback_velocity
		move_and_slide()
		_play_anim("idle")
		_process_animation(delta)
		return

	var dist = global_position.distance_to(player.global_position)
	var dir = global_position.direction_to(player.global_position)

	# Detection / Aggro
	if not is_aggro:
		if dist <= detection_radius:
			is_aggro = true
		else:
			# Peaceful idle
			velocity = knockback_velocity
			move_and_slide()
			_play_anim("idle")
			_process_animation(delta)
			return
	else:
		if dist > lose_aggro_radius:
			is_aggro = false
			velocity = knockback_velocity
			move_and_slide()
			_play_anim("idle")
			_process_animation(delta)
			return

	# Touch attack check (удар при прикосновении)
	var stats = SIZE_STATS[slime_size]
	var touch_dist = stats["col_radius"] + 8.0
	if dist <= touch_dist and touch_cooldown <= 0.0:
		touch_cooldown = 1.4
		var rolled_dmg = int(max(1.0, round(float(damage) * randf_range(0.85, 1.15))))
		if player.has_method("take_damage"):
			player.take_damage(rolled_dmg, global_position)
		else:
			GameStateManager.take_damage(rolled_dmg)
		# Slime recoils back slightly upon hitting player to prevent stun-locking
		knockback_velocity = -jump_target_dir * 40.0
		is_jumping = false
		match slime_size:
			SlimeSize.SMALL:
				jump_cooldown = randf_range(0.9, 1.3)
			SlimeSize.MEDIUM:
				jump_cooldown = randf_range(1.1, 1.5)
			SlimeSize.BIG:
				jump_cooldown = randf_range(1.3, 1.8)
			_:
				jump_cooldown = 1.0
		_play_anim("idle")

	# Jumping movement state machine
	if is_jumping:
		# During airborne frames (2, 3, 4, 5), move in jump direction
		var air_mult = 1.35 if slime_size == SlimeSize.SMALL else 1.4
		if current_frame >= 2 and current_frame <= 5:
			velocity = jump_target_dir * (speed * air_mult) + knockback_velocity
		else:
			velocity = knockback_velocity
	else:
		# On ground / idle between jumps
		velocity = knockback_velocity
		if jump_cooldown <= 0.0:
			# Start next jump towards player!
			_start_jump(dir)

	move_and_slide()
	_process_animation(delta)

func _start_jump(dir: Vector2) -> void:
	is_jumping = true
	jump_target_dir = dir
	if sprite and abs(dir.x) > 0.05:
		sprite.scale.x = -1.0 if dir.x < 0 else 1.0
	_play_anim("jump")

func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_anim != "jump":
		return

	current_anim = anim_name
	current_frame = 0
	anim_timer = 0.0
	_apply_frame()

func _apply_frame() -> void:
	if not ANIM_ROWS.has(current_anim) or not sprite or not sprite.texture:
		return
	var row_data = ANIM_ROWS[current_anim]
	var row_idx = row_data["row"]
	var fsize = SIZE_FRAME_DIMS[slime_size]
	sprite.region_rect = Rect2(current_frame * fsize, row_idx * fsize, fsize, fsize)

func _process_animation(delta: float) -> void:
	if current_anim == "" or not ANIM_ROWS.has(current_anim):
		return

	var row_data = ANIM_ROWS[current_anim]
	var fps: float = row_data["fps"]
	var total_frames: int = row_data["frames"]
	var loop: bool = row_data["loop"]

	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer -= (1.0 / fps)
		current_frame += 1

		if current_frame >= total_frames:
			if current_anim == "death":
				current_frame = total_frames - 1
				current_anim = ""
				_apply_frame()
				_on_death_animation_finished()
				return
			elif current_anim == "jump":
				is_jumping = false
				match slime_size:
					SlimeSize.SMALL:
						jump_cooldown = randf_range(0.9, 1.4)
					SlimeSize.MEDIUM:
						jump_cooldown = randf_range(1.1, 1.6)
					SlimeSize.BIG:
						jump_cooldown = randf_range(1.3, 1.8)
					_:
						jump_cooldown = randf_range(1.0, 1.5)
				_play_anim("idle")
				return
			elif current_anim == "hurt":
				is_acting = false
				_play_anim("idle")
				return
			elif not loop:
				current_frame = 0
				_play_anim("idle")
				return
			else:
				current_frame = current_frame % total_frames

		_apply_frame()

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
	is_aggro = true # Provoke immediate aggro on hit
	
	# Audio feedback
	if AudioManager:
		AudioManager.play_sfx(preload("res://assets/audio/ui/sfx_pop.mp3"), randf_range(0.85, 1.15), 0.0)

	# Impact dust
	_spawn_impact_dust(global_position + Vector2(0, -4))

	# Всплывающий урон (обычный или критический)
	DamageNumber.spawn(get_parent(), global_position + Vector2(0, -14), amount, is_crit)

	# Red flash
	if sprite:
		var flash_tween = create_tween()
		sprite.modulate = Color(2.2, 0.4, 0.4, 1.0)
		flash_tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)

	# Knockback based on mass
	if knockback_dir != Vector2.ZERO:
		var impulse = knockback_dir
		if impulse.length_squared() <= 1.5:
			impulse = impulse.normalized() * 180.0
		knockback_velocity = impulse / max(0.1, mass)

	if hp <= 0:
		is_dead = true
		is_acting = true
		is_jumping = false
		is_paralyzed = false
		var pfx = get_node_or_null("ParalysisEffect")
		if pfx:
			pfx.queue_free()
		collision_layer = 0
		collision_mask = 0
		if hp_bar:
			hp_bar.visible = false
		GameStateManager.register_monster_killed()
		
		if slime_size in [SlimeSize.BIG, SlimeSize.MEDIUM]:
			# Immediately split with juicy burst!
			_spawn_impact_dust(global_position + Vector2(0, -6))
			_spawn_split_slimes()
			set_physics_process(false)
			if sprite:
				var pop_tween = create_tween()
				pop_tween.tween_property(sprite, "scale", Vector2(1.3, 0.3), 0.08)
				pop_tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.08)
				pop_tween.tween_callback(queue_free)
			else:
				queue_free()
		else:
			# Smallest slime plays death animation and drops loot
			_play_anim("death")
	else:
		is_acting = true
		is_jumping = false
		_play_anim("hurt")

func _on_death_animation_finished() -> void:
	set_physics_process(false)
	_spawn_loot()

	# Fade out corpse smoothly
	var fade_tween = create_tween()
	fade_tween.tween_property(self, "modulate:a", 0.0, 0.3)
	fade_tween.tween_callback(queue_free)

func _spawn_split_slimes() -> void:
	if has_split:
		return
	has_split = true

	var next_size = -1
	if slime_size == SlimeSize.BIG:
		next_size = SlimeSize.MEDIUM
	elif slime_size == SlimeSize.MEDIUM:
		next_size = SlimeSize.SMALL
	else:
		_spawn_loot()
		return

	var slime_scene = load("res://scenes/characters/slime.tscn")
	if not slime_scene: return

	# Split into 2 smaller slimes with juicy outward pop!
	var offsets = [-14.0, 14.0]
	for off_x in offsets:
		var child_slime = slime_scene.instantiate() as SlimeEnemy
		child_slime.global_position = global_position + Vector2(off_x * 0.5, randf_range(-2, 2))
		child_slime.setup_slime(next_size, slime_color)
		child_slime.knockback_velocity = Vector2(off_x * 8.0, randf_range(-60.0, -35.0))
		child_slime.is_aggro = true
		# Landing delay so they don't immediately jump on spawn
		child_slime.jump_cooldown = randf_range(0.8, 1.2)
		child_slime.touch_cooldown = 1.0
		get_parent().call_deferred("add_child", child_slime)

func _spawn_loot() -> void:
	var drop_scene = preload("res://scenes/objects/dropped_item.tscn")
	var drops = [
		{"id": "coin", "count": randi_range(1, 3)},
	]
	if randf() < 0.5:
		drops.append({"id": "stone", "count": 1})

	for d in drops:
		var drop = drop_scene.instantiate()
		drop.setup(d["id"], d["count"])
		drop.position = global_position + Vector2(randf_range(-6, 6), randf_range(-4, 4))
		get_parent().call_deferred("add_child", drop)

func interact(actor: Node2D) -> void:
	if is_dead:
		return
	var dir = actor.global_position.direction_to(global_position) if actor else Vector2.ZERO
	var dmg = 12 if InventoryManager.get_item_amount("stone_sword") > 0 else 6
	take_damage(dmg, dir)
