with open('scripts/components/stone.gd', 'r') as f:
    content = f.read()

# 1. Remove @tool
content = content.replace("@tool\n", "")

# 2. Add @export to rock_type
content = content.replace("var rock_type: int = 1", "@export var rock_type: int = 1")

# 3. Rewrite _ready to only set HP, and stop doing texture/shape overrides!
old_ready = """func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	# Pick random rock type (1 to 14)
	rock_type = randi() % 14 + 1
	var tex_path = "res://assets/new_assets/Cute_Fantasy/Outdoor decoration/Outdoor_Decor_Animations/Rock_Animations/Rock_%d_Anim.png" % rock_type
	var tex = load(tex_path)
	print("STONE LOAD:", tex_path, " RESULT:", tex)
	if tex:
		sprite.texture = tex
		sprite.hframes = 8
		sprite.vframes = 1
		sprite.frame = 0
		sprite.offset = Vector2(0, -tex.get_height() / 2.0)
	
	# Make shapes unique so we don't modify the shared resource for all stones
	interaction_shape.shape = interaction_shape.shape.duplicate()
	static_shape.shape = static_shape.shape.duplicate()
	
	# Size specific setups
	# Rocks 1-10 are 16x16 frames, Rocks 11-14 are 32x32 frames
	var is_large = rock_type >= 11
	
	if is_large:
		hp = randi_range(4, 7)
		interaction_shape.shape.radius = 24.0
		interaction_shape.position.y = -16.0
		static_shape.shape.size = Vector2(24.0, 10.0)
		static_shape.position.y = -5.0
	else:
		hp = randi_range(2, 4)
		interaction_shape.shape.radius = 16.0
		interaction_shape.position.y = -8.0
		static_shape.shape.size = Vector2(12.0, 6.0)
		static_shape.position.y = -3.0
		
	# Always process to loop the idle animation"""

new_ready = """func _ready() -> void:
	super._ready()
	collision_layer = 2
	
	var is_large = rock_type >= 11
	if is_large:
		hp = randi_range(4, 7)
	else:
		hp = randi_range(2, 4)
		
	# Always process to loop the idle animation"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/stone.gd', 'w') as f:
    f.write(content)
