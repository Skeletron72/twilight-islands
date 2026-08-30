import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Add mining to anim_data
axe_block = """	"axe": {
		"frames": 10,
		"base": preload("res://assets/sprites/characters/Human/AXE/base_axe_strip10.png"),
		"boots": preload("res://assets/sprites/characters/Human/AXE/boots1_axe_strip10.png"),
		"cloth": preload("res://assets/sprites/characters/Human/AXE/cloth1_axe_strip10.png"),
		"hair": preload("res://assets/sprites/characters/Human/AXE/hair_merged_axe_strip10.png"),
		"tools": preload("res://assets/sprites/characters/Human/AXE/tools_axe_strip10.png")
	}"""
mining_block = """	"mining": {
		"frames": 10,
		"base": preload("res://assets/sprites/characters/Human/MINING/base_mining_strip10.png"),
		"boots": preload("res://assets/sprites/characters/Human/MINING/boots1_mining_strip10.png"),
		"cloth": preload("res://assets/sprites/characters/Human/MINING/cloth1_mining_strip10.png"),
		"hair": preload("res://assets/sprites/characters/Human/MINING/hair_merged_mining_strip10.png"),
		"tools": preload("res://assets/sprites/characters/Human/MINING/tools_mining_strip10.png")
	}"""

if '"mining": {' not in content:
    content = content.replace(axe_block, axe_block + ',\n' + mining_block)

# Update interaction logic
old_interact = """		if current_target is Destructible:
			is_acting = true
			_play_anim("axe")"""
new_interact = """		if current_target is Destructible:
			is_acting = true
			if current_target.resource_id == "wood":
				_play_anim("axe")
			else:
				_play_anim("mining")"""

content = content.replace(old_interact, new_interact)

# Update hit logic
old_hit = """		if current_anim == "axe" and current_frame == 6:"""
new_hit = """		if (current_anim == "axe" or current_anim == "mining") and current_frame == 6:"""

content = content.replace(old_hit, new_hit)

# Update end logic
old_end = """			if current_anim == "axe":"""
new_end = """			if current_anim == "axe" or current_anim == "mining":"""

content = content.replace(old_end, new_end)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
