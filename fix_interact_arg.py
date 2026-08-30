import re

with open('scripts/components/storage_box.gd', 'r') as f:
    content = f.read()

content = content.replace("func interact() -> void:", "func interact(player: Node2D) -> void:")

with open('scripts/components/storage_box.gd', 'w') as f:
    f.write(content)
