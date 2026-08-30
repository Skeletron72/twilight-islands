import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

content = content.replace('GameStateManager.consume_stamina(5.0):', 'GameStateManager.consume_stamina(15.0):')

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
