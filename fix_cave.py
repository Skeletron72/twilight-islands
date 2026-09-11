import re

file_path = "scenes/objects/buildings/cave_entrance.tscn"
with open(file_path, "r") as f:
    content = f.read()

# Rename Sprite2D to EntranceSprite to avoid highlight
content = content.replace('name="Sprite2D"', 'name="EntranceSprite"')

# Change z_index of prompt in the script
script_path = "scripts/components/cave_entrance.gd"
with open(script_path, "r") as f:
    script = f.read()
    
script = script.replace('@onready var sprite: Sprite2D = $Sprite2D', '@onready var sprite: Sprite2D = $EntranceSprite')
script = script.replace('prompt_label.custom_minimum_size = Vector2(120, 16)', 'prompt_label.custom_minimum_size = Vector2(120, 16)\n\t\tprompt_label.z_index = 100')

with open(script_path, "w") as f:
    f.write(script)
    
with open(file_path, "w") as f:
    f.write(content)

print("Cave fixed")
