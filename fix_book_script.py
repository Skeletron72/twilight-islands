import re

with open('scripts/components/book_ui.gd', 'r') as f:
    content = f.read()

# Insert the exports and variables at the top of the file
exports = """extends Control

@export var closed_book_tex: AtlasTexture
@export var open_book_tex: AtlasTexture

@onready var book_panel: TextureRect = $DimBackground/CenterContainer/HBoxContainer/BookPanel
"""

content = content.replace('extends Control\n', exports)

# Fix the Button cast
content = content.replace('as Button', 'as BaseButton')

with open('scripts/components/book_ui.gd', 'w') as f:
    f.write(content)
