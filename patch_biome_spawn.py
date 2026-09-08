with open("scripts/components/biome_zone.gd", "r") as f:
    content = f.read()

old = '''	var scene_root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	if not scene_root: return
		
	# Удаляем объекты которые создала ЭТА зона
	for child in scene_root.get_children():
		if child.has_meta("auto_generated") and child.has_meta("spawned_by_zone"):
			if child.get_meta("spawned_by_zone") == name:
				child.queue_free()'''

new = '''	# Удаляем объекты которые создала ЭТА зона (они дети этой зоны)
	for child in get_children():
		if child.has_meta("auto_generated"):
			child.queue_free()'''

content = content.replace(old, new)

old2 = '''				var inst = scene.instantiate()
					inst.set_meta("auto_generated", true)
					inst.set_meta("spawned_by_zone", name)
					# СНАЧАЛА добавляем в дерево, потом global_position!
					scene_root.add_child(inst)
					if Engine.is_editor_hint():
						inst.owner = scene_root
					inst.global_position = global_position + pt'''

new2 = '''				var inst = scene.instantiate()
					inst.set_meta("auto_generated", true)
					# Добавляем как ребенок зоны (для организации иерархии)
					add_child(inst)
					if Engine.is_editor_hint() and owner:
						inst.owner = owner
					inst.global_position = global_position + pt'''

content = content.replace(old2, new2)

# Also remove the duplicate scene_root line if exists
old3 = '''	# Целевой родитель — корень сцены, чтобы Y-сортировка работала с игроком
	var scene_root = get_tree().edited_scene_root if Engine.is_editor_hint() else get_tree().current_scene
	
	while'''
new3 = '''	while'''
content = content.replace(old3, new3)

with open("scripts/components/biome_zone.gd", "w") as f:
    f.write(content)
print("Done")
