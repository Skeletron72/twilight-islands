with open('scripts/autoloads/placement_manager.gd', 'r') as f:
    content = f.read()

content = content.replace('var ysort = get_tree().current_scene.get_node_or_null("WorldMap/YSort")', 'var ysort = get_tree().current_scene.get_node_or_null("Interactables")')

with open('scripts/autoloads/placement_manager.gd', 'w') as f:
    f.write(content)
