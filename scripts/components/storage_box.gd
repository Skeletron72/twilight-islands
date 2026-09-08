extends StaticBody2D
class_name StorageBox

var inventory: Dictionary = {}
var is_broken: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var sfx: AudioStreamPlayer2D = get_node_or_null("AudioStreamPlayer2D")

func _ready() -> void:
	if sprite:
		sprite.frame = 0

func interact(player: Node2D) -> void:
	if is_broken: return
	
	# Проверяем, хочет ли игрок сломать ящик (выбран топор в хотбаре или зажат Shift/Ctrl)
	if _should_break_crate():
		break_crate()
		return
		
	# Обычное открытие инвентаря ящика
	var storage_ui = get_tree().current_scene.get_node_or_null("UILayer/StorageUI")
	if storage_ui:
		GameStateManager.register_chest_opened()
		storage_ui.open(self)
	else:
		print("Storage UI not found!")

func close_chest() -> void:
	# Анимации открытия/закрытия больше нет — ящик остаётся на статичном 0 кадре
	if sprite and not is_broken:
		sprite.frame = 0

func _should_break_crate() -> bool:
	# 1. Зажата клавиша Shift или Ctrl при взаимодействии
	if Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_CTRL):
		return true
		
	# 2. В активном слоте хотбара выбран топор или кирка
	var hotbar = get_tree().current_scene.get_node_or_null("UILayer/HotbarUI")
	if hotbar and "active_slot_index" in hotbar and hotbar.active_slot_index != -1:
		var slot_id = InventoryManager.ui_slots[hotbar.active_slot_index]
		if slot_id in ["wooden_axe", "stone_axe", "wooden_pickaxe", "stone_pickaxe"]:
			return true
			
	return false

func break_crate() -> void:
	if is_broken: return
	is_broken = true
	
	# Если окно сундука было открыто — закрываем его
	var storage_ui = get_tree().current_scene.get_node_or_null("UILayer/StorageUI")
	if storage_ui and storage_ui.visible and storage_ui.get("current_chest") == self:
		storage_ui.close()
		
	# Отключаем коллизию, чтобы сквозь обломки сразу можно было пройти
	var col = get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", true)
		
	# Звук раскалывания дерева
	if sfx:
		sfx.stream = load("res://assets/audio/sfx/tools/sfx_wood_break.mp3")
		sfx.pitch_scale = randf_range(0.95, 1.1)
		sfx.play()
		
	# Высыпаем всё содержимое ящика на землю
	_drop_contents()
	
	# Проигрывание анимации разрушения по кадрам (1 -> 2 -> 3 -> 4 -> 5 -> исчезновение)
	_play_break_animation()

func _drop_contents() -> void:
	var dropped_scene = preload("res://scenes/objects/dropped_item.tscn")
	
	# Дроп хранившихся предметов
	for item_id in inventory.keys():
		var amt = inventory[item_id]
		if amt > 0:
			var drop = dropped_scene.instantiate()
			drop.global_position = global_position + Vector2(randf_range(-12, 12), randf_range(-6, 6))
			drop.setup(item_id, amt)
			get_tree().current_scene.add_child(drop)
			
	inventory.clear()
	
	# Дроп самого ящика в инвентарь или древесины
	var crate_drop = dropped_scene.instantiate()
	crate_drop.global_position = global_position + Vector2(0, 4)
	crate_drop.setup("storage_box", 1)
	get_tree().current_scene.add_child(crate_drop)

func _play_break_animation() -> void:
	if not sprite:
		queue_free()
		return
		
	# Покадровое переключение анимации (от кадра 1 до кадра 5)
	var tween = create_tween()
	for f in range(1, 6):
		tween.tween_callback(func():
			if sprite and is_instance_valid(sprite):
				sprite.frame = f
		)
		tween.tween_interval(0.08) # 80 мс на кадр — сочная, приятная скорость разлёта досок
		
	# Задержка на последнем кадре (осевшие щепки) и плавное удаление
	tween.tween_interval(0.12)
	tween.tween_callback(queue_free)
