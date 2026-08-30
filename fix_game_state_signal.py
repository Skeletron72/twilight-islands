import re

with open('scripts/autoloads/game_state_manager.gd', 'r') as f:
    content = f.read()

# Add signal item_consumed(color)
if "signal item_consumed(color: Color)" not in content:
    content = content.replace('signal hunger_changed(new_value: float, max_value: float)', 'signal hunger_changed(new_value: float, max_value: float)\nsignal item_consumed(color: Color)')
    with open('scripts/autoloads/game_state_manager.gd', 'w') as f:
        f.write(content)
