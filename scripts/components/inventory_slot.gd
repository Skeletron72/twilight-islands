extends Control

signal item_clicked(item_id: String)

var slot_index: int = -1
var custom_item_id: String = ""
var custom_amount: int = -1
var is_selected: bool = false
var selector_tween: Tween = null

@onready var icon_rect: TextureRect = $Icon
@onready var highlight_rect: TextureRect = get_node_or_null("Highlight")
@onready var selector_rect: TextureRect = get_node_or_null("Selector")
@onready var amount_label: Label = $Amount

var sel_wide_tex: AtlasTexture
var sel_narrow_tex: AtlasTexture

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	var sel_img = preload("res://assets/new_assets/Cute_Fantasy_UI/UI/UI_Selectors.png")
	sel_wide_tex = AtlasTexture.new()
	sel_wide_tex.atlas = sel_img
	sel_wide_tex.region = Rect2(96, 768, 48, 48)
	
	sel_narrow_tex = AtlasTexture.new()
	sel_narrow_tex.atlas = sel_img
	sel_narrow_tex.region = Rect2(144, 768, 48, 48)

func set_selected(selected: bool) -> void:
	is_selected = selected
	if not selector_rect:
		return
		
	if selector_tween:
		selector_tween.kill()
		selector_tween = null
		
	if is_selected:
		if highlight_rect:
			highlight_rect.hide()
		selector_rect.show()
		selector_rect.pivot_offset = selector_rect.size / 2.0
		selector_rect.scale = Vector2(0.94, 0.94)
		selector_rect.texture = sel_narrow_tex
		
		# Quick punch on slot
		var punch_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		punch_tween.tween_property(self, "scale", Vector2(1.06, 1.06), 0.1)
		punch_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.08)
		
		selector_tween = create_tween().set_loops()
		selector_tween.tween_callback(func():
			if selector_rect: selector_rect.texture = sel_wide_tex
		)
		selector_tween.tween_property(selector_rect, "scale", Vector2(1.08, 1.08), 0.35)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		selector_tween.tween_callback(func():
			if selector_rect: selector_rect.texture = sel_narrow_tex
		)
		selector_tween.tween_property(selector_rect, "scale", Vector2(0.94, 0.94), 0.35)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	else:
		selector_rect.hide()
		selector_rect.scale = Vector2.ONE
		scale = Vector2.ONE

func _on_mouse_entered() -> void:
	if not is_selected and highlight_rect:
		highlight_rect.show()

func _on_mouse_exited() -> void:
	if highlight_rect:
		highlight_rect.hide()

func set_slot_index(idx: int) -> void:
	slot_index = idx
	_refresh()

func set_item(id: String, amt: int) -> void:
	custom_item_id = id
	custom_amount = amt
	_refresh()

func _refresh() -> void:
	var item_id = ""
	var amount = 0
	
	if custom_amount != -1:
		item_id = custom_item_id
		amount = custom_amount
	else:
		if slot_index < 0 or slot_index >= InventoryManager.ui_slots.size(): return
		item_id = InventoryManager.ui_slots[slot_index]
		amount = InventoryManager.get_item_amount(item_id) if item_id != "" else 0
	
	if amount > 0 and item_id != "":
		icon_rect.texture = ItemDB.get_icon(item_id)
		amount_label.text = str(amount)
		if amount > 1:
			amount_label.show()
		else:
			amount_label.hide()
			
		var item_data = ItemDB.get_item(item_id)
		var item_name = item_data.get("name", item_id)
		var item_desc = item_data.get("desc", "")
		tooltip_text = item_name if item_desc == "" else "%s\n%s" % [item_name, item_desc]
	else:
		icon_rect.texture = null
		amount_label.hide()
		tooltip_text = ""

func _get_drag_data(_at_position: Vector2) -> Variant:
	if slot_index < 0: return null
	var item_id = InventoryManager.ui_slots[slot_index]
	if item_id == "" or InventoryManager.get_item_amount(item_id) <= 0: return null
	
	var preview = TextureRect.new()
	preview.texture = icon_rect.texture
	preview.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	preview.custom_minimum_size = Vector2(44, 44)
	preview.modulate.a = 0.85
	
	var control = Control.new()
	preview.position = -Vector2(22, 22)
	control.add_child(preview)
	set_drag_preview(control)
	
	return {"type": "inventory_slot", "slot_index": slot_index}

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if slot_index < 0: return false
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "inventory_slot":
		return true
	return false

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if slot_index < 0: return
	var from_idx = data["slot_index"]
	if from_idx != slot_index:
		InventoryManager.swap_ui_slots(from_idx, slot_index)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if custom_amount != -1:
			pass
		elif slot_index >= 0 and slot_index < InventoryManager.ui_slots.size():
			var item_id = InventoryManager.ui_slots[slot_index]
			if item_id != "":
				item_clicked.emit(item_id)
