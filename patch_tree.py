import re

with open("scripts/components/tree.gd", "r") as f:
    content = f.read()

# 1. Slow down tree fall
content = content.replace(
    'fall_tween.tween_property(falling_top, "rotation", fall_dir * (PI / 2.5), 0.5)',
    'fall_tween.tween_property(falling_top, "rotation", fall_dir * (PI / 2.5), 0.8)'
)
content = content.replace(
    'fall_tween.tween_property(falling_top, "modulate:a", 0.0, 0.5).set_delay(0.2)',
    'fall_tween.tween_property(falling_top, "modulate:a", 0.0, 0.4).set_delay(0.4)'
)
content = content.replace(
    'cleanup_tween.tween_interval(0.6)',
    'cleanup_tween.tween_interval(0.9)'
)

# 2. Modify particles function
old_particles = """	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.lifetime = 2.0 # Last much longer"""

new_particles = """	var particles = CPUParticles2D.new()
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.lifetime = 1.0 # Исчезают быстрее над землей
	
	if tree_size == "big":
		particles.amount = 15
	elif tree_size == "medium":
		particles.amount = 10
	else:
		particles.amount = 5"""
		
content = content.replace(old_particles, new_particles)

old_physics = """	# Float gently like a feather
	particles.gravity = Vector2(0, 60.0) 
	particles.direction = Vector2(0, -1) # Burst slightly upwards first
	particles.spread = 60.0
	particles.initial_velocity_min = 10.0
	particles.initial_velocity_max = 25.0
	
	# Slower rotation
	particles.angular_velocity_min = -45.0
	particles.angular_velocity_max = 45.0
	
	particles.scale_amount_min = 0.6
	particles.scale_amount_max = 1.0
	
	# Smooth fade out at the end
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.6, 1))
	curve.add_point(Vector2(1, 0))
	particles.scale_amount_curve = curve"""

new_physics = """	# Float gently like a feather
	particles.gravity = Vector2(0, 30.0) # Падают медленнее
	particles.direction = Vector2(0, -1) 
	particles.spread = 180.0 # Разлетаются кружась во все стороны
	particles.initial_velocity_min = 20.0
	particles.initial_velocity_max = 40.0
	
	# Быстрее крутятся
	particles.angular_velocity_min = -180.0
	particles.angular_velocity_max = 180.0
	
	particles.scale_amount_min = 0.5
	particles.scale_amount_max = 0.9
	
	# Smooth fade out at the end - исчезают еще в воздухе
	var curve = Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(0.4, 1))
	curve.add_point(Vector2(0.9, 0))
	particles.scale_amount_curve = curve"""

content = content.replace(old_physics, new_physics)

with open("scripts/components/tree.gd", "w") as f:
    f.write(content)
print("Patched tree.gd successfully")
