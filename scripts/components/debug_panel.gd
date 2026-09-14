extends Control
class_name DebugPanel

## DebugPanel - панель разработчика для Twilight Islands.
## Включает:
## - Спавнер предметов с поиском, категориями, характеристиками со спрайтовыми иконками и выбором количества
## - Управление игроком: бессмертие (God Mode), HP, выносливость, сытость, эффекты статусов
## - Управление миром: время суток, скорость течения времени, день недели, смена погоды, вызов молний
## - Спавн и управление мобами: слаймы (всех цветов и размеров), скелеты, курицы, массовые действия

var active_tab: int = 0
var selected_item_id: String = ""
var give_quantity: int = 10
var spawn_count: int = 1
var search_filter: String = ""
var category_filter: String = "ALL"

# Ссылки на контейнеры
var main_panel: PanelContainer
var tabs_container: HBoxContainer
var content_container: MarginContainer

# Контейнеры вкладок
var tab_items: Control
var tab_player: Control
var tab_world: Control
var tab_mobs: Control

# Элементы вкладки предметов
var item_list_container: VBoxContainer
var preview_icon: TextureRect
var preview_name: Label
var preview_id: Label
var preview_desc: Label
var preview_stats: VBoxContainer
var qty_spinbox: SpinBox
var give_btn: Button
var toast_label: Label

# Элементы игрока
var god_mode_btn: Button
var hp_label: Label
var stamina_label: Label
var hunger_label: Label

# Элементы мира
var time_info_label: Label
var weather_info_label: Label

# Иконки статов из существующих ресурсов игры
var _tex_health: AtlasTexture
var _tex_stamina: AtlasTexture
var _tex_hunger: AtlasTexture
var _tex_sword: AtlasTexture
var _tex_shield: AtlasTexture
var _tex_stack: AtlasTexture
var _tex_craft: AtlasTexture
var _tex_pickaxe: Texture2D
var _tex_axe: Texture2D

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	z_index = 3500
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	hide()
	
	_init_stat_icons()
	_build_ui()
	_populate_items()

func _init_stat_icons() -> void:
	var ui_icons = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Icons.png")
	var food_icons = preload("res://assets/new_assets/Cute_Fantasy/Icons/No Outline/Food_Icons_NO_Outline.png")
	
	_tex_health = AtlasTexture.new()
	_tex_health.atlas = ui_icons
	_tex_health.region = Rect2(0, 0, 16, 16)
	
	_tex_stamina = AtlasTexture.new()
	_tex_stamina.atlas = ui_icons
	_tex_stamina.region = Rect2(144, 0, 16, 16)
	
	_tex_hunger = AtlasTexture.new()
	_tex_hunger.atlas = food_icons
	_tex_hunger.region = Rect2(0, 16, 16, 16)
	
	_tex_sword = AtlasTexture.new()
	_tex_sword.atlas = ui_icons
	_tex_sword.region = Rect2(96, 16, 16, 16)
	
	_tex_shield = AtlasTexture.new()
	_tex_shield.atlas = ui_icons
	_tex_shield.region = Rect2(192, 0, 16, 16)
	
	_tex_stack = AtlasTexture.new()
	_tex_stack.atlas = ui_icons
	_tex_stack.region = Rect2(160, 32, 16, 16)
	
	_tex_craft = AtlasTexture.new()
	_tex_craft.atlas = ui_icons
	_tex_craft.region = Rect2(48, 16, 16, 16)
	
	_tex_pickaxe = ItemDB.get_icon("pickaxe_copper")
	_tex_axe = ItemDB.get_icon("axe_copper")

func _create_icon_rect(tex: Texture2D) -> TextureRect:
	var ico = TextureRect.new()
	ico.custom_minimum_size = Vector2(16, 16)
	ico.texture = tex
	ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ico.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return ico

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F3 or event.keycode == KEY_QUOTELEFT or event.keycode == KEY_ASCIITILDE:
			toggle_panel()
			get_viewport().set_input_as_handled()
		elif visible and event.keycode == KEY_ESCAPE:
			hide()
			get_viewport().set_input_as_handled()

func toggle_panel() -> void:
	visible = not visible
	if visible:
		_refresh_active_tab()

func _build_ui() -> void:
	for child in get_children():
		child.queue_free()
		
	var fantasy_theme = preload("res://resources/themes/theme_cute_fantasy.tres")
	theme = fantasy_theme

	# Затемняющий фон
	var dim_bg = ColorRect.new()
	dim_bg.name = "DimBackground"
	dim_bg.anchors_preset = Control.PRESET_FULL_RECT
	dim_bg.anchor_right = 1.0
	dim_bg.anchor_bottom = 1.0
	dim_bg.color = Color(0, 0, 0, 0.45)
	dim_bg.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim_bg)
		
	# Главное окно PanelContainer (использует официальную подложку StyleBoxTexture_panel из theme_cute_fantasy.tres)
	main_panel = PanelContainer.new()
	main_panel.name = "MainPanel"
	main_panel.custom_minimum_size = Vector2(590, 324)
	main_panel.anchors_preset = Control.PRESET_CENTER
	main_panel.anchor_left = 0.5
	main_panel.anchor_top = 0.5
	main_panel.anchor_right = 0.5
	main_panel.anchor_bottom = 0.5
	main_panel.offset_left = -295.0
	main_panel.offset_top = -162.0
	main_panel.offset_right = 295.0
	main_panel.offset_bottom = 162.0
	main_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(main_panel)
	
	var root_vbox = VBoxContainer.new()
	root_vbox.add_theme_constant_override("separation", 5)
	main_panel.add_child(root_vbox)
	
	# 1. Заголовок и кнопка закрытия
	var header = HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 22)
	
	var title = Label.new()
	title.text = "Панель разработчика (F3 / ~)"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	header.add_child(title)
	
	var close_btn = Button.new()
	close_btn.text = " X "
	close_btn.pressed.connect(hide)
	header.add_child(close_btn)
	root_vbox.add_child(header)
	
	# 2. Навигационные вкладки
	tabs_container = HBoxContainer.new()
	tabs_container.add_theme_constant_override("separation", 4)
	
	var tab_names = ["Предметы", "Игрок и Читы", "Мир и Погода", "Мобы и Спавн"]
	for i in range(tab_names.size()):
		var t_btn = Button.new()
		t_btn.text = tab_names[i]
		t_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var idx = i
		t_btn.pressed.connect(func(): _switch_tab(idx))
		tabs_container.add_child(t_btn)
		
	root_vbox.add_child(tabs_container)
	
	# 3. Контейнер содержимого вкладок
	content_container = MarginContainer.new()
	content_container.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_container.add_theme_constant_override("margin_left", 4)
	content_container.add_theme_constant_override("margin_top", 4)
	content_container.add_theme_constant_override("margin_right", 4)
	content_container.add_theme_constant_override("margin_bottom", 4)
	root_vbox.add_child(content_container)
	
	# Создаем страницы вкладок
	_build_tab_items()
	_build_tab_player()
	_build_tab_world()
	_build_tab_mobs()
	
	_switch_tab(0)

func _switch_tab(idx: int) -> void:
	active_tab = idx
	tab_items.visible = (idx == 0)
	tab_player.visible = (idx == 1)
	tab_world.visible = (idx == 2)
	tab_mobs.visible = (idx == 3)
	
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as Button
		if i == idx:
			btn.modulate = Color(1.15, 1.10, 0.85)
		else:
			btn.modulate = Color.WHITE
			
	_refresh_active_tab()

func _refresh_active_tab() -> void:
	match active_tab:
		0:
			_populate_items()
		1:
			_update_player_tab_info()
		2:
			_update_world_tab_info()

# ═══════════════════════════════════════════════════════════════════════════════
# ВКЛАДКА 1: ПРЕДМЕТЫ
# ═══════════════════════════════════════════════════════════════════════════════

func _build_tab_items() -> void:
	tab_items = HBoxContainer.new()
	tab_items.add_theme_constant_override("separation", 8)
	content_container.add_child(tab_items)
	
	# Левая колонка: Поиск, Фильтры и Список предметов (ширина 310px)
	var left_col = VBoxContainer.new()
	left_col.custom_minimum_size = Vector2(310, 0)
	left_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	left_col.add_theme_constant_override("separation", 4)
	tab_items.add_child(left_col)
	
	# Поисковая строка
	var search_edit = LineEdit.new()
	search_edit.placeholder_text = "Поиск по названию или ID..."
	search_edit.clear_button_enabled = true
	var search_style = StyleBoxFlat.new()
	search_style.bg_color = Color(0.93, 0.89, 0.82, 0.95)
	search_style.border_width_left = 1
	search_style.border_width_top = 1
	search_style.border_width_right = 1
	search_style.border_width_bottom = 1
	search_style.border_color = Color(0.42, 0.30, 0.18)
	search_style.corner_radius_top_left = 4
	search_style.corner_radius_top_right = 4
	search_style.corner_radius_bottom_left = 4
	search_style.corner_radius_bottom_right = 4
	search_style.content_margin_left = 6
	search_style.content_margin_right = 6
	search_style.content_margin_top = 3
	search_style.content_margin_bottom = 3
	search_edit.add_theme_stylebox_override("normal", search_style)
	search_edit.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05))
	search_edit.add_theme_color_override("font_placeholder_color", Color(0.5, 0.42, 0.35))
	search_edit.text_changed.connect(func(new_text):
		search_filter = new_text.strip_edges().to_lower()
		_populate_items()
	)
	left_col.add_child(search_edit)
	
	# Фильтры категорий
	var cat_row = HBoxContainer.new()
	cat_row.add_theme_constant_override("separation", 2)
	var cats = [
		{"id": "ALL", "label": "Все"},
		{"id": "WEAPON", "label": "Оружие"},
		{"id": "TOOL", "label": "Инструменты"},
		{"id": "FOOD", "label": "Еда"},
		{"id": "RES", "label": "Ресурсы"},
		{"id": "BUILD", "label": "Стройка"}
	]
	for c in cats:
		var c_btn = Button.new()
		c_btn.text = c["label"]
		c_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var cid = c["id"]
		c_btn.pressed.connect(func():
			category_filter = cid
			for b in cat_row.get_children():
				b.modulate = Color(1.15, 1.10, 0.7) if b == c_btn else Color.WHITE
			_populate_items()
		)
		cat_row.add_child(c_btn)
	left_col.add_child(cat_row)
	
	# Список предметов
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	item_list_container = VBoxContainer.new()
	item_list_container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	item_list_container.add_theme_constant_override("separation", 2)
	scroll.add_child(item_list_container)
	left_col.add_child(scroll)
	
	# Правая колонка: Инспектор выбранного предмета (использует текстурную подложку слота/карточки из UI_Frames)
	var right_col = PanelContainer.new()
	right_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_col.size_flags_vertical = Control.SIZE_EXPAND_FILL
	
	var card_sb = StyleBoxTexture.new()
	card_sb.texture = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Frames.png")
	card_sb.region_rect = Rect2(1022, 158, 20, 20)
	card_sb.texture_margin_left = 6.0
	card_sb.texture_margin_top = 6.0
	card_sb.texture_margin_right = 6.0
	card_sb.texture_margin_bottom = 6.0
	right_col.add_theme_stylebox_override("panel", card_sb)
	tab_items.add_child(right_col)
	
	var r_margin = MarginContainer.new()
	r_margin.add_theme_constant_override("margin_left", 6)
	r_margin.add_theme_constant_override("margin_top", 6)
	r_margin.add_theme_constant_override("margin_right", 6)
	r_margin.add_theme_constant_override("margin_bottom", 6)
	right_col.add_child(r_margin)
	
	var r_vbox = VBoxContainer.new()
	r_vbox.add_theme_constant_override("separation", 5)
	r_margin.add_child(r_vbox)
	
	# Шапка карточки предмета (иконка + название + id)
	var card_top = HBoxContainer.new()
	card_top.add_theme_constant_override("separation", 8)
	
	preview_icon = TextureRect.new()
	preview_icon.custom_minimum_size = Vector2(36, 36)
	preview_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	preview_icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	card_top.add_child(preview_icon)
	
	var name_vbox = VBoxContainer.new()
	name_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_name = Label.new()
	preview_name.text = "Выберите предмет"
	preview_name.add_theme_color_override("font_color", Color(0.25, 0.12, 0.05))
	name_vbox.add_child(preview_name)
	
	preview_id = Label.new()
	preview_id.text = "ID: -"
	preview_id.add_theme_color_override("font_color", Color(0.45, 0.35, 0.25))
	name_vbox.add_child(preview_id)
	card_top.add_child(name_vbox)
	r_vbox.add_child(card_top)
	
	# Описание
	preview_desc = Label.new()
	preview_desc.text = "Нажмите на любой предмет из списка слева, чтобы посмотреть его характеристики."
	preview_desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	preview_desc.add_theme_color_override("font_color", Color(0.28, 0.2, 0.12))
	r_vbox.add_child(preview_desc)
	
	# Блок характеристик со скроллом
	var stats_scroll = ScrollContainer.new()
	stats_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stats_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	preview_stats = VBoxContainer.new()
	preview_stats.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	preview_stats.add_theme_constant_override("separation", 3)
	stats_scroll.add_child(preview_stats)
	r_vbox.add_child(stats_scroll)
	
	# Выбор количества
	var qty_row = HBoxContainer.new()
	qty_row.add_theme_constant_override("separation", 4)
	
	var qty_lbl = Label.new()
	qty_lbl.text = "Кол-во:"
	qty_lbl.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	qty_row.add_child(qty_lbl)
	
	qty_spinbox = SpinBox.new()
	qty_spinbox.min_value = 1
	qty_spinbox.max_value = 999
	qty_spinbox.value = give_quantity
	qty_spinbox.value_changed.connect(func(v): give_quantity = int(v))
	qty_row.add_child(qty_spinbox)
	
	var q_presets = [1, 10, 64]
	for q in q_presets:
		var qb = Button.new()
		qb.text = str(q)
		var val = q
		qb.pressed.connect(func():
			qty_spinbox.value = val
			give_quantity = val
		)
		qty_row.add_child(qb)
	r_vbox.add_child(qty_row)
	
	# Кнопка выдачи
	give_btn = Button.new()
	give_btn.text = "Выдать в инвентарь"
	give_btn.custom_minimum_size = Vector2(0, 26)
	give_btn.pressed.connect(_on_give_item_pressed)
	r_vbox.add_child(give_btn)
	
	toast_label = Label.new()
	toast_label.text = ""
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color", Color(0.1, 0.5, 0.15))
	r_vbox.add_child(toast_label)

func _populate_items() -> void:
	if not item_list_container:
		return
		
	for child in item_list_container.get_children():
		child.queue_free()
		
	var items = ItemDB.ITEMS
	var first_matching = ""
	
	for item_id in items.keys():
		var data = items[item_id]
		var item_name = data.get("name", item_id)
		
		# Фильтр по поисковой строке
		if search_filter != "":
			var matches_id = item_id.to_lower().find(search_filter) != -1
			var matches_name = item_name.to_lower().find(search_filter) != -1
			if not matches_id and not matches_name:
				continue
				
		# Фильтр по категориям
		if category_filter != "ALL":
			var cat = _get_item_category(item_id, data)
			if cat != category_filter:
				continue
				
		if first_matching == "":
			first_matching = item_id
			
		var row_btn = Button.new()
		row_btn.custom_minimum_size = Vector2(0, 24)
		row_btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
		row_btn.icon = ItemDB.get_icon(item_id)
		row_btn.text = " " + item_name
		
		var id_copy = item_id
		row_btn.pressed.connect(func(): _select_item(id_copy))
		item_list_container.add_child(row_btn)
		
	if selected_item_id == "" or not items.has(selected_item_id):
		if first_matching != "":
			_select_item(first_matching)
	else:
		_select_item(selected_item_id)

func _get_item_category(item_id: String, data: Dictionary) -> String:
	if "sword" in item_id or "bow" in item_id or "arrow" in item_id or data.has("damage"):
		return "WEAPON"
	if "axe" in item_id or "pickaxe" in item_id or data.has("tool_type"):
		return "TOOL"
	if data.has("hunger_restore") or data.has("health_restore"):
		return "FOOD"
	if item_id in ["tent", "campfire", "storage_box", "orange_bed"]:
		return "BUILD"
	return "RES"

func _select_item(item_id: String) -> void:
	selected_item_id = item_id
	if not ItemDB.ITEMS.has(item_id):
		return
		
	var data = ItemDB.ITEMS[item_id]
	preview_icon.texture = ItemDB.get_icon(item_id)
	preview_name.text = data.get("name", item_id)
	preview_id.text = "ID: " + item_id
	preview_desc.text = data.get("desc", "Описание отсутствует.")
	
	# Очищаем старые характеристики
	for child in preview_stats.get_children():
		child.queue_free()
		
	# Формируем характеристики с существующими иконками игры
	_add_stat_row(_tex_stack, "Макс. стак:", str(data.get("max_stack", 99)))
	
	if data.has("damage"):
		_add_stat_row(_tex_sword, "Урон:", str(data["damage"]))
	if data.has("knockback"):
		_add_stat_row(_tex_shield, "Отбрасывание:", str(data["knockback"]))
	if data.has("hunger_restore"):
		_add_stat_row(_tex_hunger, "Сытость:", "+%d" % int(data["hunger_restore"]))
	if data.has("health_restore"):
		_add_stat_row(_tex_health, "Лечение:", "+%d HP" % int(data["health_restore"]))
	if data.has("stamina_restore"):
		_add_stat_row(_tex_stamina, "Выносливость:", "+%d" % int(data["stamina_restore"]))
	if data.has("mining_power"):
		_add_stat_row(_tex_pickaxe, "Сила добычи:", str(data["mining_power"]))
	if data.has("chop_power"):
		_add_stat_row(_tex_axe, "Сила рубки:", str(data["chop_power"]))
		
	if ItemDB.RECIPES.has(item_id):
		var r = ItemDB.RECIPES[item_id]
		var parts = []
		for mat in r.keys():
			var mat_name = ItemDB.ITEMS.get(mat, {}).get("name", mat)
			parts.append("%s: %d" % [mat_name, r[mat]])
		_add_stat_row(_tex_craft, "Рецепт:", ", ".join(parts))

func _add_stat_row(icon_tex: Texture2D, stat_label: String, val: String) -> void:
	var h = HBoxContainer.new()
	h.add_theme_constant_override("separation", 6)
	
	if icon_tex:
		var ico = TextureRect.new()
		ico.custom_minimum_size = Vector2(14, 14)
		ico.texture = icon_tex
		ico.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		ico.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ico.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		h.add_child(ico)
	
	var l1 = Label.new()
	l1.text = stat_label
	l1.add_theme_color_override("font_color", Color(0.35, 0.25, 0.15))
	h.add_child(l1)
	
	var l2 = Label.new()
	l2.text = " " + val
	l2.add_theme_color_override("font_color", Color(0.18, 0.10, 0.04))
	h.add_child(l2)
	preview_stats.add_child(h)

func _on_give_item_pressed() -> void:
	if selected_item_id == "":
		return
	InventoryManager.add_item(selected_item_id, give_quantity)
	var item_name = ItemDB.ITEMS.get(selected_item_id, {}).get("name", selected_item_id)
	toast_label.text = "Выдано: +%d %s" % [give_quantity, item_name]
	
	var tw = create_tween()
	tw.tween_interval(1.8)
	tw.tween_property(toast_label, "text", "", 0.3)

# ═══════════════════════════════════════════════════════════════════════════════
# ВКЛАДКА 2: ИГРОК И ЧИТЫ
# ═══════════════════════════════════════════════════════════════════════════════

func _build_tab_player() -> void:
	tab_player = VBoxContainer.new()
	tab_player.add_theme_constant_override("separation", 8)
	content_container.add_child(tab_player)
	
	# Блок Режима Бога
	god_mode_btn = Button.new()
	god_mode_btn.custom_minimum_size = Vector2(0, 32)
	god_mode_btn.text = "Режим Бога: ВЫКЛ"
	god_mode_btn.pressed.connect(_toggle_god_mode)
	tab_player.add_child(god_mode_btn)
	
	# Сетка управления характеристиками
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 8)
	tab_player.add_child(grid)
	
	# 1. ЗДОРОВЬЕ
	var hp_box = VBoxContainer.new()
	var hp_header = HBoxContainer.new()
	hp_header.add_theme_constant_override("separation", 6)
	var hp_ico = _create_icon_rect(_tex_health)
	hp_header.add_child(hp_ico)
	hp_label = Label.new()
	hp_label.text = "Здоровье: 100 / 100"
	hp_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	hp_header.add_child(hp_label)
	hp_box.add_child(hp_header)
	
	var hp_btns = HBoxContainer.new()
	var heal_btn = Button.new(); heal_btn.text = "100% HP"; heal_btn.pressed.connect(func(): GameStateManager.heal(100))
	var dmg_btn = Button.new(); dmg_btn.text = "-25 HP"; dmg_btn.pressed.connect(func(): GameStateManager.take_damage(25))
	var low_btn = Button.new(); low_btn.text = "1 HP"; low_btn.pressed.connect(func():
		GameStateManager.current_health = 1.0
		GameStateManager.health_changed.emit(1.0, GameStateManager.max_health)
	)
	var die_btn = Button.new(); die_btn.text = "Убить игрока"; die_btn.pressed.connect(func(): GameStateManager.take_damage(999))
	hp_btns.add_child(heal_btn); hp_btns.add_child(dmg_btn); hp_btns.add_child(low_btn); hp_btns.add_child(die_btn)
	hp_box.add_child(hp_btns)
	grid.add_child(hp_box)
	
	# 2. ВЫНОСЛИВОСТЬ
	var sta_box = VBoxContainer.new()
	var sta_header = HBoxContainer.new()
	sta_header.add_theme_constant_override("separation", 6)
	var sta_ico = _create_icon_rect(_tex_stamina)
	sta_header.add_child(sta_ico)
	stamina_label = Label.new()
	stamina_label.text = "Выносливость: 100 / 100"
	stamina_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	sta_header.add_child(stamina_label)
	sta_box.add_child(sta_header)
	
	var sta_btns = HBoxContainer.new()
	var full_sta_btn = Button.new(); full_sta_btn.text = "Восстановить (100%)"; full_sta_btn.pressed.connect(func(): GameStateManager.add_stamina(100))
	var empty_sta_btn = Button.new(); empty_sta_btn.text = "Сбросить в 0"; empty_sta_btn.pressed.connect(func():
		GameStateManager.current_stamina = 0.0
		GameStateManager.is_exhausted = true
		GameStateManager.stamina_changed.emit(0.0, GameStateManager.max_stamina)
	)
	sta_btns.add_child(full_sta_btn); sta_btns.add_child(empty_sta_btn)
	sta_box.add_child(sta_btns)
	grid.add_child(sta_box)
	
	# 3. СЫТОСТЬ (ГОЛОД)
	var hg_box = VBoxContainer.new()
	var hg_header = HBoxContainer.new()
	hg_header.add_theme_constant_override("separation", 6)
	var hg_ico = _create_icon_rect(_tex_hunger)
	hg_header.add_child(hg_ico)
	hunger_label = Label.new()
	hunger_label.text = "Сытость: 100%"
	hunger_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	hg_header.add_child(hunger_label)
	hg_box.add_child(hg_header)
	
	var hg_btns = HBoxContainer.new()
	var full_hg_btn = Button.new(); full_hg_btn.text = "Насытить (100%)"; full_hg_btn.pressed.connect(func(): GameStateManager.add_hunger(100))
	var starve_btn = Button.new(); starve_btn.text = "Голод (10%)"; starve_btn.pressed.connect(func():
		GameStateManager.current_hunger = 10.0
		GameStateManager.hunger_changed.emit(10.0, GameStateManager.max_hunger)
	)
	hg_btns.add_child(full_hg_btn); hg_btns.add_child(starve_btn)
	hg_box.add_child(hg_btns)
	grid.add_child(hg_box)
	
	# 4. ТЕСТИРОВАНИЕ СТАТУСОВ
	var st_box = VBoxContainer.new()
	var st_lbl = Label.new()
	st_lbl.text = "Эффекты и статусы игрока:"
	st_lbl.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	st_box.add_child(st_lbl)
	
	var st_btns = HBoxContainer.new()
	var burn_btn = Button.new(); burn_btn.text = "Горение"; burn_btn.pressed.connect(_apply_player_burn)
	var wet_btn = Button.new(); wet_btn.text = "Намокание"; wet_btn.pressed.connect(_apply_player_wet)
	var shock_btn = Button.new(); shock_btn.text = "Шок (паралич)"; shock_btn.pressed.connect(_apply_player_paralysis)
	var clear_btn = Button.new(); clear_btn.text = "Снять все статусы"; clear_btn.pressed.connect(_clear_player_statuses)
	st_btns.add_child(burn_btn); st_btns.add_child(wet_btn); st_btns.add_child(shock_btn); st_btns.add_child(clear_btn)
	st_box.add_child(st_btns)
	grid.add_child(st_box)

func _toggle_god_mode() -> void:
	GameStateManager.is_god_mode = not GameStateManager.is_god_mode
	_update_player_tab_info()

func _update_player_tab_info() -> void:
	if not god_mode_btn: return
	if GameStateManager.is_god_mode:
		god_mode_btn.text = "Режим Бога: ВКЛ (Бессмертие, бесконечная выносливость и сытость)"
		god_mode_btn.modulate = Color(0.8, 1.3, 0.8)
	else:
		god_mode_btn.text = "Режим Бога: ВЫКЛ (Нажмите для включения)"
		god_mode_btn.modulate = Color.WHITE
		
	hp_label.text = "Здоровье: %d / %d" % [int(GameStateManager.current_health), int(GameStateManager.max_health)]
	stamina_label.text = "Выносливость: %d / %d" % [int(GameStateManager.current_stamina), int(GameStateManager.max_stamina)]
	hunger_label.text = "Сытость: %d%%" % int(GameStateManager.current_hunger)

func _apply_player_burn() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("apply_burn"):
		p.apply_burn(6.0)

func _apply_player_wet() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p:
		p.set("is_wet", true)
		p.set("wet_timer", 8.0)

func _apply_player_paralysis() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p and p.has_method("apply_paralysis"):
		p.apply_paralysis(3.0)

func _clear_player_statuses() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if p:
		if p.has_method("extinguish_burn"):
			p.extinguish_burn()
		p.set("is_wet", false)
		p.set("wet_timer", 0.0)
		p.set("is_paralyzed", false)
		p.set("paralysis_timer", 0.0)
		var pfx = p.get_node_or_null("ParalysisEffect")
		if pfx: pfx.queue_free()
		var bfx = p.get_node_or_null("BurnEffect")
		if bfx: bfx.queue_free()

# ═══════════════════════════════════════════════════════════════════════════════
# ВКЛАДКА 3: МИР И ПОГОДА
# ═══════════════════════════════════════════════════════════════════════════════

func _build_tab_world() -> void:
	tab_world = VBoxContainer.new()
	tab_world.add_theme_constant_override("separation", 8)
	content_container.add_child(tab_world)
	
	# Инфо-строка
	time_info_label = Label.new()
	time_info_label.text = "Время: -"
	time_info_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	tab_world.add_child(time_info_label)
	
	# Смена времени суток
	var time_row = HBoxContainer.new()
	time_row.add_theme_constant_override("separation", 4)
	
	var times = [
		{"label": "Утро (06:00)", "hour": 6.0},
		{"label": "День (12:00)", "hour": 12.0},
		{"label": "Вечер (18:00)", "hour": 18.0},
		{"label": "Ночь (00:00)", "hour": 0.0}
	]
	for t in times:
		var btn = Button.new()
		btn.text = t["label"]
		btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var h = t["hour"]
		btn.pressed.connect(func():
			GameStateManager.set_time_hour(h)
			_update_world_tab_info()
		)
		time_row.add_child(btn)
	tab_world.add_child(time_row)
	
	# Шаги времени и скорость
	var step_row = HBoxContainer.new()
	step_row.add_theme_constant_override("separation", 4)
	
	var h1_btn = Button.new(); h1_btn.text = "+1 Час"; h1_btn.pressed.connect(func(): GameStateManager.set_time_hour(GameStateManager.current_hour + 1.0); _update_world_tab_info())
	var h6_btn = Button.new(); h6_btn.text = "+6 Часов"; h6_btn.pressed.connect(func(): GameStateManager.set_time_hour(GameStateManager.current_hour + 6.0); _update_world_tab_info())
	var day_btn = Button.new(); day_btn.text = "След. день"; day_btn.pressed.connect(func(): GameStateManager.advance_day(); _update_world_tab_info())
	
	step_row.add_child(h1_btn); step_row.add_child(h6_btn); step_row.add_child(day_btn)
	
	var sp_lbl = Label.new()
	sp_lbl.text = "  Скорость:"
	sp_lbl.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	step_row.add_child(sp_lbl)
	
	var speeds = [
		{"lbl": "Пауза", "val": 0.0},
		{"lbl": "1x", "val": 1.0},
		{"lbl": "5x", "val": 5.0},
		{"lbl": "20x", "val": 20.0}
	]
	for s in speeds:
		var sb = Button.new()
		sb.text = s["lbl"]
		var v = s["val"]
		sb.pressed.connect(func():
			GameStateManager.time_speed = v
			_update_world_tab_info()
		)
		step_row.add_child(sb)
	tab_world.add_child(step_row)
	
	# Погода
	var sep = HSeparator.new()
	tab_world.add_child(sep)
	
	weather_info_label = Label.new()
	weather_info_label.text = "Погода: -"
	weather_info_label.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	tab_world.add_child(weather_info_label)
	
	var w_row1 = HBoxContainer.new()
	w_row1.add_theme_constant_override("separation", 4)
	
	var weathers1 = [
		{"w": WeatherManager.Weather.CLEAR, "txt": "Ясно"},
		{"w": WeatherManager.Weather.CLOUDY, "txt": "Облачно"},
		{"w": WeatherManager.Weather.FOG, "txt": "Туман"},
		{"w": WeatherManager.Weather.OVERCAST, "txt": "Пасмурно"}
	]
	for w in weathers1:
		var wb = Button.new()
		wb.text = w["txt"]
		wb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var w_id = w["w"]
		wb.pressed.connect(func():
			WeatherManager.set_weather(w_id)
			_update_world_tab_info()
		)
		w_row1.add_child(wb)
	tab_world.add_child(w_row1)
	
	var w_row2 = HBoxContainer.new()
	w_row2.add_theme_constant_override("separation", 4)
	
	var weathers2 = [
		{"w": WeatherManager.Weather.RAIN, "txt": "Дождь"},
		{"w": WeatherManager.Weather.THUNDERSTORM, "txt": "Гроза"},
		{"w": WeatherManager.Weather.TWILIGHT_STORM, "txt": "Сумеречный шторм"}
	]
	for w in weathers2:
		var wb = Button.new()
		wb.text = w["txt"]
		wb.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var w_id = w["w"]
		wb.pressed.connect(func():
			WeatherManager.set_weather(w_id)
			_update_world_tab_info()
		)
		w_row2.add_child(wb)
		
	# Кнопка принудительного удара молнии
	var strike_btn = Button.new()
	strike_btn.text = "Удар молнии в игрока"
	strike_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strike_btn.pressed.connect(_trigger_player_lightning_strike)
	w_row2.add_child(strike_btn)
	tab_world.add_child(w_row2)
	
	# Строка тестирования Экспедиции и мыслей персонажа
	var w_row3 = HBoxContainer.new()
	w_row3.add_theme_constant_override("separation", 4)
	
	var storm_test_btn = Button.new()
	storm_test_btn.text = "Шторм экспедиции (+6 мин)"
	storm_test_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	storm_test_btn.pressed.connect(func():
		if ExpeditionManager:
			ExpeditionManager.is_in_raid = true
			ExpeditionManager.raid_duration = ExpeditionManager.storm_start_time
			ExpeditionManager.post_thought("Буря началась! (Через дебаг-панель)", ExpeditionManager.COLOR_DANGER)
	)
	w_row3.add_child(storm_test_btn)
	
	var thought_test_btn = Button.new()
	thought_test_btn.text = "Тест мысли"
	thought_test_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	thought_test_btn.pressed.connect(func():
		if ExpeditionManager:
			ExpeditionManager.post_thought("Кажется, начинается буря... Воздух тяжелеет.", ExpeditionManager.COLOR_WARNING)
	)
	w_row3.add_child(thought_test_btn)
	tab_world.add_child(w_row3)

func _update_world_tab_info() -> void:
	if not time_info_label: return
	var day_name = GameStateManager.get_day_of_week()
	var time_str = GameStateManager.get_formatted_time()
	time_info_label.text = "День %d (%s)  |  Время: %s  |  Скорость: %.1fx" % [
		GameStateManager.current_day, day_name, time_str, GameStateManager.time_speed
	]
	if WeatherManager:
		weather_info_label.text = "Текущая погода: %s" % WeatherManager.get_weather_name()

func _trigger_player_lightning_strike() -> void:
	var p = get_tree().get_first_node_in_group("player")
	if not p: return
	var strike = LightningStrike.new()
	strike.global_position = p.global_position
	if WeatherManager and WeatherManager.current_weather == WeatherManager.Weather.TWILIGHT_STORM:
		strike.is_twilight = true
	get_tree().current_scene.add_child(strike)

# ═══════════════════════════════════════════════════════════════════════════════
# ВКЛАДКА 4: МОБЫ И СПАВН
# ═══════════════════════════════════════════════════════════════════════════════

func _build_tab_mobs() -> void:
	tab_mobs = VBoxContainer.new()
	tab_mobs.add_theme_constant_override("separation", 8)
	content_container.add_child(tab_mobs)
	
	# Количество для спавна
	var count_row = HBoxContainer.new()
	count_row.add_theme_constant_override("separation", 4)
	
	var c_lbl = Label.new()
	c_lbl.text = "Количество для спавна:"
	c_lbl.add_theme_color_override("font_color", Color(0.25, 0.15, 0.05))
	count_row.add_child(c_lbl)
	
	var counts = [1, 3, 5, 10]
	for c in counts:
		var cb = Button.new()
		cb.text = "%d шт" % c
		var val = c
		cb.pressed.connect(func():
			spawn_count = val
			for b in count_row.get_children():
				if b is Button:
					b.modulate = Color(1.15, 1.10, 0.7) if b == cb else Color.WHITE
		)
		count_row.add_child(cb)
	tab_mobs.add_child(count_row)
	
	# Сетка кнопок спавна
	var spawn_grid = GridContainer.new()
	spawn_grid.columns = 3
	spawn_grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	spawn_grid.add_theme_constant_override("h_separation", 6)
	spawn_grid.add_theme_constant_override("v_separation", 6)
	tab_mobs.add_child(spawn_grid)
	
	# Слаймы
	var sl_g_s = Button.new(); sl_g_s.text = "Маленький Слайм (Зел)"; sl_g_s.pressed.connect(func(): _spawn_slime(SlimeEnemy.SlimeSize.SMALL, SlimeEnemy.SlimeColor.GREEN))
	var sl_b_s = Button.new(); sl_b_s.text = "Маленький Слайм (Син)"; sl_b_s.pressed.connect(func(): _spawn_slime(SlimeEnemy.SlimeSize.SMALL, SlimeEnemy.SlimeColor.BLUE))
	var sl_r_s = Button.new(); sl_r_s.text = "Маленький Слайм (Крас)"; sl_r_s.pressed.connect(func(): _spawn_slime(SlimeEnemy.SlimeSize.SMALL, SlimeEnemy.SlimeColor.RED))
	var sl_m = Button.new(); sl_m.text = "Средний Слайм"; sl_m.pressed.connect(func(): _spawn_slime(SlimeEnemy.SlimeSize.MEDIUM, SlimeEnemy.SlimeColor.GREEN))
	var sl_b = Button.new(); sl_b.text = "Большой Слайм"; sl_b.pressed.connect(func(): _spawn_slime(SlimeEnemy.SlimeSize.BIG, SlimeEnemy.SlimeColor.GREEN))
	
	# Скелет и Курица
	var skel_btn = Button.new(); skel_btn.text = "Скелет с мечом"; skel_btn.pressed.connect(_spawn_skeleton)
	var chick_btn = Button.new(); chick_btn.text = "Курица"; chick_btn.pressed.connect(_spawn_chicken)
	
	spawn_grid.add_child(sl_g_s); spawn_grid.add_child(sl_b_s); spawn_grid.add_child(sl_r_s)
	spawn_grid.add_child(sl_m); spawn_grid.add_child(sl_b); spawn_grid.add_child(skel_btn)
	spawn_grid.add_child(chick_btn)
	
	# Массовые действия
	var act_sep = HSeparator.new()
	tab_mobs.add_child(act_sep)
	
	var act_row = HBoxContainer.new()
	act_row.add_theme_constant_override("separation", 8)
	
	var kill_all_btn = Button.new()
	kill_all_btn.text = "Убить всех врагов"
	kill_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	kill_all_btn.pressed.connect(_kill_all_enemies)
	act_row.add_child(kill_all_btn)
	
	var clear_all_btn = Button.new()
	clear_all_btn.text = "Очистить всех мобов"
	clear_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	clear_all_btn.pressed.connect(_despawn_all_mobs)
	act_row.add_child(clear_all_btn)
	
	var strike_all_btn = Button.new()
	strike_all_btn.text = "Молнии по всем врагам"
	strike_all_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	strike_all_btn.pressed.connect(_lightning_strike_all_enemies)
	act_row.add_child(strike_all_btn)
	
	tab_mobs.add_child(act_row)

func _get_spawn_position() -> Vector2:
	var p = get_tree().get_first_node_in_group("player")
	if p:
		var angle = randf() * TAU
		var dist = randf_range(45.0, 90.0)
		return p.global_position + Vector2(cos(angle), sin(angle)) * dist
	return Vector2(100, 100)

func _spawn_slime(size: int, color: int) -> void:
	var scene = load("res://scenes/characters/slime.tscn")
	if not scene: return
	for _i in range(spawn_count):
		var inst = scene.instantiate() as SlimeEnemy
		inst.global_position = _get_spawn_position()
		get_tree().current_scene.add_child(inst)
		inst.setup_slime(size as SlimeEnemy.SlimeSize, color as SlimeEnemy.SlimeColor)

func _spawn_skeleton() -> void:
	var scene = load("res://scenes/characters/skeleton.tscn")
	if not scene: return
	for _i in range(spawn_count):
		var inst = scene.instantiate()
		inst.global_position = _get_spawn_position()
		get_tree().current_scene.add_child(inst)

func _spawn_chicken() -> void:
	var scene = load("res://scenes/characters/chicken.tscn")
	if not scene: return
	for _i in range(spawn_count):
		var inst = scene.instantiate()
		inst.global_position = _get_spawn_position()
		get_tree().current_scene.add_child(inst)

func _kill_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			if e.has_method("take_damage"):
				e.take_damage(9999)

func _despawn_all_mobs() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e):
			e.queue_free()
	var chickens = get_tree().get_nodes_in_group("chickens")
	for c in chickens:
		if is_instance_valid(c):
			c.queue_free()

func _lightning_strike_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if is_instance_valid(e) and not e.get("is_dead"):
			var strike = LightningStrike.new()
			strike.global_position = e.global_position
			get_tree().current_scene.add_child(strike)
