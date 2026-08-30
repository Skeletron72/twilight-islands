import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Change req_label font size 12 -> 10
content = content.replace('req_label.add_theme_font_size_override("font_size", 12)', 'req_label.add_theme_font_size_override("font_size", 10)')

# Change stats text to be more compact
old_stats = """	var stats_text = ""
	if item.has("damage"): stats_text += "Урон: %d  " % item["damage"]
	if item.has("efficiency"): stats_text += "Эффективность: %d  " % item["efficiency"]
	if item.has("defense"): stats_text += "Защита: %d  " % item["defense"]
	if item.has("durability"): stats_text += "Прочность: %d" % item["durability"]
	craft_stats.text = stats_text"""

new_stats = """	var stats_parts = []
	if item.has("damage"): stats_parts.append("Урон: %d" % item["damage"])
	if item.has("efficiency"): stats_parts.append("Эфф: %d" % item["efficiency"])
	if item.has("defense"): stats_parts.append("Защита: %d" % item["defense"])
	if item.has("durability"): stats_parts.append("Проч: %d" % item["durability"])
	craft_stats.text = " ".join(stats_parts)"""

content = content.replace(old_stats, new_stats)

# Add WarmPixel font explicitly to DescLabel and StatsLabel in _ready
old_ready = """	craft_name.label_settings = null
	craft_name.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
	craft_name.add_theme_font_size_override("font_size", 16)
	craft_name.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))"""

new_ready = """	craft_name.label_settings = null
	craft_name.add_theme_font_override("font", preload("res://assets/fonts/Chalkboard.ttf"))
	craft_name.add_theme_font_size_override("font_size", 16)
	craft_name.add_theme_color_override("font_color", Color(0.2, 0.1, 0.05, 1))
	
	craft_desc.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))
	craft_stats.add_theme_font_override("font", preload("res://assets/fonts/WarmPixel.ttf"))"""

content = content.replace(old_ready, new_ready)

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
