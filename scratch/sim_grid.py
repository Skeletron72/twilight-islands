import random

w = 80
h = 60
sw = w // 2
sh = h // 2

s_grid = [[1 for _ in range(sh)] for _ in range(sw)]

for x in range(2, sw - 2):
    for y in range(2, sh - 2):
        if random.random() > 0.47:
            s_grid[x][y] = 0

for i in range(4):
    new_s = [row[:] for row in s_grid]
    for x in range(1, sw - 1):
        for y in range(1, sh - 1):
            walls = sum(s_grid[x+dx][y+dy] for dx in (-1,0,1) for dy in (-1,0,1))
            if walls >= 5: new_s[x][y] = 1
            elif walls <= 3: new_s[x][y] = 0
    s_grid = new_s

scx = sw // 2
scy = sh // 2

for dx in range(-1, 2):
    for dy in range(-1, 2):
        s_grid[scx + dx][scy + dy] = 0

for y in range(sh // 2, scy + 1):
    s_grid[scx][y] = 0

# Scale by 2
grid = [[s_grid[x//2][y//2] for y in range(h)] for x in range(w)]

cx = w // 2
cy = h // 2

for dx in range(-4, 5):
    for dy in range(-3, 4):
        grid[cx + dx][cy + dy] = 0

for dx in range(-6, 6):
    for dy in range(-7, -4):
        grid[cx + dx][cy + dy] = 1

for dy in range(-12, -3):
    for dx in range(-1, 2):
        grid[cx + dx][cy + dy] = 0
    grid[cx - 2][cy + dy] = 1
    grid[cx - 3][cy + dy] = 1
    grid[cx + 2][cy + dy] = 1
    grid[cx + 3][cy + dy] = 1

for dx in range(-3, 3):
    grid[cx + dx][cy - 12] = 0

print("ASCII grid around (cx, cy):")
for dy in range(-14, 4):
    line = f"{dy:3d}: "
    for dx in range(-10, 11):
        x = cx + dx
        y = cy + dy
        c = "." if grid[x][y] == 0 else "#"
        if dx == 0 and dy == 0: c = "S"
        line += c
    print(line)
