# Fix 1: StaminaIndicator Sprite2D - z_index should not override Y-sort
# Use z_as_relative=true and small relative z instead
with open("scenes/characters/player/player.tscn", "r") as f:
    content = f.read()

# Remove absolute z_index=10 from stamina sprite
# Instead use z_as_relative which respects y_sort
content = content.replace(
    "hframes = 16\nvframes = 4\nframe = 15\nz_index = 10",
    "hframes = 16\nvframes = 4\nframe = 15"
)

with open("scenes/characters/player/player.tscn", "w") as f:
    f.write(content)
print("Fixed player.tscn z_index")
