import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('GameStateManager.add_stamina(5.0 * delta)', 'GameStateManager.add_stamina(3.5 * delta)')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
