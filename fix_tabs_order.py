import re

with open('scenes/ui/book_ui.tscn', 'r') as f:
    content = f.read()

# Fix Tabs to be HBoxContainer
content = re.sub(r'\[node name="Tabs" type="VBoxContainer"(.*?)\]\nlayout_mode = 2\nalignment = 1', r'[node name="Tabs" type="HBoxContainer"\1]\nlayout_mode = 2\nalignment = 1\ntheme_override_constants/separation = 16', content)

# Move Tabs before BookPanel
# We find [node name="BookPanel"... and [node name="Tabs"...
# Since it's a bit tricky with nested nodes, let's just write a custom parser or just trust regex.
book_idx = content.find('[node name="BookPanel"')
tabs_idx = content.find('[node name="Tabs"')

if book_idx != -1 and tabs_idx != -1:
    tabs_block = content[tabs_idx:]
    content_before_tabs = content[:tabs_idx]
    
    # We want to insert tabs_block right before book_idx
    new_content = content_before_tabs[:book_idx] + tabs_block + content_before_tabs[book_idx:]
    
    with open('scenes/ui/book_ui.tscn', 'w') as f:
        f.write(new_content)
