extends Control
class_name StatsHud

## StatsHud — компактный HUD со шкалами HP/Stamina/Hunger.
## Поддерживает:
## - Компактные аккуратные значки с центрированной пульсацией (сжатием)
## - Точные цифры при наведении курсора на шкалу (всплывающие подписи + тултипы)
## - Автоматическое скрытие HUD при открытии меню (Книга, Сундук, Лодка, Дебаг)

@onready var health_container: HBoxContainer = $HealthContainer
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var heart_icon: TextureRect = $HealthContainer/HeartIcon
@onready var health_hover: Label = $HealthContainer/HealthHover

@onready var stamina_container: HBoxContainer = $StaminaContainer
@onready var stamina_bar: ProgressBar = $StaminaContainer/StaminaBar
@onready var stamina_icon: TextureRect = $StaminaContainer/StaminaIcon
@onready var stamina_hover: Label = $StaminaContainer/StaminaHover

@onready var hunger_container: HBoxContainer = $HungerContainer
@onready var hunger_bar: ProgressBar = $HungerContainer/HungerBar
@onready var hunger_icon: TextureRect = $HungerContainer/HungerIcon
@onready var hunger_hover: Label = $HungerContainer/HungerHover

# Ссылки на fill-стили для динамической смены цвета
var stamina_fill_style: StyleBoxTexture
var hunger_fill_style: StyleBoxTexture
var _stamina_shake_tween: Tween

# Флаги наведения курсора
var _hover_health: bool = false
var _hover_stamina: bool = false
var _hover_hunger: bool = false

func _ready() -> void:
	# Обрабатывать даже во время паузы игры (когда открыт инвентарь или сундук)
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Центрируем опорную точку (pivot) строго по центру значков
	_setup_icon_pivots()

	# Забираем fill-стили из ProgressBar
	stamina_fill_style = stamina_bar.get_theme_stylebox("fill") as StyleBoxTexture
	hunger_fill_style = hunger_bar.get_theme_stylebox("fill") as StyleBoxTexture

	# Инициализируем значения
	health_bar.max_value = GameStateManager.max_health
	health_bar.value = GameStateManager.current_health
	stamina_bar.max_value = GameStateManager.max_stamina
	stamina_bar.value = GameStateManager.current_stamina
	hunger_bar.max_value = GameStateManager.max_hunger
	hunger_bar.value = GameStateManager.current_hunger

	# Обновляем текст тултипов и подписей
	_update_tooltips()

	# Подключаем наведение мыши для точных цифр
	_setup_hover_events()

	# Подключаем сигналы состояния игрока
	GameStateManager.health_changed.connect(_on_health_changed)
	GameStateManager.player_hurt.connect(_on_player_hurt)
	GameStateManager.stamina_changed.connect(_on_stamina_changed)
	GameStateManager.stamina_depleted.connect(_on_stamina_depleted)
	GameStateManager.hunger_changed.connect(_on_hunger_changed)

	# Отслеживаем открытие других интерфейсов (книга, сундук, лодка, консоль)
	_setup_overlay_tracking()

func _process(_delta: float) -> void:
	_check_overlay_visibility()

func _setup_icon_pivots() -> void:
	for icon in [heart_icon, stamina_icon, hunger_icon]:
		if icon:
			icon.pivot_offset = icon.custom_minimum_size * 0.5

func _setup_hover_events() -> void:
	if health_bar:
		health_bar.mouse_entered.connect(func(): _set_hover_state("hp", true))
		health_bar.mouse_exited.connect(func(): _set_hover_state("hp", false))
	if health_container:
		health_container.mouse_entered.connect(func(): _set_hover_state("hp", true))
		health_container.mouse_exited.connect(func(): _set_hover_state("hp", false))

	if stamina_bar:
		stamina_bar.mouse_entered.connect(func(): _set_hover_state("st", true))
		stamina_bar.mouse_exited.connect(func(): _set_hover_state("st", false))
	if stamina_container:
		stamina_container.mouse_entered.connect(func(): _set_hover_state("st", true))
		stamina_container.mouse_exited.connect(func(): _set_hover_state("st", false))

	if hunger_bar:
		hunger_bar.mouse_entered.connect(func(): _set_hover_state("hg", true))
		hunger_bar.mouse_exited.connect(func(): _set_hover_state("hg", false))
	if hunger_container:
		hunger_container.mouse_entered.connect(func(): _set_hover_state("hg", true))
		hunger_container.mouse_exited.connect(func(): _set_hover_state("hg", false))

func _set_hover_state(type: String, is_hover: bool) -> void:
	match type:
		"hp":
			_hover_health = is_hover
			if health_hover:
				health_hover.text = "%d/%d" % [int(ceil(GameStateManager.current_health)), int(GameStateManager.max_health)]
				health_hover.visible = is_hover
		"st":
			_hover_stamina = is_hover
			if stamina_hover:
				stamina_hover.text = "%d/%d" % [int(ceil(GameStateManager.current_stamina)), int(GameStateManager.max_stamina)]
				stamina_hover.visible = is_hover
		"hg":
			_hover_hunger = is_hover
			if hunger_hover:
				hunger_hover.text = "%d/%d" % [int(ceil(GameStateManager.current_hunger)), int(GameStateManager.max_hunger)]
				hunger_hover.visible = is_hover

func _update_tooltips() -> void:
	if health_bar:
		health_bar.tooltip_text = "Здоровье: %d / %d" % [int(ceil(GameStateManager.current_health)), int(GameStateManager.max_health)]
	if stamina_bar:
		stamina_bar.tooltip_text = "Выносливость: %d / %d" % [int(ceil(GameStateManager.current_stamina)), int(GameStateManager.max_stamina)]
	if hunger_bar:
		hunger_bar.tooltip_text = "Сытость: %d / %d" % [int(ceil(GameStateManager.current_hunger)), int(GameStateManager.max_hunger)]

# ─── Сжатие значков строго по центру ──────────────────────────────────────────

func _animate_icon_squeeze(icon: TextureRect) -> void:
	if not icon: return
	icon.pivot_offset = icon.custom_minimum_size * 0.5
	var tw = create_tween()
	# Сжатие внутрь к центру (0.7) -> сочный отскок наружу (1.25) -> возвращение в норму (1.0)
	tw.tween_property(icon, "scale", Vector2(0.7, 0.7), 0.05).set_trans(Tween.TRANS_SINE)
	tw.tween_property(icon, "scale", Vector2(1.22, 1.22), 0.08).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(icon, "scale", Vector2(1.0, 1.0), 0.09).set_trans(Tween.TRANS_SINE)

# ─── Скрытие при открытии других интерфейсов ─────────────────────────────────

func _setup_overlay_tracking() -> void:
	var ui_layer = get_parent()
	if not ui_layer: return
	for ui_name in ["BookUI", "StorageUI", "BoatUI", "DebugPanel"]:
		var node = ui_layer.get_node_or_null(ui_name)
		if node and not node.visibility_changed.is_connected(_check_overlay_visibility):
			node.visibility_changed.connect(_check_overlay_visibility)
	_check_overlay_visibility()

func _check_overlay_visibility() -> void:
	var ui_layer = get_parent()
	if not ui_layer: return
	
	var any_overlay_open = false
	for ui_name in ["BookUI", "StorageUI", "BoatUI", "DebugPanel"]:
		var node = ui_layer.get_node_or_null(ui_name)
		if node and node.visible:
			any_overlay_open = true
			break
			
	if visible == any_overlay_open:
		visible = not any_overlay_open

# ─── Health ──────────────────────────────────────────────────────────────────

func _on_health_changed(new_val: float, max_val: float) -> void:
	health_bar.max_value = max_val
	var tw = create_tween()
	tw.tween_property(health_bar, "value", new_val, 0.2)
	_animate_icon_squeeze(heart_icon)
	_update_tooltips()
	if _hover_health and health_hover:
		health_hover.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]

func _on_player_hurt() -> void:
	var tw = create_tween()
	tw.tween_property(health_container, "position:x", health_container.position.x - 3.0, 0.03)
	tw.tween_property(health_container, "position:x", health_container.position.x + 3.0, 0.04)
	tw.tween_property(health_container, "position:x", health_container.position.x, 0.03)
	_animate_icon_squeeze(heart_icon)

# ─── Stamina ─────────────────────────────────────────────────────────────────

func _on_stamina_changed(new_val: float, max_val: float) -> void:
	stamina_bar.max_value = max_val
	var tw = create_tween()
	tw.tween_property(stamina_bar, "value", new_val, 0.1)
	if stamina_fill_style:
		if GameStateManager.is_exhausted:
			stamina_fill_style.modulate_color = Color(0.92, 0.3, 0.2, 1.0)
			_start_stamina_shake()
		else:
			stamina_fill_style.modulate_color = Color(0.25, 0.85, 0.35, 1.0)
			_stop_stamina_shake()
			
	_animate_icon_squeeze(stamina_icon)
	_update_tooltips()
	if _hover_stamina and stamina_hover:
		stamina_hover.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]

func _on_stamina_depleted() -> void:
	var base_x := stamina_container.position.x
	var tw = create_tween()
	tw.tween_property(stamina_container, "position:x", base_x - 4.0, 0.04)
	tw.tween_property(stamina_container, "position:x", base_x + 4.0, 0.04)
	tw.tween_property(stamina_container, "position:x", base_x - 3.0, 0.04)
	tw.tween_property(stamina_container, "position:x", base_x + 3.0, 0.04)
	tw.tween_property(stamina_container, "position:x", base_x, 0.04)
	if stamina_fill_style and not GameStateManager.is_exhausted:
		stamina_fill_style.modulate_color = Color(0.92, 0.3, 0.2, 1.0)
		var t = get_tree().create_timer(0.3)
		t.timeout.connect(func():
			if not GameStateManager.is_exhausted and stamina_fill_style:
				stamina_fill_style.modulate_color = Color(0.25, 0.85, 0.35, 1.0)
		)
	_animate_icon_squeeze(stamina_icon)

func _start_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid() and _stamina_shake_tween.is_running():
		return
	var base_x := stamina_container.position.x
	_stamina_shake_tween = create_tween().set_loops()
	_stamina_shake_tween.tween_property(stamina_container, "position:x", base_x - 3.0, 0.04)
	_stamina_shake_tween.tween_property(stamina_container, "position:x", base_x + 3.0, 0.04)
	_stamina_shake_tween.tween_property(stamina_container, "position:x", base_x, 0.04)

func _stop_stamina_shake() -> void:
	if _stamina_shake_tween and _stamina_shake_tween.is_valid():
		_stamina_shake_tween.kill()
	stamina_container.position.x = 70.0

# ─── Hunger ──────────────────────────────────────────────────────────────────

func _on_hunger_changed(new_val: float, max_val: float) -> void:
	hunger_bar.max_value = max_val
	var tw = create_tween()
	tw.tween_property(hunger_bar, "value", new_val, 0.15)
	if hunger_fill_style:
		if new_val <= 20.0:
			hunger_fill_style.modulate_color = Color(0.9, 0.25, 0.2, 1.0)
		elif new_val <= 50.0:
			hunger_fill_style.modulate_color = Color(0.95, 0.55, 0.15, 1.0)
		else:
			hunger_fill_style.modulate_color = Color(0.95, 0.65, 0.18, 1.0)
			
	_animate_icon_squeeze(hunger_icon)
	_update_tooltips()
	if _hover_hunger and hunger_hover:
		hunger_hover.text = "%d/%d" % [int(ceil(new_val)), int(max_val)]
