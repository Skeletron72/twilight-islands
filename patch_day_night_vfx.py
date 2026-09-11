import re

file_path = "scripts/components/day_night_cycle.gd"
with open(file_path, "r") as f:
    content = f.read()

new_code = """extends CanvasModulate

@export var morning_color: Color = Color(1.04, 0.96, 0.90)
@export var day_color: Color = Color(1.0, 1.0, 1.0)
@export var dusk_color: Color = Color(0.88, 0.58, 0.48)
@export var night_color: Color = Color(0.20, 0.22, 0.42)
@export var transition_time: float = 2.5

var sun: DirectionalLight2D
var godrays_material: ShaderMaterial

func _ready() -> void:
	# Create a sun for dynamic shadows
	sun = DirectionalLight2D.new()
	sun.shadow_enabled = true
	sun.shadow_color = Color(0.05, 0.05, 0.1, 0.4) # Soft blueish shadow
	sun.shadow_filter = DirectionalLight2D.SHADOW_FILTER_NONE # Pixel perfect shadows
	sun.color = Color.WHITE
	sun.energy = 0.6
	sun.blend_mode = Light2D.BLEND_MODE_ADD
	add_child(sun)
	
	var vfx = get_parent().get_node_or_null("VFXLayer/Godrays")
	if vfx:
		godrays_material = vfx.material as ShaderMaterial
	
	GameStateManager.time_changed.connect(_on_time_changed)
	_apply_color_for_time(GameStateManager.current_time, 0.0)

func _on_time_changed(new_time: int) -> void:
	_apply_color_for_time(new_time, transition_time)

func _apply_color_for_time(time: int, duration: float) -> void:
	var target_color: Color
	var target_rotation: float
	var target_energy: float
	var target_shadow_color: Color
	var target_godray_color: Color
	
	match time:
		GameStateManager.TimeOfDay.MORNING:
			target_color = morning_color
			target_rotation = deg_to_rad(-60) # Sun rising from east (shadows cast west)
			target_energy = 0.6
			target_shadow_color = Color(0.05, 0.05, 0.15, 0.5)
			target_godray_color = Color(1.0, 0.9, 0.65, 0.4)
		GameStateManager.TimeOfDay.DAY:
			target_color = day_color
			target_rotation = deg_to_rad(-100) # Sun high up (shadows cast slightly north-west)
			target_energy = 0.8
			target_shadow_color = Color(0.0, 0.0, 0.05, 0.35)
			target_godray_color = Color(1.0, 1.0, 0.9, 0.3)
		GameStateManager.TimeOfDay.DUSK:
			target_color = dusk_color
			target_rotation = deg_to_rad(-160) # Sun setting west (shadows cast east)
			target_energy = 0.5
			target_shadow_color = Color(0.1, 0.05, 0.1, 0.6)
			target_godray_color = Color(1.0, 0.6, 0.4, 0.4)
		GameStateManager.TimeOfDay.NIGHT:
			target_color = night_color
			target_rotation = deg_to_rad(-80) # Moon light
			target_energy = 0.3
			target_shadow_color = Color(0.02, 0.02, 0.05, 0.7)
			target_godray_color = Color(0.3, 0.4, 0.7, 0.15)
			
	if duration <= 0.0:
		color = target_color
		if sun:
			sun.rotation = target_rotation
			sun.energy = target_energy
			sun.shadow_color = target_shadow_color
		if godrays_material:
			godrays_material.set_shader_parameter("color", target_godray_color)
	else:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "color", target_color, duration)
		if sun:
			tween.tween_property(sun, "rotation", target_rotation, duration)
			tween.tween_property(sun, "energy", target_energy, duration)
			tween.tween_property(sun, "shadow_color", target_shadow_color, duration)
		if godrays_material:
			# Godot tween property on material doesn't work directly on shader parameters usually, 
			# but we can tween a dummy property or just set it via a MethodTweener.
			# Actually in Godot 4 you CAN tween material parameters!
			tween.tween_property(godrays_material, "shader_parameter/color", target_godray_color, duration)
"""
with open(file_path, "w") as f:
    f.write(new_code)
print("Updated day_night_cycle.gd with godrays integration")
