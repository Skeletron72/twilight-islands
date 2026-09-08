old = '''func _ensure_water_safety() -> void:
	if _is_water_at(global_position + Vector2(0, -4)):
		global_position = last_safe_position
		if current_state == State.WALKING:
			direction = -direction
			_pick_new_state()
	else:
		last_safe_position = global_position'''

new = '''var _is_flying: bool = false

func _ensure_water_safety() -> void:
	if _is_flying: return
	
	if _is_water_at(global_position + Vector2(0, -4)):
		_do_panic_fly()
	else:
		last_safe_position = global_position

func _do_panic_fly() -> void:
	_is_flying = true
	var land_pos = last_safe_position
	
	# Прыжок вверх
	var fly_tween = create_tween()
	fly_tween.set_parallel(true)
	fly_tween.tween_property(self, "position:y", position.y - 40.0, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	fly_tween.tween_property(sprite, "scale", Vector2(1.3, 0.7), 0.1)
	fly_tween.chain()
	
	# Плавный перелет к безопасной точке
	var fly2 = create_tween()
	fly2.tween_interval(0.3)
	fly2.tween_property(self, "global_position", land_pos - Vector2(0, 30), 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# Приземление
	var land = create_tween()
	land.tween_interval(0.6)
	land.tween_property(self, "global_position", land_pos, 0.2)\
		.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	land.tween_property(sprite, "scale", Vector2(1.2, 0.8), 0.05)
	land.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)
	land.tween_callback(func():
		_is_flying = false
		_enter_state(State.IDLE)
		state_timer = 1.0
	)'''

with open("scripts/components/chicken.gd", "r") as f:
    content = f.read()

if old in content:
    content = content.replace(old, new)
    with open("scripts/components/chicken.gd", "w") as f:
        f.write(content)
    print("Patched!")
else:
    print("Pattern not found, dumping file end...")
    print(content[-500:])
