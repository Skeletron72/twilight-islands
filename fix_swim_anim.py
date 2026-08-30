import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

swim_data = """	"swimming": {
		"frames": 8,
		"base": preload("res://assets/sprites/characters/Human/SWIMMING/base_swimming_strip8.png"),
		"boots": preload("res://assets/sprites/characters/Human/SWIMMING/boots1_swimming_strip8.png"),
		"cloth": preload("res://assets/sprites/characters/Human/SWIMMING/cloth1_swimming_strip8.png"),
		"hair": preload("res://assets/sprites/characters/Human/SWIMMING/hair_merged_swimming_strip8.png"),
		"tools": preload("res://assets/sprites/characters/Human/SWIMMING/tools_swimming_strip8.png")
	},
"""

# Insert after "walk": { ... },
pattern = r'(\t"walk": \{\n(?:\t\t[^\n]+\n){6}\t\},)'
content = re.sub(pattern, r'\1\n' + swim_data, content)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
