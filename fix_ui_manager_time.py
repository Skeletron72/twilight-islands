import re

with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Replace time_label reference
old_refs = """@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel"""
new_refs = """@onready var time_icon: TextureRect = $TimeContainer/TimeIcon
@onready var time_label: Label = $TimeContainer/TimeLabel
@onready var day_label: Label = $TimeContainer/DayLabel"""
content = content.replace(old_refs, new_refs)

# Replace _update_time_text
old_update = """func _update_time_text() -> void:
	var time_str = ""
	match GameStateManager.current_time:
		GameStateManager.TimeOfDay.MORNING: time_str = "Morning"
		GameStateManager.TimeOfDay.DAY: time_str = "Day"
		GameStateManager.TimeOfDay.DUSK: time_str = "Dusk"
		GameStateManager.TimeOfDay.NIGHT: time_str = "Night"
	if time_label:
		time_label.text = "Day %d - %s" % [GameStateManager.current_day, time_str]"""

new_update = """func _update_time_text() -> void:
	var time_str = ""
	var icon_tex = null
	match GameStateManager.current_time:
		GameStateManager.TimeOfDay.MORNING:
			time_str = "Утро"
			icon_tex = tex_morning
		GameStateManager.TimeOfDay.DAY:
			time_str = "День"
			icon_tex = tex_day
		GameStateManager.TimeOfDay.DUSK:
			time_str = "Вечер"
			icon_tex = tex_evening
		GameStateManager.TimeOfDay.NIGHT:
			time_str = "Ночь"
			icon_tex = tex_night
	
	if time_label: time_label.text = time_str
	if time_icon: time_icon.texture = icon_tex
	if day_label: day_label.text = "День %d" % GameStateManager.current_day"""

content = content.replace(old_update, new_update)

# Add tex variables and init logic
tex_vars = """var tex_morning: AtlasTexture
var tex_day: AtlasTexture
var tex_evening: AtlasTexture
var tex_night: AtlasTexture"""

content = content.replace('var tex_open_hover: AtlasTexture', 'var tex_open_hover: AtlasTexture\n' + tex_vars)

init_logic = """func _init_time_textures() -> void:
	tex_morning = AtlasTexture.new()
	tex_morning.atlas = ui_tex
	tex_morning.region = Rect2(1056, 16, 48, 48)
	
	tex_day = AtlasTexture.new()
	tex_day.atlas = ui_tex
	tex_day.region = Rect2(1104, 16, 48, 48)
	
	tex_evening = AtlasTexture.new()
	tex_evening.atlas = ui_tex
	tex_evening.region = Rect2(1056, 64, 48, 48)
	
	tex_night = AtlasTexture.new()
	tex_night.atlas = ui_tex
	tex_night.region = Rect2(1104, 64, 48, 48)"""

content = content.replace('func _init_book_textures() -> void:', init_logic + '\n\nfunc _init_book_textures() -> void:')

# Call _init_time_textures in ready
content = content.replace('_init_book_textures()', '_init_time_textures()\n\t_init_book_textures()')

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
