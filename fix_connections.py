import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Remove the lines connecting signals
content = content.replace('GameStateManager.stamina_changed.connect(_on_stamina_changed)\n', '')
content = content.replace('\tGameStateManager.health_changed.connect(_on_health_changed)\n', '')
content = content.replace('GameStateManager.health_changed.connect(_on_health_changed)\n', '')

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
