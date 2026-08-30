extends SceneTree

func _init() -> void:
	print("Setting up Player Animations...")
	var scene = load("res://scenes/characters/player/player.tscn")
	var root = scene.instantiate()
	
	# Create Visuals Node
	var visuals = Node2D.new()
	visuals.name = "Visuals"
	root.add_child(visuals)
	visuals.owner = root
	
	var layers = ["Base", "Cloth", "Hair", "Tools"]
	var sprites = {}
	
	for l in layers:
		var s = Sprite2D.new()
		s.name = l
		visuals.add_child(s)
		s.owner = root
		s.hframes = 9 # Default to idle
		sprites[l] = s

	# Animation Player
	var anim_player = AnimationPlayer.new()
	anim_player.name = "AnimationPlayer"
	root.add_child(anim_player)
	anim_player.owner = root
	
	var library = AnimationLibrary.new()
	
	# --- IDLE ANIMATION ---
	var idle_anim = Animation.new()
	idle_anim.length = 0.9
	idle_anim.loop_mode = Animation.LOOP_LINEAR
	
	for l in layers:
		var path = "Visuals/" + l
		
		# Texture track
		var tex_track = idle_anim.add_track(Animation.TYPE_VALUE)
		idle_anim.track_set_path(tex_track, path + ":texture")
		idle_anim.track_insert_key(tex_track, 0.0, _get_tex(l, "WAITING", 9))
		
		# Hframes track
		var hf_track = idle_anim.add_track(Animation.TYPE_VALUE)
		idle_anim.track_set_path(hf_track, path + ":hframes")
		idle_anim.track_insert_key(hf_track, 0.0, 9)
		
		# Frame track
		var frame_track = idle_anim.add_track(Animation.TYPE_VALUE)
		idle_anim.track_set_path(frame_track, path + ":frame")
		for i in range(9):
			idle_anim.track_insert_key(frame_track, i * 0.1, i)
			
	library.add_animation("idle", idle_anim)
	
	# --- RUN ANIMATION ---
	var run_anim = Animation.new()
	run_anim.length = 0.8
	run_anim.loop_mode = Animation.LOOP_LINEAR
	
	for l in layers:
		var path = "Visuals/" + l
		
		var tex_track = run_anim.add_track(Animation.TYPE_VALUE)
		run_anim.track_set_path(tex_track, path + ":texture")
		run_anim.track_insert_key(tex_track, 0.0, _get_tex(l, "RUN", 8))
		
		var hf_track = run_anim.add_track(Animation.TYPE_VALUE)
		run_anim.track_set_path(hf_track, path + ":hframes")
		run_anim.track_insert_key(hf_track, 0.0, 8)
		
		var frame_track = run_anim.add_track(Animation.TYPE_VALUE)
		run_anim.track_set_path(frame_track, path + ":frame")
		for i in range(8):
			run_anim.track_insert_key(frame_track, i * 0.1, i)
			
	library.add_animation("run", run_anim)
	
	anim_player.add_animation_library("", library)
	
	# Remove old Sprite2D
	var old_sprite = root.get_node_or_null("Sprite2D")
	if old_sprite:
		old_sprite.name = "OldSprite"
		old_sprite.queue_free()
	
	var err = PackedScene.new()
	err.pack(root)
	ResourceSaver.save(err, "res://scenes/characters/player/player.tscn")
	print("Player animations saved!")
	quit()

func _get_tex(layer_name: String, state: String, strip: int) -> Texture2D:
	var prefix = ""
	match layer_name:
		"Base": prefix = "base"
		"Cloth": prefix = "cloth1"
		"Hair": prefix = "hair_merged"
		"Tools": prefix = "tools"
		
	var path = "res://assets/sprites/characters/Human/%s/%s_%s_strip%d.png" % [state, prefix, state.to_lower(), strip]
	if ResourceLoader.exists(path):
		return load(path)
	return null
