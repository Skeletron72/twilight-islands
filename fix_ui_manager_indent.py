with open('scripts/components/ui_manager.gd', 'r') as f:
    content = f.read()

# Add _update_time_text() back to the signal handlers!
content = content.replace(
    'func _on_time_changed(new_time: int) -> void:\n\nfunc _on_day_changed(new_day: int) -> void:\n\nfunc _update_time_text() -> void:',
    'func _on_time_changed(new_time: int) -> void:\n\t_update_time_text()\n\nfunc _on_day_changed(new_day: int) -> void:\n\t_update_time_text()\n\nfunc _update_time_text() -> void:'
)

with open('scripts/components/ui_manager.gd', 'w') as f:
    f.write(content)
