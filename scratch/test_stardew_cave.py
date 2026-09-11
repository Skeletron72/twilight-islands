import random
import math
from collections import deque

def generate_stardew_cave(sw, sh, swall_y):
    # s_grid initialized with 1 (rock)
    s_grid = [[1 for _ in range(sh)] for _ in range(sw)]
    
    # We want spacious, natural, interconnected cave chambers in the area y in [2, swall_y - 2]
    cave_min_y = 2
    cave_max_y = swall_y - 2
    cave_h = cave_max_y - cave_min_y
    cave_w = sw - 4
    
    # 1. Generate 3 to 6 large cave centers (chambers)
    num_chambers = random.randint(4, 7)
    chambers = []
    
    # Ensure at least one chamber near the entrance (above swall_y)
    entrance_chamber_x = sw // 2
    entrance_chamber_y = swall_y - random.randint(3, 5)
    chambers.append((entrance_chamber_x, entrance_chamber_y, random.randint(4, 7), random.randint(4, 7)))
    
    # Other chambers spread out
    for _ in range(num_chambers - 1):
        cx = random.randint(4, sw - 5)
        cy = random.randint(cave_min_y + 2, cave_max_y - 2)
        rx = random.randint(4, 8)
        ry = random.randint(3, 7)
        chambers.append((cx, cy, rx, ry))
        
    # Carve chambers using organic noisy ellipses
    for cx, cy, rx, ry in chambers:
        for x in range(max(1, cx - rx - 2), min(sw - 1, cx + rx + 3)):
            for y in range(max(1, cy - ry - 2), min(swall_y - 1, cy + ry + 3)):
                # Distance formula with noise for natural rugged edges
                dx = (x - cx) / float(rx)
                dy = (y - cy) / float(ry)
                dist = dx*dx + dy*dy
                # Add irregular border noise
                noise = (math.sin(x * 1.5) + math.cos(y * 1.7)) * 0.15
                if dist + noise < 1.05:
                    s_grid[x][y] = 0
                    
    # 2. Connect chambers with wide, winding natural corridors (Random Walk / Carve)
    # Connect sequentially and with a few cross-connections
    for i in range(len(chambers)):
        # Connect to next chamber, and optionally to another random chamber
        targets = [(i + 1) % len(chambers)]
        if random.random() < 0.5:
            targets.append(random.randint(0, len(chambers) - 1))
            
        x1, y1, _, _ = chambers[i]
        for t in targets:
            x2, y2, _, _ = chambers[t]
            # Carve winding path from (x1, y1) to (x2, y2)
            cur_x, cur_y = x1, y1
            while (cur_x, cur_y) != (x2, y2):
                # Carve brush of radius 1-2 in s_grid (which is 2-4 in full grid!)
                for bx in range(-1, 2):
                    for by in range(-1, 2):
                        nx, ny = cur_x + bx, cur_y + by
                        if 1 <= nx < sw - 1 and 1 <= ny < swall_y - 1:
                            s_grid[nx][ny] = 0
                            
                # Step towards target with small random jitter for natural winding feel
                dx = x2 - cur_x
                dy = y2 - cur_y
                if abs(dx) > abs(dy):
                    step_x = 1 if dx > 0 else -1
                    step_y = 1 if dy > 0 else (-1 if dy < 0 else (1 if random.random()<0.3 else 0))
                else:
                    step_y = 1 if dy > 0 else -1
                    step_x = 1 if dx > 0 else (-1 if dx < 0 else (1 if random.random()<0.3 else 0))
                    
                cur_x += step_x
                cur_y += step_y
                cur_x = max(2, min(sw - 3, cur_x))
                cur_y = max(2, min(swall_y - 2, cur_y))

    # 3. Sprinkle internal rock pillars / clusters in large open areas (Stardew-style)
    for cx, cy, rx, ry in chambers:
        if rx >= 6 and ry >= 5 and random.random() < 0.7:
            # Place an organic rock pillar in the middle
            px = cx + random.randint(-1, 1)
            py = cy + random.randint(-1, 1)
            s_grid[px][py] = 1
            if random.random() < 0.5:
                s_grid[px+1][py] = 1

    # 4. Cellular automata pass to smooth the natural cave walls
    for _ in range(2):
        new_s = [row[:] for row in s_grid]
        for x in range(1, sw - 1):
            for y in range(1, swall_y - 1):
                walls = sum(s_grid[x+dx][y+dy] for dx in (-1,0,1) for dy in (-1,0,1))
                if walls >= 6: new_s[x][y] = 1
                elif walls <= 2: new_s[x][y] = 0
        s_grid = new_s

    # 5. Connect corridor from south wall (swall_y) straight up to entrance chamber
    scx = sw // 2
    for y in range(swall_y, entrance_chamber_y, -1):
        s_grid[scx][y] = 0
        s_grid[scx][y-1] = 0

    return s_grid

# Let's test on sw=40, sh=30, swall_y=25
sw, sh, swall_y = 40, 30, 25
s_grid = generate_stardew_cave(sw, sh, swall_y)

# Print ASCII
print("Spacious Natural Cave (s_grid 40x25):")
for y in range(swall_y + 1):
    line = f"{y:2d}: "
    for x in range(sw):
        line += "." if s_grid[x][y] == 0 else "#"
    print(line)
