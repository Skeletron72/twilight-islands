import re

with open('scripts/autoloads/item_db.gd', 'r') as f:
    content = f.read()

# Update get_icon to support custom textures/regions
old_get_icon = """func get_icon(id: String) -> Texture2D:
	var item = get_item(id)
	if item.is_empty(): return null
	
	if item.has("grid_pos"):
		var pos = item["grid_pos"]
		var atlas = AtlasTexture.new()
		atlas.atlas = atlas_texture_file
		atlas.region = Rect2((pos.x - 1) * ITEM_SIZE, (pos.y - 1) * ITEM_SIZE, ITEM_SIZE, ITEM_SIZE)
		return atlas
		
	return null"""

new_get_icon = """func get_icon(id: String) -> Texture2D:
	var item = get_item(id)
	if item.is_empty(): return null
	
	if item.has("custom_atlas"):
		var atlas = AtlasTexture.new()
		atlas.atlas = load(item["custom_atlas"])
		atlas.region = item["custom_region"]
		return atlas
		
	if item.has("grid_pos"):
		var pos = item["grid_pos"]
		var atlas = AtlasTexture.new()
		atlas.atlas = atlas_texture_file
		atlas.region = Rect2((pos.x - 1) * ITEM_SIZE, (pos.y - 1) * ITEM_SIZE, ITEM_SIZE, ITEM_SIZE)
		return atlas
		
	return null"""

content = content.replace(old_get_icon, new_get_icon)

# Update campfire and storage_box in ITEMS
content = content.replace('"grid_pos": Vector2(9, 20)', '"custom_atlas": "res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png",\n\t\t"custom_region": Rect2(592, 336, 32, 32)')
content = content.replace('"grid_pos": Vector2(8, 20)', '"custom_atlas": "res://assets/sprites/tileset/spr_tileset_sunnysideworld_16px.png",\n\t\t"custom_region": Rect2(560, 160, 16, 32)')

with open('scripts/autoloads/item_db.gd', 'w') as f:
    f.write(content)
