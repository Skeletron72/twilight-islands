from test_gen import generate_dungeon

w, h = 80, 60
grid, cx, wall_y = generate_dungeon(w, h)

# Let's check the neighbors at (x, y) around wall_y
# mapping currently in dungeon_generator.gd:
# Внешние углы:
# f_n and f_w: (4, 3)
# f_n and f_e: (5, 3)
# f_s and f_w: (4, 4)
# f_s and f_e: (5, 4)
# Прямые края:
# f_n: (5, 2)
# f_s: (5, 0)
# f_w: (6, 1)
# f_e: (4, 1)
# Внутренние углы:
# f_nw: (6, 2)
# f_ne: (4, 2)
# f_sw: (6, 0)
# f_se: (4, 0)

for y in range(wall_y - 2, wall_y + 4):
    line = f"{y:2d}: "
    for x in range(cx - 5, cx + 6):
        if grid[x][y] == 0:
            line += "   .    "
            continue
            
        f_n = (y > 0 and grid[x][y-1] == 0)
        f_s = (y < h-1 and grid[x][y+1] == 0)
        f_w = (x > 0 and grid[x-1][y] == 0)
        f_e = (x < w-1 and grid[x+1][y] == 0)
        
        f_nw = (x > 0 and y > 0 and grid[x-1][y-1] == 0)
        f_ne = (x < w-1 and y > 0 and grid[x+1][y-1] == 0)
        f_sw = (x > 0 and y < h-1 and grid[x-1][y+1] == 0)
        f_se = (x < w-1 and y < h-1 and grid[x+1][y+1] == 0)
        
        t = " (-1,-1)"
        if f_n and f_w: t = " (4, 3) "
        elif f_n and f_e: t = " (5, 3) "
        elif f_s and f_w: t = " (4, 4) "
        elif f_s and f_e: t = " (5, 4) "
        elif f_n: t = " (5, 2) "
        elif f_s: t = " (5, 0) "
        elif f_w: t = " (6, 1) "
        elif f_e: t = " (4, 1) "
        elif f_nw: t = " (6, 2) "
        elif f_ne: t = " (4, 2) "
        elif f_sw: t = " (6, 0) "
        elif f_se: t = " (4, 0) "
        
        # Check vertical face
        face = ""
        if f_s or f_se or f_sw:
            face = "+F"
            
        line += f"{t}{face:2s}"
    print(line)
