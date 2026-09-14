extends Control
class_name ThoughtLogUI

## ThoughtLogUI
## Левая панель мыслей / диалоговый чат размышлений персонажа.
## В стиле Stardew Valley реплики появляются снизу, окрашиваются в зависимости
## от контекста (опасность, тревога, раздумья), плавно всплывают и затухают со временем.

@export var max_messages: int = 5
@export var message_lifetime: float = 8.5

@onready var container: VBoxContainer = $MarginContainer/VBoxContainer

const FONT_WARM = preload("res://assets/fonts/WarmPixel.ttf")

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if container:
		# Очищаем демонстрационные сообщения, если они есть
		for child in container.get_children():
			child.queue_free()
			
	if ExpeditionManager:
		ExpeditionManager.thought_posted.connect(_on_thought_posted)

func _on_thought_posted(text: String, color: Color) -> void:
	add_thought(text, color)

func add_thought(text: String, color: Color = Color(0.95, 0.95, 0.90)) -> void:
	if not container:
		return
		
	# Если сообщений много, удаляем самое старое сверху
	if container.get_child_count() >= max_messages:
		var oldest = container.get_child(0)
		if oldest:
			oldest.queue_free()

	var msg_label = RichTextLabel.new()
	msg_label.bbcode_enabled = true
	msg_label.fit_content = true
	msg_label.scroll_active = false
	msg_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	msg_label.custom_minimum_size = Vector2(240, 0)
	
	msg_label.add_theme_font_override("normal_font", FONT_WARM)
	msg_label.add_theme_font_size_override("normal_font_size", 9)
	msg_label.add_theme_color_override("default_color", color)
	msg_label.add_theme_constant_override("outline_size", 4)
	msg_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.95))
	
	# Форматирование: звездочка/иконка мысли и текст
	msg_label.text = "[color=#%s]• %s[/color]" % [color.to_html(false), text]
	
	# Начальное появление с плавным фейдом
	msg_label.modulate.a = 0.0
	container.add_child(msg_label)
	
	var in_tween = create_tween()
	in_tween.tween_property(msg_label, "modulate:a", 1.0, 0.25)
	
	# Затухание через message_lifetime
	var lifetime_tween = create_tween()
	lifetime_tween.tween_interval(message_lifetime)
	lifetime_tween.tween_property(msg_label, "modulate:a", 0.0, 1.2)
	lifetime_tween.tween_callback(func():
		if is_instance_valid(msg_label):
			msg_label.queue_free()
	)
