import re

with open('scripts/components/destructible.gd', 'r') as f:
    content = f.read()

# Tweak shake
shake_pattern = r'(shake_tween\.tween_property\(sprite, "position:x", orig_pos\.x \+ )3\.0(, 0\.03\)\n\t\tshake_tween\.tween_property\(sprite, "position:x", orig_pos\.x - )3\.0(, 0\.04\)\n\t\tshake_tween\.tween_property\(sprite, "position:x", orig_pos\.x \+ )2\.0(, 0\.04\)\n\t\tshake_tween\.tween_property\(sprite, "position:x", orig_pos\.x, )0\.03(\))'
content = re.sub(shake_pattern, r'\1 1.5\2 1.5\3 1.0\4 0.04\5', content)

# Add hp_variance
if '@export var hp_variance: int = 0' not in content:
    content = content.replace('@export var max_hp: int = 3', '@export var max_hp: int = 3\n@export var hp_variance: int = 0')

# Apply hp_variance in _ready
if 'max_hp += randi_range(-hp_variance, hp_variance)' not in content:
    ready_pattern = r'(func _ready\(\) -> void:\n\tsuper\._ready\(\)\n\tcollision_layer = 2\n\t)current_hp = max_hp'
    content = re.sub(ready_pattern, r'\1if hp_variance > 0:\n\t\tmax_hp += randi_range(-hp_variance, hp_variance)\n\tcurrent_hp = max_hp', content)

with open('scripts/components/destructible.gd', 'w') as f:
    f.write(content)

