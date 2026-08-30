import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Remove the node assignments for sb and hb
content = re.sub(r'\tvar sb = get_node_or_null.*?GameStateManager\.current_health\n', '', content, flags=re.DOTALL)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
