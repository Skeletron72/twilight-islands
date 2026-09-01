with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

old = """	# Size specific setups"""
new = """	# Make shapes unique so we don't modify the shared resource for all stones
	interaction_shape.shape = interaction_shape.shape.duplicate()
	static_shape.shape = static_shape.shape.duplicate()
	
	# Size specific setups"""

content = content.replace(old, new)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
