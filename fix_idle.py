import re

# Update player.gd
with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Replace WAITING with IDLE
content = content.replace('WAITING/base_waiting_strip9', 'IDLE/base_idle_strip9')
content = content.replace('WAITING/boots1_waiting_strip9', 'IDLE/boots1_idle_strip9')
content = content.replace('WAITING/cloth1_waiting_strip9', 'IDLE/cloth1_idle_strip9')
content = content.replace('WAITING/hair_merged_waiting_strip9', 'IDLE/hair_merged_idle_strip9')
content = content.replace('WAITING/tools_waiting_strip9', 'IDLE/tools_idle_strip9')

# Reduce speed
content = content.replace('@export var speed: float = 120.0', '@export var speed: float = 80.0')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)

# Update player.tscn
with open('scenes/characters/player/player.tscn', 'r') as f:
    content = f.read()

content = content.replace('WAITING/base_waiting_strip9', 'IDLE/base_idle_strip9')
content = content.replace('WAITING/boots1_waiting_strip9', 'IDLE/boots1_idle_strip9')
content = content.replace('WAITING/cloth1_waiting_strip9', 'IDLE/cloth1_idle_strip9')
content = content.replace('WAITING/hair_merged_waiting_strip9', 'IDLE/hair_merged_idle_strip9')
content = content.replace('WAITING/tools_waiting_strip9', 'IDLE/tools_idle_strip9')

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write(content)
