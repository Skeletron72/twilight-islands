extends Stone
class_name CaveOreRock

# Minable ore deposit found inside dungeon and cave floors.
# Uses Ores.png (8 rows of minerals/metals x 5 columns of vein variants).

enum OreType {
	STEEL = 0,     # Row 0: Сталь
	IRON = 1,      # Row 1: Железо
	GOLD = 2,      # Row 2: Золото
	MALACHITE = 3, # Row 3: Малахит (зеленый минерал)
	SAPPHIRE = 4,  # Row 4: Сапфир (синий минерал)
	TOPAZ = 5,     # Row 5: Топаз (оранжевый минерал)
	RUBY = 6,      # Row 6: Рубин (красный минерал)
	DUSK = 7       # Row 7: Сумрак (топ редкий металл)
}

enum VeinVariant {
	STONE_WITH_ORE = 0, # Col 0: Камень с рудой (дропает камень + немного руды)
	LARGE_VEIN = 1,     # Col 1: Большая жила (редкая, дропает больше руды)
	MEDIUM_VEIN = 2,    # Col 2: Средняя жила
	SMALL_VEIN_1 = 3,   # Col 3: Маленькая жила
	SMALL_VEIN_2 = 4    # Col 4: Маленькая жила v2
}

const ORE_ITEM_IDS = {
	OreType.STEEL: "ore_steel",
	OreType.IRON: "ore_iron",
	OreType.GOLD: "ore_gold",
	OreType.MALACHITE: "mineral_malachite",
	OreType.SAPPHIRE: "mineral_sapphire",
	OreType.TOPAZ: "mineral_topaz",
	OreType.RUBY: "mineral_ruby",
	OreType.DUSK: "ore_dusk"
}

const ORE_NAMES = {
	OreType.STEEL: "стальную руду",
	OreType.IRON: "железную руду",
	OreType.GOLD: "золотую руду",
	OreType.MALACHITE: "малахит",
	OreType.SAPPHIRE: "сапфир",
	OreType.TOPAZ: "топаз",
	OreType.RUBY: "рубин",
	OreType.DUSK: "кристалл Сумрака"
}

# Цвета свечения для самоцветов и Сумрака
const ORE_GLOW_COLORS = {
	OreType.MALACHITE: Color(0.15, 0.9, 0.45, 1.0),   # Зеленый малахит
	OreType.SAPPHIRE: Color(0.1, 0.65, 1.0, 1.0),     # Синий сапфир
	OreType.TOPAZ: Color(1.0, 0.65, 0.15, 1.0),       # Оранжевый топаз
	OreType.RUBY: Color(1.0, 0.2, 0.3, 1.0),          # Красный рубин
	OreType.DUSK: Color(0.85, 0.35, 1.0, 1.0)         # Фиолетовый Сумрак
}

@export var ore_type: OreType = OreType.IRON
@export var vein_variant: VeinVariant = VeinVariant.STONE_WITH_ORE

@onready var ore_light: PointLight2D = get_node_or_null("OreLight")
@onready var sparkle_particles: CPUParticles2D = get_node_or_null("SparkleParticles")

var _glow_base_energy: float = 0.5
var _pulse_timer: float = 0.0

func is_gatherable() -> bool:
	return false

func _ready() -> void:
	super._ready()
	_pulse_timer = randf() * TAU
	_setup_properties()
	_update_visuals()

func setup_ore(p_type: OreType, p_variant: VeinVariant) -> void:
	ore_type = p_type
	vein_variant = p_variant
	_setup_properties()
	_update_visuals()

func _setup_properties() -> void:
	var item_name = ORE_NAMES.get(ore_type, "руду")
	
	match vein_variant:
		VeinVariant.STONE_WITH_ORE:
			prompt_text = "Разбить камень со " + item_name
			hp = randi_range(2, 3)
		VeinVariant.LARGE_VEIN:
			prompt_text = "Добыть богатую жилу (" + item_name + ")"
			hp = randi_range(4, 5)
		VeinVariant.MEDIUM_VEIN:
			prompt_text = "Добыть жилу (" + item_name + ")"
			hp = randi_range(3, 4)
		VeinVariant.SMALL_VEIN_1, VeinVariant.SMALL_VEIN_2:
			prompt_text = "Добыть малую жилу (" + item_name + ")"
			hp = 2

func _update_visuals() -> void:
	if not sprite: return
	sprite.hframes = 8
	sprite.vframes = 8
	var row = clampi(int(ore_type), 0, 7)
	var col = clampi(int(vein_variant), 0, 4)
	sprite.frame = row * 8 + col
	
	# Настройка мягкого свечения для минералов (3..6) и Сумрака (7)
	var is_mineral = ore_type in [
		OreType.MALACHITE, OreType.SAPPHIRE, OreType.TOPAZ, OreType.RUBY
	]
	var is_dusk = (ore_type == OreType.DUSK)
	
	if ore_light:
		if is_mineral or is_dusk:
			ore_light.visible = true
			var glow_col = ORE_GLOW_COLORS.get(ore_type, Color.WHITE)
			ore_light.color = glow_col
			
			# Масштаб и яркость зависят от размера жилы
			var scale_factor = 1.0
			match vein_variant:
				VeinVariant.LARGE_VEIN:
					scale_factor = 1.6
					_glow_base_energy = 0.65
				VeinVariant.MEDIUM_VEIN:
					scale_factor = 1.3
					_glow_base_energy = 0.55
				VeinVariant.STONE_WITH_ORE:
					scale_factor = 0.9
					_glow_base_energy = 0.40
				_:
					scale_factor = 1.0
					_glow_base_energy = 0.48
					
			if is_dusk:
				# Сумрак светит ярче и загадочнее
				_glow_base_energy += 0.20
				scale_factor *= 1.2
				
			ore_light.energy = _glow_base_energy
			ore_light.texture_scale = scale_factor
			set_process(true)
		else:
			ore_light.visible = false
			set_process(false)
			
	# Настройка искрения исключительно для руды Сумрака
	if sparkle_particles:
		if is_dusk:
			sparkle_particles.emitting = true
			sparkle_particles.visible = true
			# Если жила большая, чуть больше искр
			if vein_variant == VeinVariant.LARGE_VEIN:
				sparkle_particles.amount = 6
			elif vein_variant == VeinVariant.STONE_WITH_ORE:
				sparkle_particles.amount = 3
			else:
				sparkle_particles.amount = 4
		else:
			sparkle_particles.emitting = false
			sparkle_particles.visible = false

func _process(delta: float) -> void:
	if is_dead: return
	if not ore_light or not ore_light.visible: return
	
	_pulse_timer += delta * 2.2
	# Плавная пульсация свечения
	var pulse = sin(_pulse_timer) * 0.1
	ore_light.energy = _glow_base_energy + pulse

func _spawn_drops() -> void:
	if ore_light and is_instance_valid(ore_light):
		var tw = create_tween()
		tw.tween_property(ore_light, "energy", 0.0, 0.15)
	if sparkle_particles and is_instance_valid(sparkle_particles):
		sparkle_particles.emitting = false

	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	var drop_id = ORE_ITEM_IDS.get(ore_type, "ore_iron")
	
	match vein_variant:
		VeinVariant.STONE_WITH_ORE:
			# Дропает 1-2 камня + 1 руду
			var stone_count = randi_range(1, 2)
			for i in range(stone_count):
				var drop = dropped_scene.instantiate()
				drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
				drop.setup("stone", 1)
				get_tree().current_scene.add_child(drop)
				
			var ore_drop = dropped_scene.instantiate()
			ore_drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
			ore_drop.setup(drop_id, 1)
			get_tree().current_scene.add_child(ore_drop)
			
		VeinVariant.LARGE_VEIN:
			# Большая жила: 3-5 руды + 30% шанс доп. самоцвета/монет
			var ore_count = randi_range(3, 5)
			for i in range(ore_count):
				var drop = dropped_scene.instantiate()
				drop.global_position = global_position + Vector2(randf_range(-8, 8), randf_range(-8, 8))
				drop.setup(drop_id, 1)
				get_tree().current_scene.add_child(drop)
				
			if randf() < 0.35:
				var bonus_drop = dropped_scene.instantiate()
				bonus_drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
				bonus_drop.setup("coin", randi_range(2, 6))
				get_tree().current_scene.add_child(bonus_drop)
				
		VeinVariant.MEDIUM_VEIN:
			# Средняя жила: 2-3 руды
			var ore_count = randi_range(2, 3)
			for i in range(ore_count):
				var drop = dropped_scene.instantiate()
				drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
				drop.setup(drop_id, 1)
				get_tree().current_scene.add_child(drop)
				
		VeinVariant.SMALL_VEIN_1, VeinVariant.SMALL_VEIN_2:
			# Маленькие жилы: 1-2 руды
			var ore_count = randi_range(1, 2)
			for i in range(ore_count):
				var drop = dropped_scene.instantiate()
				drop.global_position = global_position + Vector2(randf_range(-6, 6), randf_range(-6, 6))
				drop.setup(drop_id, 1)
				get_tree().current_scene.add_child(drop)
