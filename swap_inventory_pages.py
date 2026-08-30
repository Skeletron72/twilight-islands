import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# We need to swap the children of InventoryTab/HBoxContainer/LeftPage and RightPage!
# To do this safely, we will just rename LeftPage to RightPageTemp, RightPage to LeftPage, and RightPageTemp to RightPage!
# But Godot relies on node order for layout. HBoxContainer puts first child on the left.
# So we need to literally move the [node name="RightPage"] block BEFORE [node name="LeftPage"] block!
# Or we can just swap the names "LeftPage" and "RightPage" everywhere in the InventoryTab section!
# Since LeftPage is first, if we rename it to RightPage, and RightPage to LeftPage, Godot will just render the former RightPage on the left!

# Let's extract the InventoryTab block
start_idx = content.find('[node name="InventoryTab"')
end_idx = content.find('[node name="CharacterTab"')

inv_block = content[start_idx:end_idx]

# Swap "LeftPage" and "RightPage" inside inv_block
# Use a placeholder to avoid double swapping
inv_block = inv_block.replace('LeftPage', 'TEMP_PAGE')
inv_block = inv_block.replace('RightPage', 'LeftPage')
inv_block = inv_block.replace('TEMP_PAGE', 'RightPage')

# Now put it back
new_content = content[:start_idx] + inv_block + content[end_idx:]

with open('scenes/ui/book_ui.tscn', 'w') as f:
    f.write(new_content)

