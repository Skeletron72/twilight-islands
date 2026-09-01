import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Change if current_target is Destructible or current_target is EnemySkeleton:
old_check = """		if current_target is Destructible or current_target is EnemySkeleton:"""
new_check = """		if current_target is Destructible or current_target is Stone or current_target is EnemySkeleton:"""

content = content.replace(old_check, new_check)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
