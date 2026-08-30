import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Replace direct identifier with node path
content = content.replace('TransitionManager.transition_to(', 'get_node("/root/TransitionManager").transition_to(')

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
