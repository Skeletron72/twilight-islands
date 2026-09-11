import re

file_path = "scripts/components/biome_service.gd"
with open(file_path, "r") as f:
    content = f.read()

new_mapping = """const TERRAIN_TO_BIOME: Dictionary = {
	0: "clearing",      # Базовая трава
	1: "clearing",      # Dirt (дорожка в траве)
	2: "beach",         # Sand (песок)
	3: "water",         # Water
	4: "water",         # Stone Water
	5: "clearing",      # FarmLand
	6: "forest",        # Лесная трава
	7: "dry",           # Сухая трава
	8: "magic",         # Волшебная трава
	9: "clearing",      # Горы (Луговые стены)
	10: "forest",       # Горы (Лесные стены)
	11: "dry",          # Горы (Сухие стены)
	12: "magic",        # Горы (Волшебные стены)
	13: "clearing",     # Горы (Луговая поляна)
	14: "forest",       # Горы (Лесная поляна)
	15: "dry",          # Горы (Сухая поляна)
	16: "magic"         # Горы (Волшебная поляна)
}"""

# Replace the dictionary
pattern = r"const TERRAIN_TO_BIOME: Dictionary = \{.*?\}"
content = re.sub(pattern, new_mapping, content, flags=re.DOTALL)

with open(file_path, "w") as f:
    f.write(content)
print("Biomes mapped")
