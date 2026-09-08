extends Node

# ==============================================================================
# QUEST MANAGER
# ==============================================================================
# Manages quest definitions, dynamic objective progress tracking (gathering,
# crafting, exploration), status evaluation, rewards distribution, and SFX.
# ==============================================================================

signal quest_updated(quest_id: String)
signal quest_completed(quest_id: String)
signal quest_claimed(quest_id: String)

const CAT_MAIN = "main"
const CAT_SIDE = "side"
const CAT_EXPLORE = "explore"
const CAT_COMPLETED = "completed"

const SFX_QUEST_COMPLETE = preload("res://assets/audio/ui/sfx_quest_complete.ogg")

# Status: "active" | "completed" | "claimed"
var quests: Dictionary = {
	"main_01": {
		"id": "main_01",
		"title": "Сбор древесины",
		"category": CAT_MAIN,
		"desc": "Вы оказались на таинственном Сумеречном Острове. Чтобы обустроить лагерь и защититься от ночного холода, соберите бревна с поваленных деревьев.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(192, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "wood",
				"text": "Собрать древесину",
				"type": "gather",
				"target_item": "wood",
				"target_amount": 5,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 100},
			{"type": "item", "item_id": "cloth_basic", "name": "Простая рубаха", "amount": 1}
		]
	},
	"main_02": {
		"id": "main_02",
		"title": "Огни во тьме",
		"category": CAT_MAIN,
		"desc": "С наступлением сумерек остров погружается в холод и густой туман. Смастерите костер, чтобы согреться и обезопасить свой ночлег.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(192, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "campfire",
				"text": "Создать костер",
				"type": "craft",
				"target_item": "campfire",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 50},
			{"type": "item", "item_id": "twilight_ore", "name": "Сумрачная руда", "amount": 3}
		]
	},
	"main_03": {
		"id": "main_03",
		"title": "Уютный ночлег",
		"category": CAT_MAIN,
		"desc": "Вам необходимо надежное укрытие для сна и восстановления сил. Соберите бревна, ветки и смастерите удобную палатку.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(192, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "tent",
				"text": "Создать палатку",
				"type": "craft",
				"target_item": "tent",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 150},
			{"type": "item", "item_id": "stone_sword", "name": "Каменный меч", "amount": 1}
		]
	},
	"side_01": {
		"id": "side_01",
		"title": "Орудия труда",
		"category": CAT_SIDE,
		"desc": "Рубить твердые пальмы голыми руками слишком долго и утомительно. Смастерите деревянный топор из бревен и веток.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(304, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "wooden_axe",
				"text": "Создать деревянный топор",
				"type": "craft",
				"target_item": "wooden_axe",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "item", "item_id": "red_berry", "name": "Рубиника", "amount": 8},
			{"type": "item", "item_id": "boots_basic", "name": "Кожаные сапоги", "amount": 1}
		]
	},
	"side_02": {
		"id": "side_02",
		"title": "Лесные запасы",
		"category": CAT_SIDE,
		"desc": "Староста советует сделать запасы провианта перед долгими вылазками вглубь острова. Соберите спелые ягоды и сочные грибы.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(304, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "berries",
				"text": "Собрать рубинику",
				"type": "gather",
				"target_item": "red_berry",
				"target_amount": 5,
				"current_amount": 0,
				"is_done": false
			},
			{
				"id": "mushrooms",
				"text": "Собрать огневики",
				"type": "gather",
				"target_item": "red_mushroom",
				"target_amount": 3,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 75},
			{"type": "item", "item_id": "purple_berry", "name": "Сумеречница", "amount": 6}
		]
	},
	"explore_01": {
		"id": "explore_01",
		"title": "Дары глубин",
		"category": CAT_EXPLORE,
		"desc": "В расщелинах скал на побережье мерцает таинственная сумрачная руда. Отыщите и добудьте хотя бы один образец.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(272, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "twilight_ore",
				"text": "Добыть сумрачную руду",
				"type": "gather",
				"target_item": "twilight_ore",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 120},
			{"type": "item", "item_id": "wooden_pickaxe", "name": "Деревянная кирка", "amount": 1}
		]
	},
	"explore_02": {
		"id": "explore_02",
		"title": "Ночные огоньки",
		"category": CAT_EXPLORE,
		"desc": "В тенистых уголках острова растут редкие грибы: освежающий Лазурник и магический Сумеречник. Найдите по одному каждого вида.",
		"icon_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"icon_region": Rect2(272, 32, 16, 16),
		"status": "active",
		"objectives": [
			{
				"id": "blue_shroom",
				"text": "Найти лазурник",
				"type": "gather",
				"target_item": "blue_mushroom",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			},
			{
				"id": "purple_shroom",
				"text": "Найти сумеречник",
				"type": "gather",
				"target_item": "purple_mushroom",
				"target_amount": 1,
				"current_amount": 0,
				"is_done": false
			}
		],
		"rewards": [
			{"type": "coin", "item_id": "coin", "name": "Монеты", "amount": 150},
			{"type": "item", "item_id": "storage_box", "name": "Ящик для хранения", "amount": 1}
		]
	}
}

func _ready() -> void:
	if InventoryManager.has_signal("inventory_changed"):
		InventoryManager.inventory_changed.connect(_on_inventory_changed)
	
	# Initial evaluation deferred to let other singletons initialize
	call_deferred("evaluate_all_quests")

func _on_inventory_changed(_item_id: String, _new_amount: int) -> void:
	evaluate_all_quests()

func evaluate_all_quests() -> void:
	for q_id in quests:
		var q = quests[q_id]
		if q.get("status") == "claimed":
			continue
		
		var all_done = true
		for obj in q.get("objectives", []):
			var o_type = obj.get("type", "gather")
			var target_item = obj.get("target_item", "")
			var target_amount = obj.get("target_amount", 1)
			
			if o_type == "gather":
				var inv_amt = InventoryManager.get_item_amount(target_item)
				obj["current_amount"] = inv_amt
				obj["is_done"] = (inv_amt >= target_amount)
			elif o_type == "craft":
				var inv_amt = InventoryManager.get_item_amount(target_item)
				if inv_amt > obj.get("current_amount", 0):
					obj["current_amount"] = inv_amt
				obj["is_done"] = (obj.get("current_amount", 0) >= target_amount)
			
			if not obj.get("is_done", false):
				all_done = false
		
		var prev_status = q.get("status", "active")
		if all_done:
			if prev_status != "completed":
				q["status"] = "completed"
				quest_completed.emit(q_id)
				quest_updated.emit(q_id)
		else:
			if prev_status == "completed":
				q["status"] = "active"
				quest_updated.emit(q_id)

func report_craft(item_id: String, amount: int = 1) -> void:
	var any_changed = false
	for q_id in quests:
		var q = quests[q_id]
		if q.get("status") == "claimed":
			continue
		
		for obj in q.get("objectives", []):
			if obj.get("type") == "craft" and obj.get("target_item") == item_id:
				var current = obj.get("current_amount", 0)
				var target = obj.get("target_amount", 1)
				obj["current_amount"] = min(target, current + amount)
				obj["is_done"] = (obj["current_amount"] >= target)
				any_changed = true
	
	if any_changed:
		evaluate_all_quests()

func report_event(event_type: String, target_id: String, amount: int = 1) -> void:
	var any_changed = false
	for q_id in quests:
		var q = quests[q_id]
		if q.get("status") == "claimed":
			continue
		for obj in q.get("objectives", []):
			if obj.get("type") == event_type and obj.get("target_item") == target_id:
				var current = obj.get("current_amount", 0)
				var target = obj.get("target_amount", 1)
				obj["current_amount"] = min(target, current + amount)
				obj["is_done"] = (obj["current_amount"] >= target)
				any_changed = true
	if any_changed:
		evaluate_all_quests()

func claim_reward(quest_id: String) -> bool:
	if not quests.has(quest_id):
		return false
	var q = quests[quest_id]
	if q.get("status") != "completed":
		return false
	
	# Give rewards to player
	for rew in q.get("rewards", []):
		var r_item = rew.get("item_id", "")
		var r_amount = rew.get("amount", 1)
		if r_item != "":
			InventoryManager.add_item(r_item, r_amount)
	
	q["status"] = "claimed"
	
	# Play fanfare SFX
	if SFX_QUEST_COMPLETE and AudioManager:
		AudioManager.play_sfx(SFX_QUEST_COMPLETE)
		
	quest_claimed.emit(quest_id)
	quest_updated.emit(quest_id)
	return true

func get_quest(quest_id: String) -> Dictionary:
	return quests.get(quest_id, {})

func get_quests_by_category(category: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for q_id in quests:
		var q = quests[q_id]
		var status = q.get("status", "active")
		if category == CAT_COMPLETED:
			if status == "completed" or status == "claimed":
				result.append(q)
		else:
			if q.get("category") == category and status != "completed" and status != "claimed":
				result.append(q)
	return result

func get_unclaimed_completed_count() -> int:
	var count = 0
	for q_id in quests:
		if quests[q_id].get("status") == "completed":
			count += 1
	return count

func is_quest_completed(quest_id: String) -> bool:
	var q = quests.get(quest_id, {})
	return q.get("status") == "completed"

func is_quest_claimed(quest_id: String) -> bool:
	var q = quests.get(quest_id, {})
	return q.get("status") == "claimed"
