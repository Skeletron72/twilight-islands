extends Node

## DialogueManager
## Глобальный синглтон для управления диалогами с выборами, портретами, условиями и действиями.

signal dialogue_started(speaker_name: String)
signal dialogue_line_displayed(line_data: Dictionary)
signal dialogue_ended(speaker_name: String)
signal choice_selected(choice_index: int, choice_data: Dictionary)
signal action_triggered(action_name: String, params: Array)
signal cutscene_started
signal cutscene_ended

var is_in_dialogue: bool = false
var is_in_cutscene: bool = false

var current_dialogue: Dictionary = {}
var current_node_id: String = ""
var current_speaker: String = ""
var current_portrait: Texture2D = null
var current_npc: Node = null

var flags: Dictionary = {}

func set_flag(key: String, value = true) -> void:
	flags[key] = value

func get_flag(key: String, default_value = false):
	return flags.get(key, default_value)

func has_flag(key: String) -> bool:
	return bool(flags.get(key, false))

## Загрузить дерево диалога из JSON файла
func load_dialogue_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_warning("DialogueManager: Файл диалога не найден: %s" % path)
		return {}
		
	var file = FileAccess.open(path, FileAccess.READ)
	if not file:
		push_error("DialogueManager: Не удалось открыть файл: %s" % path)
		return {}
		
	var json_str = file.get_as_text()
	var json = JSON.new()
	var err = json.parse(json_str)
	if err != OK:
		push_error("DialogueManager: Ошибка в JSON диалога %s: %s (строка %d)" % [path, json.get_error_message(), json.get_error_line()])
		return {}
		
	if json.data is Dictionary:
		return json.data
	return {}

## Начать диалог из JSON файла
func start_dialogue_from_file(path: String, initial_node: String = "start", speaker: String = "", portrait: Texture2D = null, npc_ref: Node = null) -> void:
	var tree = load_dialogue_file(path)
	if tree.is_empty():
		push_warning("DialogueManager: Пустое дерево диалога из файла %s" % path)
		return
	start_dialogue(tree, initial_node, speaker, portrait, npc_ref)

## Начать диалог из словаря
func start_dialogue(dialogue_tree: Dictionary, initial_node: String = "start", speaker: String = "", portrait: Texture2D = null, npc_ref: Node = null) -> void:
	current_dialogue = dialogue_tree
	current_node_id = initial_node
	current_speaker = speaker
	current_portrait = portrait
	current_npc = npc_ref
	is_in_dialogue = true
	
	dialogue_started.emit(speaker)
	_present_current_node()

func _present_current_node() -> void:
	if not current_dialogue.has(current_node_id):
		end_dialogue()
		return
		
	# Разрешение условных ветвлений (branches)
	var max_hops = 10
	while current_dialogue.has(current_node_id) and current_dialogue[current_node_id].has("branches") and max_hops > 0:
		max_hops -= 1
		var branches: Array = current_dialogue[current_node_id]["branches"]
		var branched = false
		for branch in branches:
			var cond = branch.get("condition", null)
			if cond == null or cond == "default" or evaluate_condition(cond):
				current_node_id = branch.get("next", "end")
				branched = true
				break
		if not branched:
			break
			
	if not current_dialogue.has(current_node_id) or current_node_id == "end" or current_node_id == "":
		end_dialogue()
		return
		
	var node_data = current_dialogue[current_node_id]
	var speaker = node_data.get("speaker", current_speaker)
	
	# Поддержка загрузки портрета по пути строки или готовому Texture2D
	var portrait_val = node_data.get("portrait", current_portrait)
	if portrait_val is String and portrait_val != "":
		if ResourceLoader.exists(portrait_val):
			portrait_val = load(portrait_val)
		else:
			portrait_val = null
			
	var line_info = {
		"node_id": current_node_id,
		"speaker": speaker,
		"text": node_data.get("text", ""),
		"portrait": portrait_val,
		"choices": node_data.get("choices", [])
	}
	
	dialogue_line_displayed.emit(line_info)

func select_choice(choice_index: int) -> void:
	if not is_in_dialogue or not current_dialogue.has(current_node_id):
		return
		
	var node_data = current_dialogue[current_node_id]
	var choices: Array = node_data.get("choices", [])
	if choice_index < 0 or choice_index >= choices.size():
		return
		
	var choice = choices[choice_index]
	choice_selected.emit(choice_index, choice)
	
	# Выполнение действия (строка или Callable)
	if choice.has("action"):
		execute_action(choice["action"])
		
	var next_node = choice.get("next", "")
	if next_node == "" or next_node == "end":
		end_dialogue()
	else:
		current_node_id = next_node
		_present_current_node()

func advance_dialogue() -> void:
	if not is_in_dialogue or not current_dialogue.has(current_node_id):
		return
		
	var node_data = current_dialogue[current_node_id]
	var choices: Array = node_data.get("choices", [])
	
	if choices.is_empty():
		# Если есть действие на завершение реплики без выборов
		if node_data.has("action"):
			execute_action(node_data["action"])
			
		var next_node = node_data.get("next", "end")
		if next_node == "end" or next_node == "":
			end_dialogue()
		else:
			current_node_id = next_node
			_present_current_node()

func end_dialogue() -> void:
	if not is_in_dialogue:
		return
	is_in_dialogue = false
	var finished_speaker = current_speaker
	current_dialogue = {}
	current_node_id = ""
	current_speaker = ""
	current_portrait = null
	current_npc = null
	dialogue_ended.emit(finished_speaker)

## Проверка условий для реплик и выборов
## Поддерживает:
## - "has_item:item_id:amount" (например "has_item:wood:5")
## - "quest_active:quest_id"
## - "quest_completed:quest_id"
## - Callable (пользовательская функция)
## - bool
func evaluate_condition(cond) -> bool:
	if cond == null:
		return true
	if cond is bool:
		return cond
	if cond is Callable:
		return cond.call()
	if cond is String:
		var s: String = cond
		if s == "default":
			return true
		if "," in s:
			for sub_c in s.split(","):
				var trimmed = sub_c.strip_edges()
				if trimmed != "" and not evaluate_condition(trimmed):
					return false
			return true
		elif s.begins_with("has_item:"):
			var parts = s.split(":")
			if parts.size() >= 3:
				var item_id = parts[1]
				var amount = int(parts[2])
				return InventoryManager.has_item(item_id, amount) if InventoryManager else false
		elif s.begins_with("quest_active:"):
			var q_id = s.split(":")[1]
			return QuestManager.is_quest_active(q_id) if QuestManager else false
		elif s.begins_with("quest_completed:"):
			var q_id = s.split(":")[1]
			return QuestManager.is_quest_completed(q_id) if QuestManager else false
		elif s.begins_with("quest_claimed:"):
			var q_id = s.split(":")[1]
			return QuestManager.is_quest_claimed(q_id) if QuestManager else false
		elif s.begins_with("quest_not_active:"):
			var q_id = s.split(":")[1]
			return not QuestManager.is_quest_active(q_id) and not QuestManager.is_quest_claimed(q_id) if QuestManager else true
		elif s.begins_with("recipe_unlocked:"):
			var r_id = s.split(":")[1]
			return ItemDB.is_recipe_unlocked(r_id) if ItemDB else false
		elif s.begins_with("has_flag:"):
			var f_id = s.split(":")[1]
			return has_flag(f_id)
		elif s.begins_with("not_has_flag:"):
			var f_id = s.split(":")[1]
			return not has_flag(f_id)
		elif s == "workshop_ready":
			return HomeStateManager.is_workshop_ready() if HomeStateManager else false
		elif s == "workshop_under_construction":
			return (HomeStateManager.workshop_built and HomeStateManager.workshop_under_construction) if HomeStateManager else false
		elif s == "workshop_not_started":
			return (not HomeStateManager.workshop_built) if HomeStateManager else true
		elif s == "shipwright_wood_given":
			return (HomeStateManager.shipwright_wood_given if HomeStateManager else false) or has_flag("shipwright_wood_given")
		elif s == "not_shipwright_wood_given":
			return not ((HomeStateManager.shipwright_wood_given if HomeStateManager else false) or has_flag("shipwright_wood_given"))
		elif s == "shipwright_spoken_once":
			return (HomeStateManager.shipwright_spoken_once if HomeStateManager else false) or has_flag("shipwright_spoken_once")
	return true

## Выполнение действий из выборов или реплик
## Поддерживает одиночные или составные команды через точку с запятой ";"
## Примеры:
## - "give_item:wood:5;claim_reward:shipwright_wood;stand_up"
## - "start_quest:quest_id"
## - "set_flag:flag_name"
func execute_action(action) -> void:
	if action == null:
		return
	if action is Callable:
		action.call()
		return
	if action is String:
		var s: String = action
		if ";" in s:
			for sub_act in s.split(";"):
				var trimmed = sub_act.strip_edges()
				if trimmed != "":
					_execute_single_action(trimmed)
		else:
			_execute_single_action(s.strip_edges())

func _execute_single_action(s: String) -> void:
	var parts = s.split(":")
	var cmd = parts[0]
	
	match cmd:
		"give_item":
			if parts.size() >= 3 and InventoryManager:
				var item_id = parts[1]
				var amount = int(parts[2])
				InventoryManager.remove_item(item_id, amount)
		"receive_item":
			if parts.size() >= 3 and InventoryManager:
				var item_id = parts[1]
				var amount = int(parts[2])
				InventoryManager.add_item(item_id, amount)
		"unlock_recipe":
			if parts.size() >= 2 and ItemDB:
				ItemDB.unlock_recipe(parts[1])
		"start_quest":
			if parts.size() >= 2 and QuestManager:
				QuestManager.activate_quest(parts[1])
		"complete_quest", "claim_reward":
			if parts.size() >= 2 and QuestManager:
				QuestManager.claim_reward(parts[1])
		"set_flag":
			if parts.size() >= 3:
				set_flag(parts[1], parts[2])
				if parts[1] == "shipwright_spoken_once" and HomeStateManager:
					HomeStateManager.shipwright_spoken_once = true
				elif parts[1] == "shipwright_wood_given" and HomeStateManager:
					HomeStateManager.shipwright_wood_given = true
			elif parts.size() >= 2:
				set_flag(parts[1], true)
				if parts[1] == "shipwright_spoken_once" and HomeStateManager:
					HomeStateManager.shipwright_spoken_once = true
				elif parts[1] == "shipwright_wood_given" and HomeStateManager:
					HomeStateManager.shipwright_wood_given = true
		"thought":
			var msg = s.substr(8)
			var exp_mgr = get_node_or_null("/root/ExpeditionManager")
			if exp_mgr and exp_mgr.has_method("post_thought"):
				exp_mgr.post_thought(msg, Color(1.0, 0.9, 0.4))
		"start_following":
			if current_npc and current_npc.has_method("start_following"):
				current_npc.start_following()
			if HomeStateManager:
				HomeStateManager.shipwright_following = true
		"stand_up":
			if current_npc and current_npc.has_method("stand_up"):
				current_npc.stand_up()
		"start_build_mode":
			var b_type = parts[1] if parts.size() >= 2 else "shipwright_workshop"
			var bm = get_node_or_null("/root/BuildModeManager")
			if bm and bm.has_method("start_freecam_build"):
				bm.start_freecam_build(b_type)
				
	action_triggered.emit(cmd, parts)

func start_cutscene() -> void:
	is_in_cutscene = true
	cutscene_started.emit()

func end_cutscene() -> void:
	is_in_cutscene = false
	cutscene_ended.emit()
