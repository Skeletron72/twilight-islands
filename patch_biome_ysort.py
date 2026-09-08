with open("scripts/components/biome_zone.gd", "r") as f:
    content = f.read()

if "y_sort_enabled = true" not in content:
    content = content.replace(
        "    if not Engine.is_editor_hint():\n        if has_node(\"VisualPolygon\"):",
        "    y_sort_enabled = true\n    if not Engine.is_editor_hint():\n        if has_node(\"VisualPolygon\"):"
    )
    with open("scripts/components/biome_zone.gd", "w") as f:
        f.write(content)
    print("Patched y_sort")
else:
    print("Already patched")
