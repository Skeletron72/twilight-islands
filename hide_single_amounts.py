import re

with open('scripts/components/hotbar_ui.gd', 'r') as f:
    content = f.read()

content = content.replace('lbl.show()', 'if amount > 1: lbl.show()\n\t\telse: lbl.hide()')

with open('scripts/components/hotbar_ui.gd', 'w') as f:
    f.write(content)
