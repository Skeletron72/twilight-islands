import re

with open('scenes/ui/ui_layer.tscn', 'r') as f:
    content = f.read()

# Remove the HealthContainer node block
content = re.sub(r'\[node name="HealthContainer" type="VBoxContainer".*?\[node name="StaminaContainer"', '[node name="StaminaContainer"', content, flags=re.DOTALL)

# Remove the StaminaContainer node block
content = re.sub(r'\[node name="StaminaContainer" type="VBoxContainer".*?\[node name="MobileControls"', '[node name="MobileControls"', content, flags=re.DOTALL)

# Remove the unused subresources to be clean
content = re.sub(r'\[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_health_bg"\].*?\[node name="UILayer"', '[node name="UILayer"', content, flags=re.DOTALL)

with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(content)
