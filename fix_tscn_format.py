import re

def fix(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Extract all [ext_resource]
    exts = re.findall(r'\[ext_resource[^\]]+\]', content)
    # Extract all [sub_resource]
    subs = []
    
    # We need to extract the sub resource blocks.
    # They start with [sub_resource and end before the next [sub_resource or [ext_resource or [node
    lines = content.split('\n')
    
    clean_lines = []
    ext_blocks = []
    sub_blocks = []
    
    current_block = []
    mode = 'none' # ext, sub, node
    
    for line in lines:
        if line.startswith('[ext_resource'):
            mode = 'ext'
            ext_blocks.append(line)
        elif line.startswith('[sub_resource'):
            if current_block and mode == 'sub':
                sub_blocks.append('\n'.join(current_block))
            mode = 'sub'
            current_block = [line]
        elif line.startswith('[node'):
            if current_block and mode == 'sub':
                sub_blocks.append('\n'.join(current_block))
            mode = 'node'
            current_block = [line]
        elif line.startswith('[gd_scene'):
            clean_lines.append(line)
        else:
            if mode == 'ext':
                pass # normally ext is 1 line
            elif mode == 'sub':
                current_block.append(line)
            elif mode == 'node':
                current_block.append(line)
                
    if current_block and mode == 'sub':
        sub_blocks.append('\n'.join(current_block))
    if current_block and mode == 'node':
        node_block = '\n'.join(current_block)
        
    # Reassemble
    out = [clean_lines[0], '']
    out.extend(ext_blocks)
    out.append('')
    out.extend(sub_blocks)
    out.append('')
    out.append(node_block)
    
    with open(filepath, 'w') as f:
        f.write('\n'.join(out))

fix('scenes/objects/tree.tscn')
fix('scenes/objects/stone.tscn')
fix('scenes/levels/twilight_ore.tscn')
