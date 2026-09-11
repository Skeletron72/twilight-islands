import re

# 1. Update cave_entrance.tscn
tscn_path = "scenes/objects/buildings/cave_entrance.tscn"
with open(tscn_path, "r") as f:
    tscn = f.read()

# Add position to EntranceSprite
sprite_pattern = r'(\[node name="EntranceSprite".*?\]\n)'
tscn = re.sub(sprite_pattern, r'\1position = Vector2(0, 48)\n', tscn)

# Shift CollisionPolygon2D
# polygon = PackedVector2Array(-24, -16, -24, -48, 24, -48, 24, -17, 13, -17, 13, -29, -13, -29, -13, -16)
# shifted: -24, 32, -24, 0, 24, 0, 24, 31, 13, 31, 13, 19, -13, 19, -13, 32
poly_pattern = r'polygon = PackedVector2Array\((.*?)\)'
def shift_points(match):
    points = [int(p.strip()) for p in match.group(1).split(',')]
    for i in range(1, len(points), 2):
        points[i] += 48
    return 'polygon = PackedVector2Array(' + ', '.join(str(p) for p in points) + ')'
tscn = re.sub(poly_pattern, shift_points, tscn)

# Add position to InteractionArea
area_pattern = r'(\[node name="InteractionArea".*?\]\n)'
tscn = re.sub(area_pattern, r'\1position = Vector2(0, 48)\n', tscn)

with open(tscn_path, "w") as f:
    f.write(tscn)


# 2. Update home_island.tscn
home_path = "scenes/levels/home_island.tscn"
with open(home_path, "r") as f:
    home = f.read()
    
# Remove z_index and z_as_relative for CaveEntrance
home = re.sub(r'z_index = 150\nz_as_relative = false\n', '', home)
# Shift position from 150 to 102
home = re.sub(r'\[node name="CaveEntrance" (.*?)\]\nposition = Vector2\((.*?)\)', 
              lambda m: f'[node name="CaveEntrance" {m.group(1)}]\nposition = Vector2({m.group(2).split(",")[0]}, {int(m.group(2).split(",")[1]) - 48})', 
              home)

with open(home_path, "w") as f:
    f.write(home)
    
print("Y-sort fixed")
