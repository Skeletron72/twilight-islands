with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

content = content.replace("var is_dead: bool = false", "var is_dead: bool = false\nvar resource_id: String = \"stone\"")

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
