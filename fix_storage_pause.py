import re

with open('scenes/ui/storage_ui.tscn', 'r') as f:
    content = f.read()

content = content.replace('[node name="StorageUI" type="Control"]', 
                          '[node name="StorageUI" type="Control"]\nprocess_mode = 3') # PROCESS_MODE_ALWAYS

with open('scenes/ui/storage_ui.tscn', 'w') as f:
    f.write(content)
