@tool
extends EditorScript

# Скрипт для спавна поваленных брёвен (горизонтальных и вертикальных) в лесу и на поляне.
# Запуск в редакторе Godot: File -> Run (или Ctrl+Shift+X / Cmd+Shift+X)

func _run() -> void:
	var scene_path = "res://scenes/levels/home_island.tscn"
	var packed_scene = load(scene_path) as PackedScene
	if not packed_scene:
		print("Не удалось загрузить home_island.tscn")
		return
		
	var island = packed_scene.instantiate()
	var log_h_scene = load("res://scenes/objects/decor/fallen_log_horizontal.tscn") as PackedScene
	var log_v_scene = load("res://scenes/objects/decor/fallen_log_vertical.tscn") as PackedScene
	if not log_h_scene or not log_v_scene:
		print("Не удалось загрузить сцены брёвен")
		return

	var clearing = island.get_node_or_null("ClearingZone")
	var forest = island.get_node_or_null("ForestZone")

	# На поляне: горизонтальные и вертикальные брёвна
	if clearing:
		var c_h_positions = [Vector2(50, -40), Vector2(210, -80)]
		var c_h_variants = [0, 2]
		for i in range(c_h_positions.size()):
			var log_inst = log_h_scene.instantiate()
			log_inst.position = c_h_positions[i]
			log_inst.variant = c_h_variants[i]
			log_inst.set_meta("auto_generated", true)
			clearing.add_child(log_inst)
			log_inst.owner = island

		var c_v_positions = [Vector2(80, -90), Vector2(250, -40)]
		var c_v_variants = [1, 3] # 1 ветка, красный гриб
		for i in range(c_v_positions.size()):
			var log_inst = log_v_scene.instantiate()
			log_inst.position = c_v_positions[i]
			log_inst.variant = c_v_variants[i]
			log_inst.set_meta("auto_generated", true)
			clearing.add_child(log_inst)
			log_inst.owner = island

	# В лесу: побольше брёвен всех разновидностей
	if forest:
		var f_h_positions = [Vector2(20, -50), Vector2(120, 40), Vector2(260, 180), Vector2(-120, 80)]
		var f_h_variants = [3, 1, 0, 2] # 3 = с фиолетовым грибом
		for i in range(f_h_positions.size()):
			var log_inst = log_h_scene.instantiate()
			log_inst.position = f_h_positions[i]
			log_inst.variant = f_h_variants[i]
			log_inst.set_meta("auto_generated", true)
			forest.add_child(log_inst)
			log_inst.owner = island

		var f_v_positions = [Vector2(100, 120), Vector2(-20, 220), Vector2(180, 240), Vector2(40, 290)]
		var f_v_variants = [2, 4, 0, 3] # синий гриб, фиолетовый гриб, без веток, красный гриб
		for i in range(f_v_positions.size()):
			var log_inst = log_v_scene.instantiate()
			log_inst.position = f_v_positions[i]
			log_inst.variant = f_v_variants[i]
			log_inst.set_meta("auto_generated", true)
			forest.add_child(log_inst)
			log_inst.owner = island

	var packed = PackedScene.new()
	var err = packed.pack(island)
	if err == OK:
		ResourceSaver.save(packed, scene_path)
		print("Успешно добавлены поваленные брёвна (горизонтальные и вертикальные) в лес и на поляну!")
	else:
		print("Ошибка упаковки сцены: ", err)
