import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Remove hide code
content = re.sub(r'var hc = get_node_or_null.*?if sc: sc\.hide\(\)', '', content, flags=re.DOTALL)

# Remove health and stamina changed
content = re.sub(r'func _on_stamina_changed\(new_val: float, max_val: float\) -> void:.*?func _on_health_changed', 'func _on_health_changed', content, flags=re.DOTALL)
content = re.sub(r'func _on_health_changed\(new_val: float, max_val: float\) -> void:.*?func _on_player_died', 'func _on_player_died', content, flags=re.DOTALL)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
