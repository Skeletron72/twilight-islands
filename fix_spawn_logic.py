import re

with open('scripts/components/resource_spawner.gd', 'r') as f:
    content = f.read()

# Remove the line that rejects spawning if WaterLayer has a tile underneath the ground
content = re.sub(r'\n\tif water and water\.get_cell_source_id\(map_pos\) != -1: return false', '', content)

# Remove the sand check just in case, because atlas coords might be different
content = re.sub(r'\n\t\tvar coords = ground\.get_cell_atlas_coords\(map_pos\)\n\t\tif coords\.y >= 12: \n\t\t\treturn false ', '', content)

with open('scripts/components/resource_spawner.gd', 'w') as f:
    f.write(content)
