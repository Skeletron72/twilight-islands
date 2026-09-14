extends Node

const ITEM_SIZE = 16
var atlas_texture_file = preload("res://resources/items/Items.png")
const RES_ICONS = "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Resources_Icons_NO_Outline.png"
const TOOL_ICONS = "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Tool_Icons_NO_Outline.png"

# База рецептов для крафта
var RECIPES = {
	"axe": {"wood": 3, "stick": 2},
	"pickaxe": {"wood": 2, "stick": 2, "stone": 2},
	"sword": {"stick": 1, "stone": 2},
	"bow": {"wood": 3, "plant_fiber": 4},
	"arrow": {"stick": 1, "plant_fiber": 1},
	"cloth_basic": {"plant_fiber": 6},
	"boots_basic": {"plant_fiber": 4},
	"campfire": {"wood": 5, "stone": 3, "plant_fiber": 2},
	"storage_box": {"wood": 10},
	"tent": {"wood": 6, "stick": 4, "plant_fiber": 6},
	"orange_bed": {"wood": 4, "stick": 2, "cloth_basic": 1}
}

signal recipe_unlocked(recipe_id: String)

# Стартовые рецепты, открытые со старта
const STARTING_RECIPES: Array[String] = [
	"campfire",
	"axe",
	"cloth_basic"
]

# Правила открытия рецептов при получении ключевых материалов (Discovery)
const DISCOVERY_RULES: Dictionary = {
	"stone": ["pickaxe", "sword"],
	"plant_fiber": ["boots_basic", "arrow"],
	"cloth_basic": ["orange_bed"],
	"wood": ["storage_box", "tent"],
	"stick": ["bow"]
}

# Подсказки для закрытых рецептов
const RECIPE_HINTS: Dictionary = {
	"pickaxe": "Найдите и соберите каменный булыжник (камень)",
	"sword": "Найдите и соберите каменный булыжник (камень)",
	"bow": "Соберите палки и волокна",
	"arrow": "Соберите растительные волокна",
	"boots_basic": "Соберите растительные волокна",
	"orange_bed": "Сотките льняную ткань или обучитесь у Корабельщика Финна",
	"storage_box": "Соберите древесину (топором из деревьев)",
	"tent": "Соберите древесину, палки и волокна",
}

var unlocked_recipes: Dictionary = {}

func _ready() -> void:
	for r in STARTING_RECIPES:
		unlocked_recipes[r] = true

func is_recipe_unlocked(recipe_id: String) -> bool:
	return unlocked_recipes.get(recipe_id, false)

func unlock_recipe(recipe_id: String, silent: bool = false) -> bool:
	if not RECIPES.has(recipe_id):
		return false
	if is_recipe_unlocked(recipe_id):
		return false
		
	unlocked_recipes[recipe_id] = true
	recipe_unlocked.emit(recipe_id)
	
	if not silent and is_inside_tree():
		var item = get_item(recipe_id)
		var item_name = item.get("name", recipe_id)
		var exp_mgr = get_node_or_null("/root/ExpeditionManager")
		if exp_mgr and exp_mgr.has_method("post_thought"):
			exp_mgr.post_thought("📜 Новый рецепт открыт: %s!" % item_name, Color(1.0, 0.85, 0.35))
		var audio_mgr = get_node_or_null("/root/AudioManager")
		if audio_mgr and audio_mgr.has_method("play_sfx"):
			var sfx = load("res://assets/audio/sfx/player/sfx_craft.mp3")
			if sfx:
				audio_mgr.play_sfx(sfx)
	return true

func check_discovery(item_id: String) -> void:
	if DISCOVERY_RULES.has(item_id):
		for recipe_id in DISCOVERY_RULES[item_id]:
			if not is_recipe_unlocked(recipe_id):
				unlock_recipe(recipe_id)

func get_recipe_unlock_hint(recipe_id: String) -> String:
	return RECIPE_HINTS.get(recipe_id, "Исследуйте остров и находите новые материалы")


var ITEMS = {
	# --- РЕСУРСЫ ---
		"red_berry": {
		"name": "Рубиника",
		"desc": "Сочная алая ягода. Отлично утоляет голод и заживляет раны.",
		"max_stack": 99,
		"hunger_restore": 25.0,
		"health_restore": 20.0,
		"stamina_restore": 5.0,
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png",
		"custom_region": Rect2(64, 128, 16, 16),
		"particle_color": Color(0.95, 0.18, 0.22, 1.0)
	},
	"purple_berry": {
		"name": "Сумеречница",
		"desc": "Таинственная ночная ягода. Освежает дух, восстанавливает силы (и ману).",
		"max_stack": 99,
		"hunger_restore": 10.0,
		"health_restore": 5.0,
		"stamina_restore": 35.0,
		"mana_restore": 25.0, # Задел на будущее для магии
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png",
		"custom_region": Rect2(80, 128, 16, 16),
		"particle_color": Color(0.65, 0.25, 0.85, 1.0)
	},
	"red_mushroom": {
		"name": "Огневик",
		"desc": "Пряный гриб с алой шляпкой. Согревает кровь, утоляет голод и заживляет раны.",
		"max_stack": 99,
		"hunger_restore": 30.0,
		"health_restore": 35.0,
		"stamina_restore": 10.0,
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png",
		"custom_region": Rect2(64, 16, 16, 16),
		"particle_color": Color(0.95, 0.25, 0.15, 1.0)
	},
	"blue_mushroom": {
		"name": "Лазурник",
		"desc": "Прохладный мерцающий гриб. Снимает усталость и мгновенно восстанавливает выносливость.",
		"max_stack": 99,
		"hunger_restore": 15.0,
		"health_restore": 10.0,
		"stamina_restore": 50.0,
		"mana_restore": 15.0,
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png",
		"custom_region": Rect2(80, 16, 16, 16),
		"particle_color": Color(0.25, 0.65, 1.0, 1.0)
	},
	"purple_mushroom": {
		"name": "Сумеречник",
		"desc": "Светящийся гриб, пропитанный ночным туманом. Дарует мощный прилив древней магии.",
		"max_stack": 99,
		"hunger_restore": 15.0,
		"health_restore": 15.0,
		"stamina_restore": 25.0,
		"mana_restore": 50.0,
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png",
		"custom_region": Rect2(80, 0, 16, 16),
		"particle_color": Color(0.75, 0.35, 0.95, 1.0)
	},

	# --- БАЗОВЫЕ РЕСУРСЫ (Строка 4: Дерево, Кость, Палка) ---
	"wood": {
		"name": "Древесина",
		"desc": "Свежее бревно, срубленное на острове.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(0, 64, 16, 16)
	},
	"bone": {
		"name": "Кость",
		"desc": "Крепкая кость. Пригодится для крафта и зелий.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 64, 16, 16)
	},
	"stick": {
		"name": "Ветка",
		"desc": "Обычная деревянная палка. Полезна для крафта.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(32, 64, 16, 16)
	},
	"plant_fiber": {
		"name": "Растительное волокно",
		"desc": "Гибкие и прочные растительные волокна из кустарника. Незаменимы для ткани, веревок и снаряжения.",
		"max_stack": 99,
		"grid_pos": Vector2(15, 3)
	},
	"stone": {
		"name": "Камень",
		"desc": "Прочный булыжник.",
		"max_stack": 99,
		"grid_pos": Vector2(2, 1)
	},

	# --- МИНЕРАЛЫ И МЕТАЛЛЫ (1 крошка, 2 самородок, 3 слиток/огранка) ---

	# Строка 0: 1 Сталь, 2 Сапфир
	"steel_dust": {
		"name": "Стальная крошка",
		"desc": "Мелкая стальная стружка и крошка.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(0, 0, 16, 16)
	},
	"ore_steel": {
		"name": "Стальная руда",
		"desc": "Плотный самородок руды со стальным отливом.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 0, 16, 16)
	},
	"steel_nugget": {
		"name": "Стальной самородок",
		"desc": "Плотный самородок руды со стальным отливом.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 0, 16, 16)
	},
	"steel_ingot": {
		"name": "Стальной слиток",
		"desc": "Закаленный слиток стали высокой прочности.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(32, 0, 16, 16)
	},

	"sapphire_dust": {
		"name": "Сапфировая крошка",
		"desc": "Сияющие синие осколки сапфира.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(48, 0, 16, 16)
	},
	"mineral_sapphire": {
		"name": "Сапфир",
		"desc": "Благородный синий драгоценный кристалл, хранящий холод глубин.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 0, 16, 16)
	},
	"sapphire_raw": {
		"name": "Необработанный сапфир",
		"desc": "Природный кристалл сапфира.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 0, 16, 16)
	},
	"sapphire_gem": {
		"name": "Ограненный сапфир",
		"desc": "Идеально ограненный чистейший сапфир королевского синего цвета.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(80, 0, 16, 16)
	},

	# Строка 1: 3 Железо, 4 Топаз
	"iron_dust": {
		"name": "Железная крошка",
		"desc": "Остатки железной породы и металлическая пыль.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(0, 16, 16, 16)
	},
	"ore_iron": {
		"name": "Железная руда",
		"desc": "Тяжелая рудная порода с богатыми включениями железа.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 16, 16, 16)
	},
	"iron_nugget": {
		"name": "Железный самородок",
		"desc": "Тяжелый самородок железа.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 16, 16, 16)
	},
	"iron_ingot": {
		"name": "Железный слиток",
		"desc": "Прочный кованый слиток очищенного железа.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(32, 16, 16, 16)
	},

	"topaz_dust": {
		"name": "Топазовая крошка",
		"desc": "Мелкие сверкающие золотисто-оранжевые осколки.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(48, 16, 16, 16)
	},
	"mineral_topaz": {
		"name": "Топаз",
		"desc": "Солнечно-оранжевый самоцвет с мягким теплым сиянием.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 16, 16, 16)
	},
	"topaz_raw": {
		"name": "Необработанный топаз",
		"desc": "Природный кристалл топаза.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 16, 16, 16)
	},
	"topaz_gem": {
		"name": "Ограненный топаз",
		"desc": "Искрящийся теплым светом ювелирный топаз.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(80, 16, 16, 16)
	},

	# Строка 2: 5 Золото, 6 Рубин
	"gold_dust": {
		"name": "Золотой песок",
		"desc": "Драгоценные крупицы чистого золота.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(0, 32, 16, 16)
	},
	"ore_gold": {
		"name": "Золотая руда",
		"desc": "Сверкающий золотыми крупинками самородок.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 32, 16, 16)
	},
	"gold_nugget": {
		"name": "Золотой самородок",
		"desc": "Сверкающий золотом природный самородок.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 32, 16, 16)
	},
	"gold_ingot": {
		"name": "Золотой слиток",
		"desc": "Тяжелый слиток сияющего золота высшей пробы.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(32, 32, 16, 16)
	},

	"ruby_dust": {
		"name": "Рубиновая крошка",
		"desc": "Алые кристаллические крошки, вспыхивающие на свету.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(48, 32, 16, 16)
	},
	"mineral_ruby": {
		"name": "Рубин",
		"desc": "Пылающий алый кристалл, высоко ценимый ювелирами.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 32, 16, 16)
	},
	"ruby_raw": {
		"name": "Необработанный рубин",
		"desc": "Природный осколок алого рубина.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 32, 16, 16)
	},
	"ruby_gem": {
		"name": "Ограненный рубин",
		"desc": "Безупречный драгоценный камень глубокого рубинового оттенка.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(80, 32, 16, 16)
	},

	# Строка 3: 7 Малахит, 8 Сумрак
	"malachite_dust": {
		"name": "Малахитовая крошка",
		"desc": "Зеленый порошок и мелкие сколы малахита.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(0, 48, 16, 16)
	},
	"mineral_malachite": {
		"name": "Малахит",
		"desc": "Насыщенно-зелёный поделочный минерал с шелковистым блеском.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 48, 16, 16)
	},
	"malachite_raw": {
		"name": "Необработанный малахит",
		"desc": "Природный кусок зеленого малахита.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(16, 48, 16, 16)
	},
	"malachite_gem": {
		"name": "Полированный малахит",
		"desc": "Гладко отполированный камень с затейливыми узорами колец.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(32, 48, 16, 16)
	},

	"dusk_dust": {
		"name": "Пыль Сумрака",
		"desc": "Таинственная фиолетовая пыльца, мерцающая потусторонними искрами.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(48, 48, 16, 16)
	},
	"ore_dusk": {
		"name": "Осколок Сумрака",
		"desc": "Сверхредкий фиолетовый кристалл с пульсирующей энергией Бездны.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 48, 16, 16)
	},
	"dusk_shard": {
		"name": "Осколок Сумрака",
		"desc": "Сверхредкий фиолетовый кристалл с пульсирующей энергией Бездны.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 48, 16, 16)
	},
	"dusk_crystal": {
		"name": "Кристалл Сумрака",
		"desc": "Очищенный кристалл Сумрака невероятной мощи.",
		"max_stack": 99,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(80, 48, 16, 16)
	},
	"twilight_ore": {
		"name": "Сумрачная руда",
		"desc": "Светящаяся в темноте руда.",
		"max_stack": 50,
		"custom_atlas": RES_ICONS,
		"custom_region": Rect2(64, 48, 16, 16)
	},
	"coin": {
		"name": "Золотая монета",
		"desc": "Блестящая золотая монета для торговли с жителями.",
		"max_stack": 9999,
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png",
		"custom_region": Rect2(208, 48, 16, 16)
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
	
	# --- ИНСТРУМЕНТЫ И ОРУЖИЕ (Tool_Icons_NO_Outline.png: 1..10) ---
	# 1 лук
	"bow": {
		"name": "Лук",
		"desc": "Охотничий лук для стрельбы на расстоянии.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 6,
		"durability": 100,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(0, 0, 16, 16)
	},
	# 2 стрела
	"arrow": {
		"name": "Стрела",
		"desc": "Острая стрела с наконечником и оперением.",
		"max_stack": 99,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(16, 0, 16, 16)
	},
	# 3 кирка
	"pickaxe": {
		"name": "Кирка",
		"desc": "Универсальная кирка для добычи камня и руды.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 3,
		"efficiency": 2,
		"durability": 100,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(32, 0, 16, 16)
	},
	"wooden_pickaxe": {
		"name": "Деревянная кирка",
		"desc": "Хлипкая кирка для мягких камней.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 2,
		"efficiency": 1,
		"durability": 50,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(32, 0, 16, 16)
	},
	"stone_pickaxe": {
		"name": "Каменная кирка",
		"desc": "Надежный инструмент шахтера.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(32, 0, 16, 16)
	},
	# 4 топор
	"axe": {
		"name": "Топор",
		"desc": "Острый топор для рубки деревьев.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 100,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(48, 0, 16, 16)
	},
	"wooden_axe": {
		"name": "Деревянный топор",
		"desc": "Слабый, но лучше, чем рубить руками.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 2,
		"efficiency": 1,
		"durability": 50,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(48, 0, 16, 16)
	},
	"stone_axe": {
		"name": "Каменный топор",
		"desc": "Острый камень на палке.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 4,
		"efficiency": 2,
		"durability": 120,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(48, 0, 16, 16)
	},
	# 5 меч
	"sword": {
		"name": "Меч",
		"desc": "Надежное боевое оружие для защиты от монстров.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 8,
		"durability": 150,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(64, 0, 16, 16)
	},
	"stone_sword": {
		"name": "Каменный меч",
		"desc": "Идеально для сражений со скелетами.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 8,
		"durability": 150,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(64, 0, 16, 16)
	},
	# 6 тяпка
	"hoe": {
		"name": "Тяпка",
		"desc": "Тяпка (мотыга) для вспашки земли под грядки.",
		"max_stack": 1,
		"equip_slot": "tool",
		"damage": 2,
		"durability": 80,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(80, 0, 16, 16)
	},
	# 7 лейка
	"watering_can": {
		"name": "Лейка",
		"desc": "Лейка для полива сельскохозяйственных культур.",
		"max_stack": 1,
		"equip_slot": "tool",
		"durability": 100,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(96, 0, 16, 16)
	},
	# 8 удочка
	"fishing_rod": {
		"name": "Удочка",
		"desc": "Удочка с леской и поплавком для ловли рыбы.",
		"max_stack": 1,
		"equip_slot": "tool",
		"durability": 80,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(112, 0, 16, 16)
	},
	# 9 фонарь
	"lantern": {
		"name": "Фонарь",
		"desc": "Переносной масляный фонарь. Освещает путь в темноте.",
		"max_stack": 5,
		"equip_slot": "tool",
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(128, 0, 16, 16)
	},
	# 10 факел
	"torch": {
		"name": "Факел",
		"desc": "Яркий факел, разгоняющий ночную тьму и пещерный сумрак.",
		"max_stack": 99,
		"custom_atlas": TOOL_ICONS,
		"custom_region": Rect2(144, 0, 16, 16)
	},
	"campfire": {
		"name": "Костер",
		"desc": "Согревает и освещает в ночи. Можно готовить.",
		"max_stack": 10,
		"placeable": true,
		"scene": "res://scenes/objects/campfire.tscn",
		"custom_atlas": "res://assets/textures/objects/campfire_unlit.png",
		"custom_region": Rect2(0, 16, 16, 16)
	},
	"storage_box": {
		"name": "Деревянный сундук",
		"desc": "Для хранения ваших вещей.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/storage_box.tscn",
		"grid_pos": Vector2(4, 32)
	},
	"tent": {
		"name": "Палатка",
		"desc": "Уютный походный шатёр. Защитит от ветра и ночного холода.",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/buildings/tent.tscn",
		"custom_atlas": "res://assets/textures/icons/tent_icon.png",
		"custom_region": Rect2(0, 0, 16, 16)
	},
	"orange_bed": {
		"name": "Оранжевая кровать",
		"desc": "Уютная односпальная кровать. Позволяет скоротать ночь и набраться сил. (Крутить на R)",
		"max_stack": 5,
		"placeable": true,
		"scene": "res://scenes/objects/furniture/orange_bed.tscn",
		"custom_atlas": "res://assets/new_assets/Cute_Fantasy/Buildings/House_Decor/Beds.png",
		"custom_region": Rect2(144, 8, 16, 16)
	}
}

const TOOL_ALIASES = {
	"wooden_axe": "axe",
	"stone_axe": "axe",
	"wooden_pickaxe": "pickaxe",
	"stone_pickaxe": "pickaxe",
	"stone_sword": "sword"
}

func get_item(id: String) -> Dictionary:
	var mapped_id = TOOL_ALIASES.get(id, id)
	if ITEMS.has(mapped_id):
		return ITEMS[mapped_id]
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
