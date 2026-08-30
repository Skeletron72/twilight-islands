import re

with open('scripts/components/skeleton.gd', 'r') as f:
    content = f.read()

new_skeleton = """extends Area2D
class_name EnemySkeleton

@export var speed: float = 35.0
@export var damage: int = 15
@export var max_hp: int = 20

var hp: int = max_hp
var player: Player = null
@onready var sprite: Sprite2D = $Sprite2D

var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 8.0

var walk_tex = preload("res://assets/sprites/characters/Skeleton/skeleton_walk_strip8.png")

var attack_cooldown: float = 0.0

func _ready() -> void:
	# Convert to Area2D that can be targeted by player
	add_to_group("interactable") 
	collision_layer = 4 # Enemies layer
	collision_mask = 1 # Player layer
	
	sprite.texture = walk_tex
	sprite.hframes = 8
	
	await get_tree().create_timer(0.5).timeout
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player):
		return
		
	var dist = global_position.distance_to(player.global_position)
	if dist > 15.0:
		var dir = global_position.direction_to(player.global_position)
		global_position += dir * speed * delta
		sprite.scale.x = -1 if dir.x < 0 else 1
		
		# Animation loop
		anim_timer += delta
		if anim_timer >= 1.0 / fps:
			anim_timer -= (1.0 / fps)
			current_frame = (current_frame + 1) % sprite.hframes
			sprite.frame = current_frame
	else:
		# Attack player
		if attack_cooldown <= 0:
			GameStateManager.take_damage(damage)
			attack_cooldown = 1.0
			
	if attack_cooldown > 0:
		attack_cooldown -= delta

func take_damage(amount: int, knockback_dir: Vector2 = Vector2.ZERO) -> void:
	hp -= amount
	
	# Flash red
	var tween = create_tween()
	sprite.modulate = Color(1, 0, 0, 1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	# Knockback
	global_position += knockback_dir * 15.0
	
	if hp <= 0:
		die()

func die() -> void:
	# Could spawn loot here
	queue_free()

# Make it act as a target for the player
func interact(actor: Node2D) -> void:
	var dir = actor.global_position.direction_to(global_position)
	take_damage(10, dir)
"""

with open('scripts/components/skeleton.gd', 'w') as f:
    f.write(new_skeleton)
