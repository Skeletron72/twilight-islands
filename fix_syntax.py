with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

bad_string = "func _init_time_textures()\n\t_init_book_textures() -> void:"
good_string = "func _init_book_textures() -> void:"

content = content.replace(bad_string, good_string)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
