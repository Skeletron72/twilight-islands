import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Extract TimeContainer
time_pattern = r'(\[node name="TimeContainer" type="VBoxContainer" parent="\."\].*?horizontal_alignment = 1\n)'
time_match = re.search(time_pattern, content, flags=re.DOTALL)

if time_match:
    time_block = time_match.group(1)
    # Remove it from current position
    content = content.replace(time_block, '')
    
    # Insert it right before BookUI
    content = content.replace('[node name="BookUI"', time_block + '\n[node name="BookUI"')
    
    with open('scenes/ui/ui_layer.tscn', 'w') as f:
        f.write(content)
