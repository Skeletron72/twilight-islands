import re

def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Change CanvasLayer to Control
    content = content.replace('type="CanvasLayer"', 'type="Control"')
    
    # Remove layer = ...
    content = re.sub(r'\nlayer = \d+', '', content)
    
    # Ensure it fills the screen (anchors)
    anchors = """
layout_mode = 3
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2"""

    if 'layout_mode = 3' not in content:
        # insert anchors after the first node definition
        content = re.sub(r'(\[node name="[^"]+" type="Control"[^\]]*\]\n(?:visible = false\n)?)', r'\1' + anchors + '\n', content, count=1)

    with open(filepath, 'w') as f:
        f.write(content)

fix('scenes/ui/book_ui.tscn')
fix('scenes/ui/mobile_controls.tscn')
