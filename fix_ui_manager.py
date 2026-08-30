import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Replace variables
content = content.replace('@onready var book_btn: Button = $BookButton', '@onready var book_btn: TextureButton = $BookToggleContainer/BookToggleBtn\n@onready var book_key_lbl: Label = $BookToggleContainer/KeyLabel')

# Define textures
tex_setup = """var ui_tex = preload("res://resources/items/UI.png")
var tex_closed: AtlasTexture
var tex_closed_hover: AtlasTexture
var tex_open: AtlasTexture
var tex_open_hover: AtlasTexture

func _init_book_textures() -> void:
	tex_closed = AtlasTexture.new()
	tex_closed.atlas = ui_tex
	tex_closed.region = Rect2(928, 256, 16, 16)
	
	tex_closed_hover = AtlasTexture.new()
	tex_closed_hover.atlas = ui_tex
	tex_closed_hover.region = Rect2(992, 256, 16, 16)
	
	tex_open = AtlasTexture.new()
	tex_open.atlas = ui_tex
	tex_open.region = Rect2(944, 256, 16, 16)
	
	tex_open_hover = AtlasTexture.new()
	tex_open_hover.atlas = ui_tex
	tex_open_hover.region = Rect2(1008, 256, 16, 16)

func _update_book_btn_textures() -> void:
	if not book_btn: return
	if book_ui.visible:
		book_btn.texture_normal = tex_open
		book_btn.texture_hover = tex_open_hover
	else:
		book_btn.texture_normal = tex_closed
		book_btn.texture_hover = tex_closed_hover
"""

# Inject into ready
# Replace the old book_btn logic
old_btn_logic = """	if book_btn:
		book_btn.pressed.connect(func():
			if book_ui.visible:
				book_ui.close()
			else:
				book_ui.open()
		)"""

new_btn_logic = """	_init_book_textures()
	_update_book_btn_textures()
	book_ui.visibility_changed.connect(_update_book_btn_textures)
	
	if book_btn:
		book_btn.pressed.connect(func():
			if book_ui.visible:
				book_ui.close()
			else:
				book_ui.open()
		)
		
	if book_key_lbl:
		var events = InputMap.action_get_events("inventory")
		if events.size() > 0:
			var event = events[0]
			if event is InputEventKey:
				var key_name = OS.get_keycode_string(event.physical_keycode)
				if key_name == "": key_name = OS.get_keycode_string(event.keycode)
				book_key_lbl.text = "[" + key_name + "]"
			else:
				book_key_lbl.text = "[Tab]"
		else:
			book_key_lbl.text = "[Tab]"
"""

content = content.replace(old_btn_logic, new_btn_logic)
content = content + '\n\n' + tex_setup

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
