def check_draw_order(visuals_y):
    # Tree origin is at Y=0. Tree base is at Y=2.
    y_tree_origin = 0
    y_tree_base = 2
    
    # Player visuals are at `visuals_y`. Feet are at `visuals_y + 8`.
    # Let's say Player stands visually in front of Tree (Player feet are 10px below Tree base)
    y_player_feet = y_tree_base + 10
    
    # Y_player_origin is where the crosshair is!
    # Because player feet are at `Y_player_origin + visuals_y + 8`
    # Therefore Y_player_origin = y_player_feet - (visuals_y + 8)
    y_player_origin = y_player_feet - visuals_y - 8
    
    if y_player_origin > y_tree_origin:
        print(f"Visuals Y: {visuals_y} -> Player draws IN FRONT (Correct)")
    else:
        print(f"Visuals Y: {visuals_y} -> Player draws BEHIND (Incorrect, trunk on head)")

check_draw_order(-5)  # Crosshair at feet (what I set)
check_draw_order(20)  # Character below crosshair (what user did)
