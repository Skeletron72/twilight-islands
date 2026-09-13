extends Node2D
class_name LightningStrike

## LightningStrike - контроллер удара молнии по земле с телеграфом, уроном и статусом паралича.
## Поддерживает фиолетовый фильтр для сумеречного шторма.

const TELEGRAPH_TEXTURE = preload("res://assets/sprites/vfx/lightning/Lightning Yellow/impact_lightning 1_Y_sheet.png")
const BOLT_TEXTURE = preload("res://assets/sprites/vfx/lightning/Lightning Yellow/lightning_thunderbolt_Y_sheet.png")
const SFX_EXPLOSION = preload("res://assets/audio/sfx/combat/explosion.mp3")

enum Phase { TELEGRAPH, STRIKE, FINISHED }
var current_phase: Phase = Phase.TELEGRAPH

var is_twilight: bool = false

# Тайминги и параметры
var telegraph_duration: float = 0.92
var timer: float = 0.0
var strike_frame: int = 0
var strike_timer: float = 0.0
const STRIKE_FRAME_DURATION: float = 0.042

var blast_radius: float = 34.0
var damage_player: float = 25.0
var damage_mobs: int = 35
var paralysis_player: float = 2.2
var paralysis_mobs: float = 3.0

var telegraph_sprite: Sprite2D
var bolt_sprite: Sprite2D
var has_dealt_damage: bool = false

func _ready() -> void:
	z_as_relative = false
	
	# Спрайт телеграфа (потрескивание земли)
	telegraph_sprite = Sprite2D.new()
	telegraph_sprite.name = "TelegraphSprite"
	telegraph_sprite.texture = TELEGRAPH_TEXTURE
	telegraph_sprite.hframes = 6
	telegraph_sprite.vframes = 1
	telegraph_sprite.frame = 0
	telegraph_sprite.offset = Vector2(0, -10)
	telegraph_sprite.scale = Vector2(1.15, 1.15)
	telegraph_sprite.z_index = 2050
	
	if is_twilight:
		telegraph_sprite.modulate = Color(1.35, 0.45, 1.9, 0.95)
	else:
		telegraph_sprite.modulate = Color(1.4, 1.3, 0.75, 0.95)
		
	add_child(telegraph_sprite)
	
	# Спрайт ниспадающей молнии
	bolt_sprite = Sprite2D.new()
	bolt_sprite.name = "BoltSprite"
	bolt_sprite.texture = BOLT_TEXTURE
	bolt_sprite.hframes = 10
	bolt_sprite.vframes = 1
	bolt_sprite.frame = 0
	bolt_sprite.offset = Vector2(0, -10)
	bolt_sprite.scale = Vector2(1.3, 1.8)
	bolt_sprite.z_index = 2600
	
	if is_twilight:
		bolt_sprite.modulate = Color(1.4, 0.55, 2.1, 1.0)
	else:
		bolt_sprite.modulate = Color(1.3, 1.3, 1.0, 1.0)
		
	bolt_sprite.visible = false
	add_child(bolt_sprite)

func _process(delta: float) -> void:
	match current_phase:
		Phase.TELEGRAPH:
			_process_telegraph(delta)
		Phase.STRIKE:
			_process_strike(delta)

func _process_telegraph(delta: float) -> void:
	timer += delta
	var frame_idx = int(timer * 11.0) % 6
	telegraph_sprite.frame = frame_idx
	
	# Нарастание яркости к моменту удара
	var progress = clamp(timer / telegraph_duration, 0.0, 1.0)
	var glow = 1.0 + progress * 0.85
	
	if is_twilight:
		telegraph_sprite.modulate = Color(1.2 * glow, 0.45 * glow, 1.8 * glow, 0.85 + progress * 0.15)
	else:
		telegraph_sprite.modulate = Color(1.2 * glow, 1.1 * glow, 0.7 * glow, 0.85 + progress * 0.15)
	
	if timer >= telegraph_duration:
		_start_strike()

func _start_strike() -> void:
	current_phase = Phase.STRIKE
	telegraph_sprite.visible = false
	bolt_sprite.visible = true
	bolt_sprite.frame = 0
	strike_frame = 0
	strike_timer = 0.0
	
	if AudioManager:
		var pitch = randf_range(0.68, 0.78) if is_twilight else randf_range(0.72, 0.84)
		AudioManager.play_spatial_sfx(SFX_EXPLOSION, global_position, pitch, 5.5, 750.0)
		
	var weather_fx = get_tree().get_first_node_in_group("weather_effects")
	if not weather_fx:
		weather_fx = get_tree().current_scene.find_child("WeatherEffects", true, false)
	if weather_fx and weather_fx.has_method("trigger_lightning_flash"):
		weather_fx.trigger_lightning_flash(is_twilight)

	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		var dist = global_position.distance_to(player.global_position)
		if dist < 380.0:
			var shake_strength = lerp(7.5, 1.5, dist / 380.0)
			if player.has_method("shake_camera"):
				player.shake_camera(shake_strength, 0.3)

func _process_strike(delta: float) -> void:
	strike_timer += delta
	var frame = int(strike_timer / STRIKE_FRAME_DURATION)
	
	if frame >= 3 and not has_dealt_damage:
		has_dealt_damage = true
		_apply_blast_damage_and_paralysis()
		
	if frame >= 10:
		current_phase = Phase.FINISHED
		queue_free()
	else:
		bolt_sprite.frame = frame

func _apply_blast_damage_and_paralysis() -> void:
	# 1. Проверка попадания по игроку
	var player = get_tree().get_first_node_in_group("player")
	if player and is_instance_valid(player):
		if not player.get("is_dead") and global_position.distance_to(player.global_position) <= blast_radius:
			if player.has_method("take_damage"):
				player.take_damage(damage_player, global_position)
			if player.has_method("apply_paralysis"):
				player.apply_paralysis(paralysis_player, is_twilight)

	# 2. Проверка попадания по мобам
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if is_instance_valid(enemy) and not enemy.get("is_dead"):
			if global_position.distance_to(enemy.global_position) <= blast_radius:
				var hit_dir = (enemy.global_position - global_position).normalized()
				if hit_dir == Vector2.ZERO: hit_dir = Vector2.DOWN
				if enemy.has_method("take_damage"):
					enemy.take_damage(damage_mobs, hit_dir)
				if enemy.has_method("apply_paralysis"):
					enemy.apply_paralysis(paralysis_mobs, is_twilight)
					
	# 3. Нейтральные сущности
	var chickens = get_tree().get_nodes_in_group("chickens")
	for ch in chickens:
		if is_instance_valid(ch):
			if global_position.distance_to(ch.global_position) <= blast_radius:
				if ch.has_method("apply_paralysis"):
					ch.apply_paralysis(paralysis_mobs, is_twilight)
