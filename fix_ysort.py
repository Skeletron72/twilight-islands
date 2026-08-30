import re

def enable_ysort(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Enable on root node
    content = re.sub(r'(\[node name="(HomeIsland|RaidIsland)" type="Node2D"[^\]]*\])', r'\1\ny_sort_enabled = true', content)
    
    # Enable on Interactables
    content = re.sub(r'(\[node name="Interactables" type="Node2D"[^\]]*\])', r'\1\ny_sort_enabled = true', content)
    
    # Check if Player node has it (not strictly necessary if root has it, but good practice)
    
    with open(filepath, 'w') as f:
        f.write(content)

enable_ysort('scenes/levels/home_island.tscn')
enable_ysort('scenes/levels/raid_island.tscn')
