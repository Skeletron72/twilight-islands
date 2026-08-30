import re

def add_spawner_to_scene(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # Add script resource
    script_res = '[ext_resource type="Script" path="res://scripts/components/resource_spawner.gd" id="spawner_script"]\n'
    if 'id="spawner_script"' not in content:
        content = content.replace('[node name=', script_res + '\n[node name=', 1)
        
    # Add node
    node_str = '\n[node name="ResourceSpawner" type="Node2D" parent="."]\nscript = ExtResource("spawner_script")\n'
    if 'name="ResourceSpawner"' not in content:
        content += node_str
        
    with open(filepath, 'w') as f:
        f.write(content)

add_spawner_to_scene('scenes/levels/home_island.tscn')
add_spawner_to_scene('scenes/levels/raid_island.tscn')
