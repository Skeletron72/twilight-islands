import re

file_path = "scenes/levels/home_island.tscn"
with open(file_path, "r") as f:
    content = f.read()

# Check if VFXLayer exists
if "VFXLayer" not in content:
    ext_resource_block = """[ext_resource type="Shader" path="res://resources/shaders/godrays.gdshader" id="shader_godrays"]

[sub_resource type="ShaderMaterial" id="ShaderMaterial_godrays"]
shader = ExtResource("shader_godrays")
shader_parameter/angle = -0.5
shader_parameter/position = -0.2
shader_parameter/spread = 0.5
shader_parameter/cutoff = 0.3
shader_parameter/falloff = 0.4
shader_parameter/edge_fade = 0.2
shader_parameter/speed = 0.6
shader_parameter/ray1_density = 6.0
shader_parameter/ray2_density = 25.0
shader_parameter/ray2_intensity = 0.4
shader_parameter/color = Color(1, 0.9, 0.65, 0.4)
shader_parameter/hdr = true
shader_parameter/seed = 5.0

"""
    
    # Insert ext resources before the first [node
    first_node_idx = content.find("[node")
    content = content[:first_node_idx] + ext_resource_block + content[first_node_idx:]
    
    vfx_layer = """[node name="VFXLayer" type="CanvasLayer" parent="." unique_id=987654321]
layer = 5

[node name="Godrays" type="ColorRect" parent="VFXLayer" unique_id=987654322]
material = SubResource("ShaderMaterial_godrays")
anchors_preset = 15
anchor_right = 1.0
anchor_bottom = 1.0
grow_horizontal = 2
grow_vertical = 2
mouse_filter = 2

"""
    # Insert at the end of the file
    content += vfx_layer
    
    with open(file_path, "w") as f:
        f.write(content)
    print("Added VFXLayer with godrays to home_island.tscn")
else:
    print("VFXLayer already exists")
