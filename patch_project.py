import re

file_path = "project.godot"
with open(file_path, "r") as f:
    content = f.read()

# Add shader_globals if not present
if "shader_globals" not in content:
    globals_block = """
[shader_globals]

global_shadow_skew={
"type": "float",
"value": 0.5
}
global_shadow_scale={
"type": "float",
"value": 0.5
}
global_shadow_color={
"type": "color",
"value": Color(0, 0, 0, 0.4)
}
"""
    content += globals_block
    with open(file_path, "w") as f:
        f.write(content)
    print("Added shader_globals to project.godot")
else:
    print("shader_globals already exists")
