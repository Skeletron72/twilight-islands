with open("scenes/characters/player/player.tscn", "r") as f:
    content = f.read()

content = content.replace("vframes = 1\n", "vframes = 4\n")

with open("scenes/characters/player/player.tscn", "w") as f:
    f.write(content)
print("Fixed: vframes=4")
