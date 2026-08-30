with open('project.godot', 'r') as f:
    content = f.read()

content = content.replace('[autoload]', '[autoload]\nPlacementManager="*res://scripts/autoloads/placement_manager.gd"')

with open('project.godot', 'w') as f:
    f.write(content)
