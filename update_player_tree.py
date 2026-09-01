import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

old_check = """if current_target is Stone or current_target is EnemySkeleton:"""
new_check = """if current_target is Stone or current_target is EnemySkeleton or current_target is TreeObject:"""
content = content.replace(old_check, new_check)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
