import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Add export variables for the textures so the user can easily assign them in the inspector
exports = """@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture

@onready var book_panel: TextureRect = $DimBackground/CenterContainer/HBoxContainer/BookPanel
@onready var tabs_container: VBoxContainer = $DimBackground/CenterContainer/HBoxContainer/Tabs
"""

content = content.replace('@onready var btn_inv: Button = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnInv', exports + '@onready var btn_inv: TextureButton = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnInv')
content = content.replace('@onready var btn_char: Button = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnChar', '@onready var btn_char: TextureButton = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnChar')
content = content.replace('@onready var btn_craft: Button = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnCraft', '@onready var btn_craft: TextureButton = $DimBackground/CenterContainer/HBoxContainer/Tabs/BtnCraft')

# Animation logic
old_open = """func open() -> void:
	show()
	get_tree().paused = true
	# Trigger refresh for inventory
	if pages_container.get_child(0).visible:
		_refresh_inventory()

func close() -> void:
	hide()
	get_tree().paused = false"""

new_open = """var is_animating: bool = false

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

content = content.replace(old_open, new_open)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
