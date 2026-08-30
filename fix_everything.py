import re

# 1. Fix ui_layer.tscn
with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# I will just insert the root node before BookToggleContainer
content = content.replace('[node name="BookToggleContainer"', '[node name="UILayer" type="CanvasLayer"]\nscript = ExtResource("1_ui")\n\n[node name="BookToggleContainer"')

# Also fix the ext_resource paths to ensure they match what's actually there
# The user's log showed warning: "invalid UID... using text path instead"
# Because my script used dummy UIDs. Godot will regenerate them on save, but the path must be correct!
content = content.replace('path="res://resources/items/UI.png"', 'path="res://assets/sprites/ui/inventory/UI.png"')

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)

# 2. Fix ui_manager.gd
with open('scripts/components/ui_manager.gd', 'r') as f:
    ui = f.read()

ui = ui.replace('preload("res://resources/items/UI.png")', 'preload("res://assets/sprites/ui/inventory/UI.png")')

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(ui)

