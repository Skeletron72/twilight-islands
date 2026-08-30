import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# I need to fix @onready var tabs_container: VBoxContainer to HBoxContainer in the script!
content = content.replace('@onready var tabs_container: VBoxContainer', '@onready var tabs_container: HBoxContainer')

old_anim = """var is_animating: bool = false

func open() -> void:
	if is_animating: return
	is_animating = true
	show()
	get_tree().paused = true
	
	# Скрываем содержимое книги на время анимации
	pages_container.hide()
	tabs_container.hide()
	
	book_panel.texture = closed_book_tex
	book_panel.pivot_offset = book_panel.size / 2.0
	book_panel.scale = Vector2(1, 1)
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	# Эффект открытия (сжимаем закрытую книгу по X)
	tween.tween_property(book_panel, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		book_panel.texture = open_book_tex
	)
	# Растягиваем уже открытую книгу
	tween.tween_property(book_panel, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		pages_container.show()
		tabs_container.show()
		is_animating = false
		if pages_container.get_child(0).visible:
			_refresh_inventory()
	)

func close() -> void:
	if is_animating: return
	is_animating = true
	
	pages_container.hide()
	tabs_container.hide()
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(book_panel, "scale:x", 0.0, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		book_panel.texture = closed_book_tex
	)
	tween.tween_property(book_panel, "scale:x", 1.0, 0.15).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(func():
		hide()
		get_tree().paused = false
		is_animating = false
	)"""

new_anim = """var is_animating: bool = false

func open() -> void:
	if is_animating: return
	is_animating = true
	show()
	get_tree().paused = true
	
	pages_container.hide()
	tabs_container.hide()
	book_panel.texture = closed_book_tex
	
	# Просто ждем небольшую паузу (имитация смены кадра)
	var timer = get_tree().create_timer(0.15)
	timer.pause_mode = Node.PAUSE_MODE_PROCESS if Engine.get_version_info().major < 4 else Node.PROCESS_MODE_ALWAYS
	
	await get_tree().create_timer(0.15).timeout
	
	book_panel.texture = open_book_tex
	pages_container.show()
	tabs_container.show()
	is_animating = false
	if pages_container.get_child(0).visible:
		_refresh_inventory()

func close() -> void:
	if is_animating: return
	is_animating = true
	
	pages_container.hide()
	tabs_container.hide()
	book_panel.texture = closed_book_tex
	
	await get_tree().create_timer(0.15).timeout
	
	hide()
	get_tree().paused = false
	is_animating = false"""

content = content.replace(old_anim, new_anim)

# I need to fix the path from HBoxContainer to MainVBox in @onready too!
content = content.replace('DimBackground/CenterContainer/HBoxContainer', 'DimBackground/CenterContainer/MainVBox')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
