import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Add is_dead flag
content = content.replace('var is_acting: bool = false', 'var is_acting: bool = false\nvar is_dead: bool = false')

# Add death to anim_data
anim_additions = """	"death": {
		"frames": 13,
		"base": preload("res://assets/sprites/characters/Human/DEATH/base_death_strip13.png"),
		"boots": preload("res://assets/sprites/characters/Human/DEATH/boots1_death_strip13.png"),
		"cloth": preload("res://assets/sprites/characters/Human/DEATH/cloth1_death_strip13.png"),
		"hair": preload("res://assets/sprites/characters/Human/DEATH/hair_merged_death_strip13.png"),
		"tools": preload("res://assets/sprites/characters/Human/DEATH/tools_death_strip13.png")
	},
"""
content = content.replace('"attack": {', anim_additions + '\t"attack": {')

# Add connection for player_died
content = content.replace('GameStateManager.player_hurt.connect(_on_hurt)', 'GameStateManager.player_hurt.connect(_on_hurt)\n\tGameStateManager.player_died.connect(_on_died)')

# Update physics process
content = content.replace('func _physics_process(delta: float) -> void:', 'func _physics_process(delta: float) -> void:\n\tif is_dead:\n\t\t_process_animation(delta)\n\t\treturn\n')

# Hyper Armor for _on_hurt
old_hurt = """func _on_hurt() -> void:
	is_acting = true
	_play_anim("hurt")"""
new_hurt = """func _on_hurt() -> void:
	if is_dead: return
	if current_anim == "attack": return # Hyper Armor: не прерываем атаку при получении урона
	is_acting = true
	_play_anim("hurt")

func _on_died() -> void:
	is_dead = true
	is_acting = true
	_play_anim("death")"""
content = content.replace(old_hurt, new_hurt)

# Handle death animation end
old_anim_end = """		if current_frame >= frames:
			if current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames"""
new_anim_end = """		if current_frame >= frames:
			if current_anim == "death":
				current_frame = frames - 1 # Зависаем на последнем кадре смерти
			elif current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames"""
content = content.replace(old_anim_end, new_anim_end)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
