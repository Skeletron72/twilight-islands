import re

file_path = "scenes/levels/home_island.tscn"
with open(file_path, "r") as f:
    content = f.read()

# We need to find ALL [ext_resource type="Shader"... and remove them.
# BUT we want to keep exactly ONE at the top.

# 1. Remove all instances
pattern = r'\[ext_resource type="Shader" path="res://resources/shaders/godrays.gdshader" id="shader_godrays"\]\n*'
content = re.sub(pattern, '', content)

# 2. Re-insert ONE at the proper place
first_ext_idx = content.find("[ext_resource")
if first_ext_idx != -1:
    content = content[:first_ext_idx] + '[ext_resource type="Shader" path="res://resources/shaders/godrays.gdshader" id="shader_godrays"]\n' + content[first_ext_idx:]

with open(file_path, "w") as f:
    f.write(content)
print("Removed duplicate ext_resource")
