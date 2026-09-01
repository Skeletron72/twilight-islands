import glob
import re

for filepath in glob.glob('scenes/objects/trees/*.tscn'):
    with open(filepath, 'r') as f:
        content = f.read()
    
    # 1. Add ext_resource for occluder.gd
    occ_resource = '[ext_resource type="Script" path="res://scripts/components/occluder.gd" id="3_occ"]\n'
    content = content.replace('[ext_resource type="Script" path="res://scripts/components/tree.gd"', occ_resource + '[ext_resource type="Script" path="res://scripts/components/tree.gd"')
    
    # 2. Fix the script assignment in OccluderArea
    content = content.replace('script = ExtResource("res://scripts/components/occluder.gd")', 'script = ExtResource("3_occ")')
    
    # 3. Strip fake UIDs
    content = re.sub(r' uid="uid://tex_[^"]+"', '', content)
    
    with open(filepath, 'w') as f:
        f.write(content)
