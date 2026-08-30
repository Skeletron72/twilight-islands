with open('scenes/characters/player/player.tscn', 'r') as f:
    lines = f.read().split('\n')

gd_scene = []
exts = []
subs = []
nodes = []

mode = 'none'
current_block = []

for line in lines:
    if line.startswith('[gd_scene'):
        gd_scene.append(line)
        mode = 'gd'
    elif line.startswith('[ext_resource'):
        exts.append(line)
    elif line.startswith('[sub_resource'):
        if mode == 'sub' and current_block:
            subs.append('\n'.join(current_block))
        mode = 'sub'
        current_block = [line]
    elif line.startswith('[node'):
        if mode == 'sub' and current_block:
            subs.append('\n'.join(current_block))
        elif mode == 'node' and current_block:
            nodes.append('\n'.join(current_block))
        mode = 'node'
        current_block = [line]
    else:
        if mode == 'sub' or mode == 'node':
            current_block.append(line)

if mode == 'node' and current_block:
    nodes.append('\n'.join(current_block))
elif mode == 'sub' and current_block:
    subs.append('\n'.join(current_block))

out = gd_scene + [''] + exts + [''] + subs + [''] + nodes

with open('scenes/characters/player/player.tscn', 'w') as f:
    f.write('\n'.join(out))
