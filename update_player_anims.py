import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

anim_additions = """	"attack": {
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
"""

content = content.replace('"axe": {', anim_additions + '\t"axe": {')

old_ready = """func _ready() -> void:
	InventoryManager.equipment_changed.connect(_update_equipment_visuals)"""
new_ready = """func _ready() -> void:
	GameStateManager.player_hurt.connect(_on_hurt)
	InventoryManager.equipment_changed.connect(_update_equipment_visuals)"""
content = content.replace(old_ready, new_ready)

hurt_func = """
func _on_hurt() -> void:
	is_acting = true
	_play_anim("hurt")
"""
content = content.replace('func _physics_process', hurt_func + '\nfunc _physics_process')

old_anim_end = """		if current_frame >= frames:
			if current_anim == "axe" or current_anim == "mining":
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame
		if (current_anim == "axe" or current_anim == "mining") and current_frame == 6:"""

new_anim_end = """		if current_frame >= frames:
			if current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame
		if current_anim in ["axe", "mining", "attack"] and current_frame == 6:"""

content = content.replace(old_anim_end, new_anim_end)

old_interact = """					if current_target is EnemySkeleton:
						_play_anim("axe") # Use axe for combat for now"""
new_interact = """					if current_target is EnemySkeleton:
						_play_anim("attack")"""

content = content.replace(old_interact, new_interact)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
