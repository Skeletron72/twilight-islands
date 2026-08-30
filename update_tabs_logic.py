import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# I need to add exports for all the new icons
exports = """@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture

@export var bookmark_active_tex: AtlasTexture
@export var bookmark_inactive_tex: AtlasTexture

@export var icon_inv_active: AtlasTexture
@export var icon_inv_inactive: AtlasTexture
@export var icon_char_active: AtlasTexture
@export var icon_char_inactive: AtlasTexture
@export var icon_craft_active: AtlasTexture
@export var icon_craft_inactive: AtlasTexture
@export var icon_quest_active: AtlasTexture
@export var icon_quest_inactive: AtlasTexture"""

content = re.sub(r'@export var closed_book_tex: AtlasTexture.*?@export var bookmark_inactive_tex: AtlasTexture', exports, content, flags=re.DOTALL)

# Now rewrite the _switch_tab logic to also swap the child Icon texture
old_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as TextureButton
		if btn:
			btn.texture_normal = bookmark_active_tex if i == index else bookmark_inactive_tex
		
	if index == 0:"""

new_switch = """func _switch_tab(index: int) -> void:
	for i in range(pages_container.get_child_count()):
		var page = pages_container.get_child(i)
		page.visible = (i == index)
		
	# Skip the first child of tabs_container because it's our Spacer!
	# The actual buttons are at index + 1
	var btn_idx = 0
	for i in range(tabs_container.get_child_count()):
		var btn = tabs_container.get_child(i) as TextureButton
		if not btn: continue
		
		btn.texture_normal = bookmark_active_tex if btn_idx == index else bookmark_inactive_tex
		
		# Now update the icon inside the button
		var icon = btn.get_node_or_null("Icon") as TextureRect
		if icon:
			if btn_idx == 0: icon.texture = icon_inv_active if btn_idx == index else icon_inv_inactive
			elif btn_idx == 1: icon.texture = icon_char_active if btn_idx == index else icon_char_inactive
			elif btn_idx == 2: icon.texture = icon_craft_active if btn_idx == index else icon_craft_inactive
			elif btn_idx == 3: icon.texture = icon_quest_active if btn_idx == index else icon_quest_inactive
		
		btn_idx += 1
		
	if index == 0:"""

content = content.replace(old_switch, new_switch)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
