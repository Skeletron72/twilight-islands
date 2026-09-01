import re

with open('scripts/components/player.gd', 'r') as f:
    content = f.read()

# Replace the giant anim_data dictionary and LAYERS
old_top = re.search(r'const LAYERS = .*?add_to_group\("player"\)', content, re.DOTALL).group(0)

new_top = """const LAYERS = ["Base", "Legs", "Feet", "Chest", "Head", "Hands"]

const ANIM_MAP = {
	"idle": { "row": 0, "frames": 6 },
	"walk": { "row": 3, "frames": 6 },
	"run": { "row": 3, "frames": 6 },
	"attack": { "row": 6, "frames": 4 }, # 6 = Sword L->R, 9 = Right L->R, 12 = Up L->R
	"hurt": { "row": 15, "frames": 4 }, # Using Fall Right (15) as hurt/death for now
	"death": { "row": 15, "frames": 4 },
	"axe": { "row": 32, "frames": 6 },
	"mining": { "row": 35, "frames": 6 },
	"swimming": { "row": 3, "frames": 6 }
}

@onready var visuals = $Visuals
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

func _ready() -> void:
	# Set up the sprite sheets
	var tex_base = preload("res://assets/new_assets/Cute_Fantasy/Player/Player_Base/Player_Base_animations.png")
	var tex_legs = preload("res://assets/new_assets/Cute_Fantasy/Player/Legs/Farmer_Pants/Farmer_Pants_1_Blue.png")
	var tex_feet = preload("res://assets/new_assets/Cute_Fantasy/Player/Feet/OG_Shoes/Shoes_1_Brown.png")
	var tex_chest = preload("res://assets/new_assets/Cute_Fantasy/Player/Chest/Farmer_Shirt/Farmer_Shirt_1_Red.png")
	var tex_head = preload("res://assets/new_assets/Cute_Fantasy/Player/Head/Hair_1/Hair_1_Brown.png")
	var tex_hands = preload("res://assets/new_assets/Cute_Fantasy/Player/Hands/Hands_1_Bare.png")
	
	for layer_name in LAYERS:
		var sprite = visuals.get_node_or_null(layer_name)
		if sprite:
			sprite.hframes = 9
			sprite.vframes = 56
			if layer_name == "Base": sprite.texture = tex_base
			if layer_name == "Legs": sprite.texture = tex_legs
			if layer_name == "Feet": sprite.texture = tex_feet
			if layer_name == "Chest": sprite.texture = tex_chest
			if layer_name == "Head": sprite.texture = tex_head
			if layer_name == "Hands": sprite.texture = tex_hands

	InventoryManager.equipment_changed.connect(_update_equipment_visuals)
	_update_equipment_visuals()

	add_to_group("player")"""

content = content.replace(old_top, new_top)

# Update physics process direction logic
old_dir = """	if direction.length() > 0:
		if direction.x != 0:
			visuals.scale.x = -1 if direction.x < 0 else 1"""

new_dir = """	if direction.length() > 0:
		# 0=Down, 1=Right, 2=Up
		if abs(direction.x) > abs(direction.y):
			current_dir = 1
			visuals.scale.x = -1 if direction.x < 0 else 1
		elif direction.y > 0:
			current_dir = 0
			visuals.scale.x = 1
		elif direction.y < 0:
			current_dir = 2
			visuals.scale.x = 1"""
content = content.replace(old_dir, new_dir)

# Update _play_anim and _process_animation
old_anim = re.search(r'func _play_anim\(anim_name: String\) -> void:.*?(?=func _update_auto_target)', content, re.DOTALL).group(0)

new_anim = """func _play_anim(anim_name: String) -> void:
	if current_anim == anim_name and current_dir == get_last_direction():
		return
	
	if current_anim != anim_name:
		current_frame = 0
		anim_timer = 0.0
		
	current_anim = anim_name

func get_last_direction() -> int:
	return current_dir

func _process_animation(delta: float) -> void:
	if current_anim == "": return
	
	var fps_mult = 1.0
	if current_anim == "run": fps_mult = 1.5
	
	anim_timer += delta
	var frame_dur = 1.0 / (fps * fps_mult)
	
	if anim_timer >= frame_dur:
		anim_timer -= frame_dur
		var frames = ANIM_MAP[current_anim]["frames"]
		current_frame += 1
		
		# Handle animation end
		if current_frame >= frames:
			if current_anim == "death":
				current_frame = frames - 1 # Зависаем на последнем кадре смерти
			elif current_anim in ["axe", "mining", "attack", "hurt"]:
				is_acting = false
				current_frame = 0
				_play_anim("idle")
			else:
				current_frame = current_frame % frames
				
		# Handle action hit frame
		var hit_frame = 3 # New animations are shorter (6 or 4 frames), hit around frame 3
		if current_anim in ["axe", "mining", "attack"] and current_frame == hit_frame:
			if current_target and is_instance_valid(current_target):
				if current_target.has_method("interact"):
					current_target.interact(self)
		
		var row = ANIM_MAP[current_anim]["row"]
		# For attack (6, 9, 12), we multiply current_dir by 3.
		# For most others, it's just + current_dir
		var actual_row = row
		if current_anim == "attack":
			actual_row = row + (current_dir * 3)
		else:
			actual_row = row + current_dir
			
		for layer_name in LAYERS:
			var sprite: Sprite2D = visuals.get_node_or_null(layer_name)
			if sprite and sprite.texture:
				sprite.frame_coords = Vector2i(current_frame, actual_row)

"""
content = content.replace(old_anim, new_anim)

with open('scripts/components/player.gd', 'w') as f:
    f.write(content)
