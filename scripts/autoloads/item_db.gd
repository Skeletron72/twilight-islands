extends Node

const ITEM_SIZE = 16
var atlas_texture_file = preload("res://resources/items/Items.png")

# База рецептов для крафта
var RECIPES = {
	"wooden_axe": {"wood": 2, "stick": 3},
	"wooden_pickaxe": {"wood": 2, "stick": 3},
	"stone_axe": {"stick": 2, "stone": 1},
	"stone_pickaxe": {"stick": 2, "stone": 1},
	"stone_sword": {"stick": 1, "stone": 2},
	"cloth_basic": {"wood": 10},
	"campfire": {"wood": 5, "stone": 3},
	"storage_box": {"wood": 10}
}

var ITEMS = {
	# --- РЕСУРСЫ ---
		"red_berry": {
		"name": "Рубиновая ягода",
		"desc": "Сочная ягода. Отлично утоляет голод и немного лечит.",
		"max_stack": 99,
		"hunger_restore": 20.0,
		"health_restore": 15.0,
		"grid_pos": Vector2(13, 3),
		"particle_color": Color(0.9, 0.1, 0.1, 1.0)
	},
	"yellow_berry": {
		"name": "Золотистая ягода",
		"desc": "Терпкая ягода. Слегка утоляет голод и бодрит.",
		"max_stack": 99,
		"hunger_restore": 10.0,
		"stamina_restore": 25.0,
		"grid_pos": Vector2(12, 3),
		"particle_color": Color(0.95, 0.85, 0.1, 1.0)
	},

	"wood": {
		"name": "Древесина",
		"desc": "Свежее бревно, срубленное на острове.",
		"max_stack": 99,
		"grid_pos": Vector2(2, 2)
	},
	"stick": {
		"name": "Ветка",
		"desc": "Обычная деревянная палка. Полезна для крафта.",
		"max_stack": 99,
		"grid_pos": Vector2(14, 3)
	},
	"stone": {
		"name": "Камень",
		"desc": "Прочный булыжник.",
		"max_stack": 99,
		"grid_pos": Vector2(2, 1)
	},
	"twilight_ore": {
		"name": "Сумрачная руда",
		"desc": "Светящаяся в темноте руда.",
		"max_stack": 50,
		"grid_pos": Vector2(5, 3)
	},
	
	# --- ОДЕЖДА ---
	"cloth_basic": {
		"name": "Простая рубаха",
		"desc": "Удобная одежда для выживания.",
		"max_stack": 1,
		"equip_slot": "chest",
		"defense": 2,
		"durability": 100,
		"grid_pos": Vector2(5, 15)
	},
	"boots_basic": {
		"name": "Кожаные сапоги",
		"desc": "Защищают ноги от колючек.",
		"max_stack": 1,
		"equip_slot": "boots",
		"defense": 1,
		"durability": 80,
		"grid_pos": Vector2(1, 17)
	},
	
	# --- ИНСТРУМЕНТЫ ---
	"wooden_axe": {
		"name": "Деревянный топор",
		"desc": "Слабый, но лучше, чем рубить руками.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 2,
		"efficiency": 1,
		"durability": 50,
		"grid_pos": Vector2(1, 5) # Пример
	},
	"stone_axe": {
		"name": "Каменный топор",
		"desc": "Острый камень на палке.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"grid_pos": Vector2(2, 5)
	},
	"wooden_pickaxe": {
		"name": "Деревянная кирка",
		"desc": "Хлипкая кирка для мягких камней.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 2,
		"efficiency": 1,
		"durability": 50,
		"grid_pos": Vector2(1, 9)
	},
	"stone_pickaxe": {
		"name": "Каменная кирка",
		"desc": "Надежный инструмент шахтера.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"grid_pos": Vector2(2, 9)
	},
		"stone_sword": {
		"name": "Каменный меч",
		"desc": "Идеально для сражений со скелетами.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 8,
		"durability": 150,
		"grid_pos": Vector2(2, 7)
	},
	"campfire": {
		"name": "Костер",
		"desc": "Согревает и освещает в ночи. Можно готовить.",
		"max_stack": 10,
		"placeable": true,
		"scene": "res://scenes/objects/campfire.tscn",
		"grid_pos": Vector2(2, 32)
	},
	"storage_box": {
		"name": "Деревянный сундук",
		"desc": "Для хранения ваших вещей.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/storage_box.tscn",
		"grid_pos": Vector2(4, 32)
	}
}

func get_item(id: String) -> Dictionary:
	if ITEMS.has(id):
		return ITEMS[id]
	return {}

func get_icon(id: String) -> Texture2D:
	var item = get_item(id)
	if item.is_empty(): return null
	
	if item.has("custom_atlas"):
		var atlas = AtlasTexture.new()
		atlas.atlas = load(item["custom_atlas"])
		atlas.region = item["custom_region"]
		return atlas
		
	if item.has("grid_pos"):
		var pos = item["grid_pos"]
		var atlas = AtlasTexture.new()
		atlas.atlas = atlas_texture_file
		atlas.region = Rect2((pos.x - 1) * ITEM_SIZE, (pos.y - 1) * ITEM_SIZE, ITEM_SIZE, ITEM_SIZE)
		return atlas
		
	return null
