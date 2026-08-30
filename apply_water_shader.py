import re

def apply_shader(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Add resources if not already present
    if 'water_waves.gdshader' not in content:
        ext_res = '[ext_resource type="Shader" path="res://resources/shaders/water_waves.gdshader" id="water_shader"]'
        content = content.replace('[ext_resource', ext_res + '\n[ext_resource', 1)

    sub_res = """
[sub_resource type="ShaderMaterial" id="ShaderMaterial_water"]
shader = ExtResource("water_shader")
shader_parameter/wave_speed = 1.5
shader_parameter/wave_freq = 0.05
shader_parameter/wave_amp = 1.5
"""
    if 'ShaderMaterial_water' not in content:
        # find the first node and insert before it
        idx = content.find('\n[node')
        if idx != -1:
            content = content[:idx] + sub_res + content[idx:]

    # Apply material to WaterLayer
    pattern = r'(\[node name="WaterLayer" type="TileMapLayer"[^\]]*\]\n(?:[^\[]*\n)?)'
    # Wait, the node might already have properties. We need to be careful not to overwrite them.
    # The safest way is to just inject 'material = SubResource("ShaderMaterial_water")' right after the node declaration
    def repl(m):
        block = m.group(1)
        if 'material = ' not in block:
            lines = block.split('\n')
            lines.insert(1, 'material = SubResource("ShaderMaterial_water")')
            return '\n'.join(lines)
        return block
        
    content = re.sub(pattern, repl, content)

    with open(filepath, 'w') as f:
        f.write(content)

apply_shader('scenes/levels/home_island.tscn')
apply_shader('scenes/levels/raid_island.tscn')

