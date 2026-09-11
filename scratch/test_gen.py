import random
from collections import deque

def generate_dungeon(w, h):
    # w, h are even numbers
    sw = w // 2
    sh = h // 2
    
    # Entrance corridor X center in sw coordinates
    scx = sw // 2
    # Entrance wall Y in sh coordinates (near bottom)
    swall_y = sh - 4
    
    # 1. Initialize small grid with walls (1)
    s_grid = [[1 for _ in range(sh)] for _ in range(sw)]
    
    # 2. Fill cave area (top 75% of map) with noise
    for x in range(2, sw - 2):
        for y in range(2, swall_y - 1):
            if random.random() > 0.44:
                s_grid[x][y] = 0
                
    # 3. Cellular automata smoothing for natural cave shapes
    for _ in range(4):
        new_s = [row[:] for row in s_grid]
        for x in range(1, sw - 1):
            for y in range(1, swall_y - 1):
                walls = sum(s_grid[x+dx][y+dy] for dx in (-1,0,1) for dy in (-1,0,1))
                if walls >= 5: new_s[x][y] = 1
                elif walls <= 3: new_s[x][y] = 0
        s_grid = new_s

    # 4. Connect corridor: carve from entrance up into the cave until we hit a floor cell!
    # If we don't hit a floor cell by y = 4, carve into the center!
    connected = False
    for y in range(swall_y, 2, -1):
        s_grid[scx][y] = 0
        s_grid[scx][y-1] = 0
        # Check if we hit an existing cave opening
        if y < swall_y - 2 and (s_grid[scx-1][y] == 0 or s_grid[scx+1][y] == 0 or s_grid[scx][y-1] == 0):
            # We reached the cave!
            connected = True
            break
            
    # Also carve a small room around the end of the corridor if needed
    for dx in (-1, 0, 1):
        for dy in (-1, 0, 1):
            if y + dy > 1:
                s_grid[scx + dx][y + dy] = 0

    # 5. Flood fill from corridor to find all reachable cells
    visited = [[False for _ in range(sh)] for _ in range(sw)]
    q = deque([(scx, swall_y)])
    visited[scx][swall_y] = True
    reachable_count = 0
    
    while q:
        cx, cy = q.popleft()
        reachable_count += 1
        for dx, dy in [(-1,0), (1,0), (0,-1), (0,1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < sw and 0 <= ny < sh:
                if s_grid[nx][ny] == 0 and not visited[nx][ny]:
                    visited[nx][ny] = True
                    q.append((nx, ny))
                    
    # Fill any unreachable floor with wall!
    for x in range(sw):
        for y in range(sh):
            if s_grid[x][y] == 0 and not visited[x][y]:
                s_grid[x][y] = 1
                
    # 6. Scale by 2 to full grid
    grid = [[s_grid[x//2][y//2] for y in range(h)] for x in range(w)]
    
    # 7. Now construct the entrance room and south wall in full resolution!
    cx = scx * 2
    wall_y = swall_y * 2
    
    # Entrance room below wall_y:
    # Wall is at wall_y. South of wall_y is the entrance room!
    # Clear entrance room: from wall_y + 1 to h - 2, and cx - 6 to cx + 6
    for x in range(cx - 6, cx + 7):
        for y in range(wall_y + 1, min(wall_y + 6, h - 2)):
            if 0 <= x < w and 0 <= y < h:
                grid[x][y] = 0
                
    # Build clean horizontal south wall:
    # From wall_y - 3 to wall_y:
    # Left side: from cx - 8 to cx - 2
    # Right side: from cx + 2 to cx + 8
    for dy in range(-3, 1): # wall_y - 3, wall_y - 2, wall_y - 1, wall_y
        wy = wall_y + dy
        # Left wall
        for x in range(max(0, cx - 8), cx - 1):
            grid[x][wy] = 1
        # Right wall
        for x in range(cx + 2, min(w, cx + 9)):
            grid[x][wy] = 1
            
    # Guarantee corridor is exactly 3 tiles wide (cx - 1, cx, cx + 1)
    # from wall_y down to wall_y - 6:
    for dy in range(-6, 1):
        wy = wall_y + dy
        for x in (cx - 1, cx, cx + 1):
            grid[x][wy] = 0
        grid[cx - 2][wy] = 1
        grid[cx - 3][wy] = 1
        grid[cx + 2][wy] = 1
        grid[cx + 3][wy] = 1
        
    return grid, cx, wall_y

grid, cx, wall_y = generate_dungeon(80, 60)
print(f"Generated successfully! cx={cx}, wall_y={wall_y}")
print("ASCII grid around entrance:")
for y in range(wall_y - 10, wall_y + 6):
    line = f"{y:2d}: "
    for x in range(cx - 10, cx + 11):
        c = "." if grid[x][y] == 0 else "#"
        line += c
    print(line)
