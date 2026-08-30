import re

with open('scripts/autoloads/inventory_manager.gd', 'r') as f:
    content = f.read()

# Fix commit_temp_inventory
content = content.replace('\t\tfor item_id in inventory:\n\t\t\t_update_ui_slots(item_id, get_item_amount(item_id))\n\tinventory_changed.emit(item_id, get_item_amount(item_id))', 
                          '\t\tfor item_id in inventory:\n\t\t\t_update_ui_slots(item_id, get_item_amount(item_id))\n\t\t\tinventory_changed.emit(item_id, get_item_amount(item_id))')

# Fix clear_temp_inventory
content = content.replace('\t\tfor item_id in lost_items:\n\t\t\t_update_ui_slots(item_id, get_item_amount(item_id))\n\tinventory_changed.emit(item_id, get_item_amount(item_id))',
                          '\t\tfor item_id in lost_items:\n\t\t\t_update_ui_slots(item_id, get_item_amount(item_id))\n\t\t\tinventory_changed.emit(item_id, get_item_amount(item_id))')

with open('scripts/autoloads/inventory_manager.gd', 'w') as f:
    f.write(content)
