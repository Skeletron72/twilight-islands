import re

with open('scripts/components/chicken.gd', 'r') as f:
    content = f.read()

# Fix 1: increase dist < 12.0 to dist < 24.0
content = content.replace('if dist < 12.0:', 'if dist < 24.0:')

# Fix 2: allow timeout during MOVING_TO_BUSH
old_moving = """		State.MOVING_TO_BUSH:
			if not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:"""

new_moving = """		State.MOVING_TO_BUSH:
			if state_timer <= 0 or not is_instance_valid(target_bush) or not target_bush.has_berries:
				_pick_new_state()
			else:"""

content = content.replace(old_moving, new_moving)

# Fix 3: set state_timer when transitioning to MOVING_TO_BUSH
old_pick = """		if valid_bushes.size() > 0:
			target_bush = valid_bushes[randi() % valid_bushes.size()]
			current_state = State.MOVING_TO_BUSH
			return"""

new_pick = """		if valid_bushes.size() > 0:
			target_bush = valid_bushes[randi() % valid_bushes.size()]
			current_state = State.MOVING_TO_BUSH
			state_timer = 10.0 # max 10 seconds to reach it
			return"""

content = content.replace(old_pick, new_pick)

with open('scripts/components/chicken.gd', 'w') as f:
    f.write(content)
