with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

import re
content = re.sub(r'# Large rocks have a small chance.*?add_child\(drop\)', '', content, flags=re.DOTALL)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
