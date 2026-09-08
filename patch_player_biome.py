import re

with open("scripts/components/player.gd", "r") as f:
    content = f.read()

# Remove the local variable
content = content.replace('\tvar current_biome = ""\n', '')

# Add the class property at the top, near other vars
if 'var current_biome: String = "clearing"' not in content:
    content = content.replace('var current_anim: String = ""', 'var current_biome: String = "clearing"\nvar current_anim: String = ""')
    
with open("scripts/components/player.gd", "w") as f:
    f.write(content)
print("Patched player.gd")
