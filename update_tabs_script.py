import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Add the new export variables
exports = """@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture
@export var bookmark_active_tex: AtlasTexture
@export var bookmark_inactive_tex: AtlasTexture"""
content = content.replace('@export var closed_book_tex: AtlasTexture\n@export var open_book_tex: AtlasTexture', exports)

# Add texture swap logic to _switch_tab
old_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	if index == 0:"""

new_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as TextureButton
		if btn:
			btn.texture_normal = bookmark_active_tex if i == index else bookmark_inactive_tex
		
	if index == 0:"""
content = content.replace(old_switch, new_switch)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
