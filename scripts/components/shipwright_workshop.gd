extends StaticBody2D
class_name ShipwrightWorkshop

@export var orientation: int = 0 # 0=South, 1=East, 2=North, 3=West

@onready var house_sprite: Sprite2D = $HouseSprite
@onready var pier_container: Node2D = $PierContainer
@onready var door_area: Area2D = $DoorArea
@onready var prompt_label: Label = $DoorArea/PromptLabel
@onready var mooring_point: Marker2D = $MooringPoint
@onready var finn_point: Marker2D = $FinnPoint

var is_under_construction: bool = false

func _ready() -> void:
	add_to_group("interactable")
	add_to_group("buildings")
	y_sort_enabled = true
	setup_orientation(orientation)
	if HomeStateManager and HomeStateManager.workshop_under_construction:
		set_under_construction(true)
	else:
		set_under_construction(false)

func set_under_construction(val: bool) -> void:
	is_under_construction = val
	if is_under_construction:
		if house_sprite:
			house_sprite.modulate = Color(0.85, 0.75, 0.65, 0.85)
		if prompt_label:
			var rem = HomeStateManager.get_days_remaining() if HomeStateManager else 2
			prompt_label.text = "[E] Стройка верфи (%d дн.)" % rem
	else:
		if house_sprite:
			house_sprite.modulate = Color.WHITE
		if prompt_label:
			prompt_label.text = "[E] Войти в мастерскую"

func finish_construction() -> void:
	set_under_construction(false)
	var dust_scene = load("res://scenes/vfx/impact_dust.tscn")
	if dust_scene:
		for offset in [Vector2(-20, 0), Vector2(20, 0), Vector2(0, 20), Vector2(0, -20)]:
			var d = dust_scene.instantiate()
			d.global_position = global_position + offset
			get_tree().current_scene.add_child(d)
	var exp_mgr = get_node_or_null("/root/ExpeditionManager")
	if exp_mgr and exp_mgr.has_method("post_thought"):
		exp_mgr.post_thought("Корабельная верфь Финна завершена! Плот перенесен к причалу мастерской.", Color(0.4, 1.0, 0.6))

func setup_orientation(rot: int) -> void:
	orientation = rot
	_build_pier_visuals()
	_update_points()

func _build_pier_visuals() -> void:
	if not pier_container:
		return
	for c in pier_container.get_children():
		c.queue_free()

	var bridge_tex = preload("res://assets/new_assets/Cute_Fantasy/Tiles/Bridge/Bridge_Wood_1.png")
	var pier_sp = Sprite2D.new()
	pier_sp.texture = bridge_tex
	pier_sp.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	pier_sp.z_index = -5

	match orientation:
		0: # South: Pier extends Down into water
			pier_sp.position = Vector2(0, 42)
			pier_sp.rotation_degrees = 90
		1: # East: Pier extends Right into water
			pier_sp.position = Vector2(48, 8)
			pier_sp.rotation_degrees = 0
		2: # North: Pier extends Up into water
			pier_sp.position = Vector2(0, -68)
			pier_sp.rotation_degrees = 90
		3: # West: Pier extends Left into water
			pier_sp.position = Vector2(-48, 8)
			pier_sp.rotation_degrees = 0

	pier_container.add_child(pier_sp)

func _update_points() -> void:
	if mooring_point:
		match orientation:
			0: mooring_point.position = Vector2(30, 42)
			1: mooring_point.position = Vector2(50, 24)
			2: mooring_point.position = Vector2(30, -56)
			3: mooring_point.position = Vector2(-50, 24)
			_: mooring_point.position = Vector2(30, 42)
	if finn_point:
		match orientation:
			0: finn_point.position = Vector2(16, 10)
			1: finn_point.position = Vector2(12, 16)
			2: finn_point.position = Vector2(16, -12)
			3: finn_point.position = Vector2(-12, 16)
			_: finn_point.position = Vector2(16, 10)

func interact(player: Node2D) -> void:
	if is_under_construction:
		var rem = HomeStateManager.get_days_remaining() if HomeStateManager else 2
		var exp_mgr = get_node_or_null("/root/ExpeditionManager")
		if exp_mgr and exp_mgr.has_method("post_thought"):
			exp_mgr.post_thought("Идёт строительство верфи! Финн закончит работу через %d дн. А пока ваш плот ждёт на пляже и готов к вылазкам!" % rem, Color(1.0, 0.85, 0.4))
		return

	var wm = get_node_or_null("/root/WorkshopManager")
	if wm and wm.has_method("enter_workshop"):
		wm.enter_workshop(self, player)
	else:
		var exp_mgr = get_node_or_null("/root/ExpeditionManager")
		if exp_mgr and exp_mgr.has_method("post_thought"):
			exp_mgr.post_thought("Дверь мастерской открыта, но внутри еще идет обустройство.", Color(0.8, 0.8, 0.8))
