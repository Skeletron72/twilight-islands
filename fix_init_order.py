with open('scripts/components/ui_manager.gd', 'r') as f:
    lines = f.readlines()

out = []
for line in lines:
    if line.strip() == '_update_time_text()':
        pass # We will add it back later
    elif line.strip() == '_init_time_textures()':
        out.append(line)
        out.append('\t_update_time_text()\n')
    else:
        out.append(line)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.writelines(out)
