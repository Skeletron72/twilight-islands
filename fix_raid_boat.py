import re

with open('scenes/levels/raid_island.tscn', 'r') as f:
    content = f.read()

# Replace ExtResource("8_boat") with ExtResource("5_boat")
content = content.replace('instance=ExtResource("8_boat")]', 'instance=ExtResource("5_boat")]')

with open('scenes/levels/raid_island.tscn', 'w') as f:
    f.write(content)
