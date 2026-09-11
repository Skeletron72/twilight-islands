import random
import math

def test_generation():
    sw = 30
    sh = 24
    swall_y = sh - 5
    
    s_grid = [[1 for _ in range(sh)] for _ in range(sw)]
    
    # Entrance chamber in s_grid!
    scx = sw // 2
    er_x = random.randint(3, 4)
    er_y = random.randint(2, 3)
    ec_x = scx
    ec_y = swall_y + 2
    
    # Carve entrance chamber in s_grid
    for x in range(1, sw - 1):
        for y in range(swall_y + 1, sh - 1):
            dx = float(x - ec_x) / er_x
            dy = float(y - ec_y) / er_y
            dist = dx*dx + dy*dy
            noise = (math.sin(x * 1.5) + math.cos(y * 1.8)) * 0.2
            if dist + noise < 1.05:
                s_grid[x][y] = 0
                
    for x in range(scx - 3, scx + 2):
        for y in range(swall_y + 1, min(sh - 1, swall_y + 3)):
            s_grid[x][y] = 0

    # Scale 2x
    w = sw * 2
    h = sh * 2
    grid = [[s_grid[x//2][y//2] for y in range(h)] for x in range(w)]
    cx = scx * 2
    wall_y = swall_y * 2
    
    # South wall
    for dy in range(-3, 1):
        wy = wall_y + dy
        for x in range(max(1, cx - 12), cx - 1):
            grid[x][wy] = 1
        for x in range(cx + 2, min(w - 1, cx + 13)):
            grid[x][wy] = 1
            
    # Corridor (3 tiles wide)
    for dy in range(-8, 1):
        wy = wall_y + dy
        grid[cx - 1][wy] = 0
        grid[cx][wy] = 0
        grid[cx + 1][wy] = 0
        grid[cx - 2][wy] = 1
        grid[cx - 3][wy] = 1
        grid[cx + 2][wy] = 1
        grid[cx + 3][wy] = 1
        
    # Sanitization pass
    for p in range(2):
        for x in range(1, w - 1):
            for y in range(1, h - 1):
                if grid[x][y] == 1:
                    if grid[x-1][y] == 0 and grid[x+1][y] == 0:
                        grid[x][y] = 0
                    elif grid[x][y-1] == 0 and grid[x][y+1] == 0:
                        grid[x][y] = 0
                elif grid[x][y] == 0:
                    if x < cx - 2 or x > cx + 2 or y < wall_y - 8:
                        if grid[x-1][y] == 1 and grid[x+1][y] == 1:
                            grid[x][y] = 1
                        elif grid[x][y-1] == 1 and grid[x][y+1] == 1:
                            grid[x][y] = 1

    # Check for any 1-tile wall protrusions
    one_tile_protrusions = 0
    for x in range(1, w - 1):
        for y in range(1, h - 1):
            if grid[x][y] == 1:
                # If isolated 1-tile horizontal or vertical
                if grid[x-1][y] == 0 and grid[x+1][y] == 0:
                    one_tile_protrusions += 1
                if grid[x][y-1] == 0 and grid[x][y+1] == 0:
                    one_tile_protrusions += 1
                    
    return one_tile_protrusions, grid, cx, wall_y

protrusions, grid, cx, wall_y = test_generation()
print(f"1-tile wall protrusions found: {protrusions} (MUST BE 0!)")
assert protrusions == 0, "Protrusions must be 0!"
print("Test passed! Clean 2x2 minimum geometry guaranteed!")
