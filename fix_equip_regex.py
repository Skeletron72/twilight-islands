import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

pattern = r'(for s in slots:.*?char_equip_grid\.add_child\(slot_panel\))'

new_slot_logic = """for s in slots:
			var slot_panel = TextureRect.new()
			var atlas = AtlasTexture.new()
			atlas.atlas = preload("res://assets/sprites/ui/inventory/UI.png")
			atlas.region = Rect2(416, 272, 16, 16)
			slot_panel.texture = atlas
			slot_panel.custom_minimum_size = Vector2(42, 42)
			
			var icon = TextureRect.new()
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			icon.set_anchors_preset(Control.PRESET_FULL_RECT)
			
			var eq_id = InventoryManager.equipment.get(s, "")
			if eq_id != "":
				icon.texture = ItemDB.get_icon(eq_id)
				
			slot_panel.add_child(icon)
			
			if eq_id != "":
				var btn = Button.new()
				btn.text = "Снять"
				btn.flat = true
				btn.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
				btn.add_theme_font_size_override("font_size", 12)
				btn.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2, 1))
				btn.add_theme_color_override("font_hover_color", Color(1.0, 0.4, 0.4, 1))
				
				# Position it nicely
				btn.position = Vector2(44, 12)
				btn.pressed.connect(func(): 
					InventoryManager.unequip(s)
					_refresh_character_tab()
				)
				slot_panel.add_child(btn)
				
			char_equip_grid.add_child(slot_panel)"""

content = re.sub(pattern, new_slot_logic, content, flags=re.DOTALL)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
