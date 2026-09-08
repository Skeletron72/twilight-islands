extends Node

enum TimeOfDay { MORNING, DAY, DUSK, NIGHT }

var current_time: TimeOfDay = TimeOfDay.MORNING
var current_day: int = 1

var max_health: float = 100.0
var current_health: float = 100.0

signal health_changed(new_value: float, max_value: float)
signal player_died()
signal player_hurt()

func take_damage(amount: float) -> void:
	if current_health > 0:
		current_health -= amount
		if current_health > 0:
			player_hurt.emit()
		if current_health <= 0:
			current_health = 0
			player_died.emit()
		health_changed.emit(current_health, max_health)

func heal(amount: float) -> void:
	if current_health > 0 and current_health < max_health:
		current_health = min(current_health + amount, max_health)
		health_changed.emit(current_health, max_health)


var max_stamina: float = 100.0
var current_stamina: float = 100.0

signal stamina_changed(new_value: float, max_value: float)

var is_exhausted: bool = false

func consume_stamina(amount: float) -> bool:
	if current_stamina >= amount and not is_exhausted:
		current_stamina -= amount
		if current_stamina <= 0.5:
			is_exhausted = true
		stamina_changed.emit(current_stamina, max_stamina)
		return true
	return false

func add_stamina(amount: float) -> void:
	if current_stamina < max_stamina:
		current_stamina = min(current_stamina + amount, max_stamina)
		if is_exhausted and current_stamina >= 15.0:
			is_exhausted = false
		stamina_changed.emit(current_stamina, max_stamina)


signal time_changed(new_time: TimeOfDay)
signal day_changed(new_day: int)

func advance_time() -> void:
	match current_time:
		TimeOfDay.MORNING:
			set_time(TimeOfDay.DAY)
		TimeOfDay.DAY:
			set_time(TimeOfDay.DUSK)
		TimeOfDay.DUSK:
			set_time(TimeOfDay.NIGHT)
		TimeOfDay.NIGHT:
			advance_day()

func set_time(new_time: TimeOfDay) -> void:
	current_time = new_time
	time_changed.emit(current_time)

func advance_day() -> void:
	current_day += 1
	current_time = TimeOfDay.MORNING
	day_changed.emit(current_day)
	time_changed.emit(current_time)

var max_hunger: float = 100.0
var current_hunger: float = 100.0
signal hunger_changed(new_value: float, max_value: float)
signal item_consumed(item_id: String, color: Color)

func add_hunger(amount: float) -> void:
	current_hunger = min(current_hunger + amount, max_hunger)
	hunger_changed.emit(current_hunger, max_hunger)

# ==============================================================================
# GAME STATISTICS (real counters, scaled automatically)
# ==============================================================================
var stat_trees_chopped: int = 0
var stat_stones_mined: int = 0
var stat_items_crafted: int = 0
var stat_distance_traveled: float = 0.0   # in pixels, divide by 16 for tiles
var stat_items_gathered: int = 0          # total items ever picked up
var stat_monsters_killed: int = 0
var stat_fish_caught: int = 0
var stat_treasures_found: int = 0
var stat_chests_opened: int = 0
var stat_campfires_lit: int = 0
var stat_bushes_harvested: int = 0
var crafted_recipes: Dictionary = {}
var unlocked_achievements: Dictionary = {}
var _last_player_position: Vector2 = Vector2.ZERO

func register_tree_chopped() -> void:
	stat_trees_chopped += 1

func register_stone_mined() -> void:
	stat_stones_mined += 1

func register_item_crafted(recipe_id: String = "") -> void:
	stat_items_crafted += 1
	if recipe_id != "":
		crafted_recipes[recipe_id] = true

func register_item_gathered(amount: int = 1) -> void:
	stat_items_gathered += amount

func register_monster_killed() -> void:
	stat_monsters_killed += 1

func register_fish_caught() -> void:
	stat_fish_caught += 1

func register_treasure_found() -> void:
	stat_treasures_found += 1

func register_chest_opened() -> void:
	stat_chests_opened += 1
	stat_treasures_found += 1

func register_campfire_lit() -> void:
	stat_campfires_lit += 1

func register_bush_harvested() -> void:
	stat_bushes_harvested += 1

func update_player_position(pos: Vector2) -> void:
	if _last_player_position != Vector2.ZERO:
		stat_distance_traveled += _last_player_position.distance_to(pos)
	_last_player_position = pos

func get_distance_meters() -> float:
	# 1 tile = 16px = 1 meter
	return stat_distance_traveled / 16.0

func get_distance_km() -> float:
	# 1 km = 1000 tiles = 16000px
	return stat_distance_traveled / 16000.0

func get_distance_display() -> String:
	var m = get_distance_meters()
	if m < 1000.0:
		return "%d м" % int(round(m))
	else:
		return "%.2f км" % (m / 1000.0)

func get_completed_quests_count() -> int:
	if not has_node("/root/QuestManager"):
		return 0
	var qm = get_node("/root/QuestManager")
	var count = 0
	for q_id in qm.quests:
		if qm.quests[q_id].get("status") in ["completed", "claimed"]:
			count += 1
	return count

func get_total_quests_count() -> int:
	if not has_node("/root/QuestManager"):
		return 0
	var qm = get_node("/root/QuestManager")
	return qm.quests.size()

func get_known_recipes_count() -> int:
	return crafted_recipes.size()

func get_total_recipes_count() -> int:
	if not has_node("/root/ItemDB"):
		return 0
	return get_node("/root/ItemDB").RECIPES.size()

func get_stat_value(key: String) -> Variant:
	match key:
		"day", "current_day":
			return current_day
		"trees_chopped":
			return stat_trees_chopped
		"stones_mined":
			return stat_stones_mined
		"items_crafted":
			return stat_items_crafted
		"items_gathered":
			return stat_items_gathered
		"monsters_killed":
			return stat_monsters_killed
		"fish_caught":
			return stat_fish_caught
		"treasures_found", "chests_opened":
			return stat_chests_opened
		"campfires_lit":
			return stat_campfires_lit
		"bushes_harvested":
			return stat_bushes_harvested
		"distance_meters":
			return get_distance_meters()
		"distance_km":
			return get_distance_km()
		"recipes_crafted":
			return get_known_recipes_count()
		"quests_completed":
			return get_completed_quests_count()
		"boat_level":
			return boat_level
	return 0

# ==============================================================================
# BOAT & EXPEDITION TIERS
# ==============================================================================
signal boat_upgraded(new_level: int)

var boat_level: int = 0

const BOAT_TIERS = {
	0: {
		"level": 0,
		"name": "Разбитый остов",
		"desc": "Лодка сильно повреждена прибоем. Требуется заделать пробоины и скрепить корпус досками перед отплытием.",
		"is_broken": true,
		"repair_cost": {"wood": 8, "stick": 4},
		"perks": ["Судно не способно выйти в море", "Требуется базовый ремонт"],
		"action_title": "Починить лодку"
	},
	1: {
		"level": 1,
		"name": "Простая лодка",
		"desc": "Легкая просмоленная лодка. Позволяет совершать первые вылазки на Сумеречный Остров.",
		"is_broken": false,
		"repair_cost": {"wood": 15, "stone": 6, "cloth_basic": 2},
		"perks": ["Доступ к экспедициям на Сумеречный остров", "Базовый трюм экспедиции"],
		"action_title": "Укрепить корпус (Ур. 2)"
	},
	2: {
		"level": 2,
		"name": "Укрепленный баркас",
		"desc": "Прочное судно с усиленным днищем и парусом. Лучше справляется с волнами и вмещает больше припасов.",
		"is_broken": false,
		"repair_cost": {"wood": 25, "stone": 12, "cloth_basic": 4},
		"perks": ["Повышенная вместимость безопасного трюма", "Экономия сил в рейдах"],
		"action_title": "Модернизировать в каравеллу (Ур. 3)"
	},
	3: {
		"level": 3,
		"name": "Сумеречная каравелла",
		"desc": "Настоящий флагман сумеречных морей с мачтой и фонарями. Максимальный уровень судна.",
		"is_broken": false,
		"repair_cost": {},
		"perks": ["Максимальный уровень корабля", "Оберег от ночных тварей при отплытии"],
		"action_title": "Максимальный уровень"
	}
}

func get_current_boat_tier() -> Dictionary:
	return BOAT_TIERS.get(boat_level, BOAT_TIERS[0])

func get_next_boat_tier() -> Dictionary:
	return BOAT_TIERS.get(boat_level + 1, {})

func can_upgrade_boat() -> bool:
	var current_tier = get_current_boat_tier()
	var cost: Dictionary = current_tier.get("repair_cost", {})
	if cost.is_empty():
		return false
	if not has_node("/root/InventoryManager"):
		return false
	var inv_mgr = get_node("/root/InventoryManager")
	for item_id in cost.keys():
		if inv_mgr.get_item_amount(item_id) < cost[item_id]:
			return false
	return true

func upgrade_boat() -> bool:
	if not can_upgrade_boat():
		return false
	var current_tier = get_current_boat_tier()
	var cost: Dictionary = current_tier.get("repair_cost", {})
	var inv_mgr = get_node("/root/InventoryManager")
	for item_id in cost.keys():
		inv_mgr.remove_item(item_id, cost[item_id])
	boat_level += 1
	boat_upgraded.emit(boat_level)
	return true

func _process(delta: float) -> void:
	# Hunger drains over time. 1 in-game day (15 mins?) let's say 1 point every 10 seconds.
	if current_hunger > 0:
		current_hunger -= (0.1 * delta)
		if current_hunger < 0:
			current_hunger = 0
		hunger_changed.emit(current_hunger, max_hunger)
