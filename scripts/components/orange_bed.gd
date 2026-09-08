extends StaticBody2D
class_name OrangeBed

enum Direction {
	FRONT = 0, # перед: 144 0 16 32
	LEFT = 1,  # изголовье слева: 160 0 32 32
	RIGHT = 2  # изголовье справо: 192 0 32 32
}

const TEXTURE_PATH = "res://assets/new_assets/Cute_Fantasy/Buildings/House_Decor/Beds.png"

const REGIONS = {
	Direction.FRONT: Rect2(144, 0, 16, 32),
	Direction.LEFT:  Rect2(160, 0, 32, 32),
	Direction.RIGHT: Rect2(192, 0, 32, 32)
}

# Размеры коллизии у основания кровати
const SHAPES = {
	Direction.FRONT: { "size": Vector2(14, 16), "offset": Vector2(0, -8) },
	Direction.LEFT:  { "size": Vector2(28, 14), "offset": Vector2(0, -7) },
	Direction.RIGHT: { "size": Vector2(28, 14), "offset": Vector2(0, -7) }
}

@export var current_direction: int = Direction.FRONT

@onready var sprite: Sprite2D = $Sprite2D
@onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	add_to_group("interactable")
	y_sort_enabled = true
	_update_orientation()

func set_direction(dir: int) -> void:
	current_direction = dir % 3
	_update_orientation()

func rotate_bed() -> void:
	set_direction((current_direction + 1) % 3)

func _update_orientation() -> void:
	if not sprite:
		sprite = get_node_or_null("Sprite2D")
	if not col_shape:
		col_shape = get_node_or_null("CollisionShape2D")
		
	if sprite:
		if not sprite.texture:
			sprite.texture = load(TEXTURE_PATH)
		sprite.region_enabled = true
		sprite.region_rect = REGIONS[current_direction]
		sprite.offset = Vector2(0, -16) # База кровати в (0, 0)
		
	if col_shape:
		var cfg = SHAPES[current_direction]
		var rect_shape = col_shape.shape as RectangleShape2D
		if not rect_shape:
			rect_shape = RectangleShape2D.new()
			col_shape.shape = rect_shape
		rect_shape.size = cfg["size"]
		col_shape.position = cfg["offset"]

func interact(player: Node2D) -> void:
	# Сон / отдых в кровати
	_sleep(player)

func _sleep(player: Node2D) -> void:
	var tm = get_node_or_null("/root/TransitionManager")
	var gsm = get_node_or_null("/root/GameStateManager")
	
	var do_sleep_action = func():
		if gsm:
			gsm.heal(100.0)
			gsm.add_stamina(100.0)
			if gsm.current_time in [gsm.TimeOfDay.DUSK, gsm.TimeOfDay.NIGHT]:
				gsm.advance_day()
			else:
				gsm.advance_time()
				
	if tm:
		tm.play_iris_transition(do_sleep_action)
	else:
		do_sleep_action.call()
