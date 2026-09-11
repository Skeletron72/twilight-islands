import re

file_path = "scripts/components/day_night_cycle.gd"
with open(file_path, "r") as f:
    content = f.read()

content = re.sub(r'\t\tif sun:.*?\n\t\t\ttween.tween_property\(sun, "shadow_color".*?\n', '', content, flags=re.DOTALL)

with open(file_path, "w") as f:
    f.write(content)
print("Fixed day_night_cycle.gd")
