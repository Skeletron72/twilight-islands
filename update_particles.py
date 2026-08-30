import re

with open('scenes/vfx/eat_particles.tscn', 'r') as f:
    content = f.read()

# amount = 12 -> amount = 5
content = re.sub(r'amount = \d+', 'amount = 5', content)

# scale_amount_min = 2.0 -> scale_amount_min = 1.0
content = re.sub(r'scale_amount_min = [0-9.]+', 'scale_amount_min = 1.0', content)

# scale_amount_max = 4.0 -> scale_amount_max = 2.0
content = re.sub(r'scale_amount_max = [0-9.]+', 'scale_amount_max = 2.0', content)

with open('scenes/vfx/eat_particles.tscn', 'w') as f:
    f.write(content)
