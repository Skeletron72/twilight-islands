with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

if not content.startswith("@tool"):
    content = "@tool\n" + content
    
    with open('scripts/components/stone.gd', 'w') as f:
        f.write(content)
