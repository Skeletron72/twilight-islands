import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Replace load(scene_path) with ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
content = content.replace('var obj_scene = load(scene_path)', 'var obj_scene = ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)')

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
