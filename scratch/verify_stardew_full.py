import random
import math
from collections import deque

def generate_stardew_cave(sw, sh, swall_y):
    s_grid = [[1 for _ in range(sh)] for _ in range(sw)]
    
    cave_min_y = 2
    cave_max_y = swall_y - 2
    
    # 1. Place chambers across sectors (e.g. 3 columns x 2 rows, or 2x2 for smaller levels)
    cols = 3 if sw >= 40 else 2
    rows = 2
    chambers = []
    
    sec_w = (sw - 4) // cols
    sec_h = (cave_max_y - cave_min_y) // rows
    
    for c in range(cols):
        for r in range(rows):
            min_x = 2 + c * sec_w + 2
            max_x = 2 + (c + 1) * sec_w - 2
            min_y = cave_min_y + r * sec_h + 1
            max_y = cave_min_y + (r + 1) * sec_h - 1
            
            if min_x < max_x and min_y < max_y:
                cx = random.randint(min_x, max_x)
                cy = random.randint(min_y, max_y)
                rx = random.randint(4, max(5, sec_w // 2))
                ry = random.randint(3, max(4, sec_h // 2))
                chambers.append((cx, cy, rx, ry))
                
    # Also ensure an entrance chamber above swall_y
    scx = sw // 2
    entrance_chamber_y = swall_y - random.randint(3, 4)
    chambers.append((scx, entrance_chamber_y, random.randint(4, 6), random.randint(3, 4)))
    
    # 2. Carve all chambers with organic noise
    for cx, cy, rx, ry in chambers:
        for x in range(max(1, cx - rx - 2), min(sw - 1, cx + rx + 3)):
            for y in range(max(1, cy - ry - 2), min(swall_y - 1, cy + ry + 3)):
                dx = (x - cx) / float(rx)
                dy = (y - cy) / float(ry)
                dist = dx*dx + dy*dy
                noise = (math.sin(x * 1.3) + math.cos(y * 1.5)) * 0.18
                if dist + noise < 1.05:
                    s_grid[x][y] = 0

    # 3. Connect neighboring chambers with wide natural passages (width 2-3 in s_grid)
    for i in range(len(chambers)):
        x1, y1, _, _ = chambers[i]
        dists = []
        for j in range(len(chambers)):
            if i != j:
                x2, y2, _, _ = chambers[j]
                d = (x1 - x2)**2 + (y1 - y2)**2
                dists.append((d, j))
        dists.sort()
        
        # Connect to 2 closest chambers
        for _, j in dists[:2]:
            x2, y2, _, _ = chambers[j]
            cur_x, cur_y = x1, y1
            while (cur_x, cur_y) != (x2, y2):
                for bx in range(-1, 2):
                    for by in range(-1, 2):
                        nx, ny = cur_x + bx, cur_y + by
                        if 1 <= nx < sw - 1 and 1 <= ny < swall_y - 1:
                            s_grid[nx][ny] = 0
                dx = x2 - cur_x
                dy = y2 - cur_y
                if abs(dx) > abs(dy):
                    cur_x += 1 if dx > 0 else -1
                    if random.random() < 0.4 and dy != 0:
                        cur_y += 1 if dy > 0 else -1
                else:
                    cur_y += 1 if dy > 0 else -1
                    if random.random() < 0.4 and dx != 0:
                        cur_x += 1 if dx > 0 else -1
                cur_x = max(2, min(sw - 3, cur_x))
                cur_y = max(2, min(swall_y - 2, cur_y))

    # 4. Natural rock pillars in the center of big rooms
    for cx, cy, rx, ry in chambers:
        if rx >= 5 and ry >= 4 and random.random() < 0.6:
            s_grid[cx][cy] = 1
            if random.random() < 0.5 and cx + 1 < sw - 1:
                s_grid[cx + 1][cy] = 1

    # 5. Cellular automata smoothing pass (mild, 2 passes)
    for _ in range(2):
        new_s = [row[:] for row in s_grid]
        for x in range(1, sw - 1):
            for y in range(1, swall_y - 1):
                walls = sum(s_grid[x+dx][y+dy] for dx in (-1,0,1) for dy in (-1,0,1))
                if walls >= 6: new_s[x][y] = 1
                elif walls <= 2: new_s[x][y] = 0
        s_grid = new_s

    # 6. Straight corridor from swall_y to entrance chamber
    for y in range(swall_y, entrance_chamber_y, -1):
        s_grid[scx][y] = 0
        s_grid[scx][y - 1] = 0
        
    # 7. Flood-fill from entrance to guarantee 100% connectivity
    visited = [[False for _ in range(sh)] for _ in range(sw)]
    q = deque([(scx, swall_y)])
    visited[scx][swall_y] = True
    reachable = 0
    while q:
        x, y = q.popleft()
        reachable += 1
        for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
            nx, ny = x + dx, y + dy
            if 0 <= nx < sw and 0 <= ny < sh:
                if s_grid[nx][ny] == 0 and not visited[nx][ny]:
                    visited[nx][ny] = True
                    q.append((nx, ny))
                    
    for x in range(sw):
        for y in range(sh):
            if s_grid[x][y] == 0 and not visited[x][y]:
                s_grid[x][y] = 1

    return s_grid, reachable

for test in range(5):
    sw = random.randint(35, 60)
    sh = int(sw * 0.75)
    swall_y = sh - 5
    s_grid, count = generate_stardew_cave(sw, sh, swall_y)
    total_area = sw * swall_y
    fill_pct = (count / total_area) * 100
    print(f"Test {test+1}: size {sw}x{sh}, reachable floor cells: {count} ({fill_pct:.1f}% of cave area)")
