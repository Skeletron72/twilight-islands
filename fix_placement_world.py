with open('scripts/autoloads/placement_manager.gd', 'r') as f:
    content = f.read()

content = content.replace('var space = get_world_2d().direct_space_state', 'var space = ghost_sprite.get_world_2d().direct_space_state')

with open('scripts/autoloads/placement_manager.gd', 'w') as f:
    f.write(content)
