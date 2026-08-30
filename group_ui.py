import re

# 1. Update ui_layer.tscn
with open('scenes/ui/ui_layer.tscn', 'r') as f:
    ui_content = f.read()

exts = """[ext_resource type="PackedScene" path="res://scenes/ui/mobile_controls.tscn" id="4_mob"]
[ext_resource type="PackedScene" path="res://scenes/ui/crafting_ui.tscn" id="5_cui"]
"""
if "4_mob" not in ui_content:
    ui_content = ui_content.replace('[node name="UILayer"', exts + '\n[node name="UILayer"', 1)
    
nodes = """
[node name="MobileControls" parent="." instance=ExtResource("4_mob")]
[node name="CraftingUI" parent="." instance=ExtResource("5_cui")]
"""
if "MobileControls" not in ui_content:
    ui_content += nodes
    
with open('scenes/ui/ui_layer.tscn', 'w') as f:
    f.write(ui_content)

# 2. Update ui_manager.gd
with open('scripts/components/ui_manager.gd', 'r') as f:
    script = f.read()
if "show()" not in script:
    script = script.replace('func _ready() -> void:\n', 'func _ready() -> void:\n\tshow()\n')
with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(script)

# 3. Clean up home_island.tscn
def clean_island(filepath):
    with open(filepath, 'r') as f:
        content = f.read()
        
    # Remove MobileControls and CraftingUI instances
    content = re.sub(r'\[node name="MobileControls" [^\]]+\]\n', '', content)
    content = re.sub(r'\[node name="CraftingUI" [^\]]+\]\n', '', content)
    
    # We can also remove their ext_resource lines if we want to be clean, but not strictly necessary.
    content = re.sub(r'\[ext_resource type="PackedScene" [^\]]+path="res://scenes/ui/mobile_controls.tscn"[^\]]+\]\n', '', content)
    content = re.sub(r'\[ext_resource type="PackedScene" [^\]]+path="res://scenes/ui/crafting_ui.tscn"[^\]]+\]\n', '', content)
    
    with open(filepath, 'w') as f:
        f.write(content)
        
clean_island('scenes/levels/home_island.tscn')
clean_island('scenes/levels/raid_island.tscn')

