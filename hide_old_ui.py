import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

hide_code = """
	var hc = get_node_or_null("MarginContainer/VBoxContainer/HealthContainer")
	if hc: hc.hide()
	var sc = get_node_or_null("MarginContainer/VBoxContainer/StaminaContainer")
	if sc: sc.hide()
"""

content = content.replace('func _ready() -> void:', 'func _ready() -> void:\n' + hide_code)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
