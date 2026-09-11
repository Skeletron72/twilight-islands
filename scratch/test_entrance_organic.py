import random
import math

w = 60
h = 45
cx = w // 2
wall_y = 30

grid = [[1 for _ in range(h)] for _ in range(w)]

# Organic entrance chamber
# Center of the entrance chamber:
ec_x = cx
ec_y = wall_y + 4
rx = random.randint(7, 10)
ry = random.randint(4, 6)

# Carve organic natural room
for x in range(cx - rx - 3, cx + rx + 4):
    for y in range(wall_y + 1, min(h - 2, wall_y + ry * 2 + 2)):
        if 1 <= x < w - 1 and 1 <= y < h - 1:
            dx = float(x - ec_x) / rx
            dy = float(y - ec_y) / ry
            dist = dx*dx + dy*dy
            noise = (math.sin(x * 1.4) + math.cos(y * 1.6)) * 0.22
            if dist + noise < 1.05:
                grid[x][y] = 0

# Guarantee clean floor in front of doorway (cx-5..cx-4) and support (cx-2..cx+2)
for x in range(cx - 6, cx + 3):
    for y in range(wall_y + 1, wall_y + 4):
        grid[x][y] = 0

# Solid south wall
for dy in range(-3, 1):
    wy = wall_y + dy
    for x in range(max(1, cx - 12), cx - 1):
        grid[x][wy] = 1
    for x in range(cx + 2, min(w - 1, cx + 13)):
        grid[x][wy] = 1

print("ASCII Organic Entrance Room:")
for y in range(wall_y - 2, min(h, wall_y + 12)):
    line = f"{y:2d}: "
    for x in range(cx - 12, cx + 13):
        line += "." if grid[x][y] == 0 else "#"
    print(line)
