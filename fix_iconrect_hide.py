import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Update hide/show logic in _show_recipe_details
old_logic = """	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
		craft_stats.text = ""
		craft_icon.texture = null
		craft_btn.disabled = true
		craft_btn.visible = false
		craft_req_title.visible = false
		return
		
	var item = ItemDB.get_item(recipe_id)
	craft_btn.visible = true
	craft_req_title.visible = true"""

new_logic = """	if recipe_id == "":
		craft_name.text = "Выберите чертеж"
		craft_desc.text = ""
		craft_stats.text = ""
		craft_icon.texture = null
		craft_icon.visible = false
		craft_btn.disabled = true
		craft_btn.visible = false
		craft_req_title.visible = false
		return
		
	var item = ItemDB.get_item(recipe_id)
	craft_icon.visible = true
	craft_btn.visible = true
	craft_req_title.visible = true"""

content = content.replace(old_logic, new_logic)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
