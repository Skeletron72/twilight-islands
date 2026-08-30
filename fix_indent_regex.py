import re

with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    content = f.read()

# For lines where inventory_changed.emit is under a for loop but missing a tab
lines = content.split('\n')
for i in range(len(lines)):
    if 'inventory_changed.emit(item_id, get_item_amount(item_id))' in lines[i]:
        # Check if the previous line is _update_ui_slots and is indented MORE than this line
        if i > 0 and '_update_ui_slots' in lines[i-1]:
            prev_tabs = len(lines[i-1]) - len(lines[i-1].lstrip('\t'))
            curr_tabs = len(lines[i]) - len(lines[i].lstrip('\t'))
            if curr_tabs < prev_tabs:
                # Fix indentation
                lines[i] = '\t' * prev_tabs + lines[i].lstrip('\t')

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write('\n'.join(lines))
