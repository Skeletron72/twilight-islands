cx = 30
wall_y = 26

def tile_to_world(x, y):
    return (x * 16 + 8, y * 16 + 8)

# Doorway
dw_pos = (tile_to_world(cx - 4, wall_y + 2)[0] - 8, tile_to_world(cx - 4, wall_y + 2)[1] + 8)
print("Doorway bottom-center:", dw_pos)
print("Doorway X span:", dw_pos[0] - 16, "to", dw_pos[0] + 16)
print("Doorway Y span:", dw_pos[1] - 64, "to", dw_pos[1])
print("Tile cx-5 X span:", (cx - 5)*16, "to", (cx - 4)*16)
print("Tile cx-4 X span:", (cx - 4)*16, "to", (cx - 3)*16)
print("Tile wall_y Y top:", wall_y * 16)
print("Tile wall_y+2 Y bot:", (wall_y + 3) * 16)

# Ladder
ld_pos = (tile_to_world(cx - 4, wall_y + 2)[0], tile_to_world(cx - 4, wall_y + 2)[1] + 8)
print("\nLadder bottom-center:", ld_pos)
print("Ladder X span:", ld_pos[0] - 8, "to", ld_pos[0] + 8)
print("Ladder Y span:", ld_pos[1] - 48, "to", ld_pos[1])

# Support
sp_pos = (tile_to_world(cx, wall_y + 2)[0], tile_to_world(cx, wall_y + 2)[1] + 8)
print("\nSupport bottom-center:", sp_pos)
print("Support X span:", sp_pos[0] - 40, "to", sp_pos[0] + 40)
print("Support Y span:", sp_pos[1] - 48, "to", sp_pos[1])
