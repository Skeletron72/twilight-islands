import re

with open("resources/shaders/tree_occlusion.gdshader", "r") as f:
    content = f.read()

# Add uniforms
content = content.replace("uniform vec2 player_pos = vec2(0.0);", 
"""uniform vec2 player_pos = vec2(0.0);
uniform float silhouette_darkness : hint_range(0.0, 1.0) = 0.6; // Темнота силуэта (1.0 - нет затемнения)
uniform float circle_alpha : hint_range(0.0, 1.0) = 0.4; // Прозрачность круга (0.0 - полностью прозрачно, 1.0 - не прозрачно)""")

# Update darkness logic
content = content.replace("tex_color.rgb *= 0.6;", "tex_color.rgb *= silhouette_darkness;")

# Update circle hole logic
content = content.replace("tex_color.a = 0.0;", "tex_color.a *= circle_alpha;")

with open("resources/shaders/tree_occlusion.gdshader", "w") as f:
    f.write(content)
print("Shader patched")
