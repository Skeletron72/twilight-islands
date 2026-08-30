import re

with open('scripts/components/storage_ui.gd', 'r') as f:
    content = f.read()

content = content.replace("GameStateManager.inventory_changed.connect", "InventoryManager.inventory_changed.connect")

with open('scripts/components/storage_ui.gd', 'w') as f:
    f.write(content)
