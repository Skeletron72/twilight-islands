import re

with open('scenes/ui/mobile_controls.tscn', 'r') as f:
    content = f.read()

content = content.replace('[node name="MobileControls" type="CanvasLayer"]\n', '[node name="MobileControls" type="CanvasLayer"]\nvisible = false\n')

with open('scenes/ui/mobile_controls.tscn', 'w') as f:
    f.write(content)
