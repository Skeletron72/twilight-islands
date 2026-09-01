with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Remove the duplicated block
dupe_block = """@onready var visuals = $Visuals
@onready var interaction_area = $InteractionArea

var current_anim: String = ""
var current_dir: int = 0 # 0=Down, 1=Right, 2=Up
var current_frame: int = 0
var anim_timer: float = 0.0
var fps: float = 10.0

var speed: float = 120.0
var is_acting: bool = false
var is_dead: bool = false
var current_target: Node2D = null
"""

content = content.replace(dupe_block, "var current_dir: int = 0 # 0=Down, 1=Right, 2=Up\n")

# Also update the original speed to 120.0 since it was 40.0
content = content.replace("@export var speed: float = 40.0", "@export var speed: float = 120.0")

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
