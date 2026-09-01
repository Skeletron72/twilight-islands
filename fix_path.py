import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace("Feet/OG_Shoes/Shoes_1_Brown.png", "Feet/Shoes_1_Brown.png")

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
