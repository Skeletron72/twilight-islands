with open("scenes/objects/trees/palm_tree_2.tscn", "r") as f:
    c = f.read()
# Fix: hframes=2 -> hframes=3, and adjust sizes
c = c.replace("hframes = 2\nframe = 1", "hframes = 3\nframe = 1")
# Smaller occluder for 32px-wide tree
c = c.replace(
    '[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]\nsize = Vector2(40, 36)',
    '[sub_resource type="RectangleShape2D" id="RectangleShape2D_occluder"]\nsize = Vector2(28, 32)'
)
with open("scenes/objects/trees/palm_tree_2.tscn", "w") as f:
    f.write(c)
print("Fixed palm_tree_2: hframes=3")
