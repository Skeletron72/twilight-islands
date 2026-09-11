import re

file_path = "scripts/components/day_night_cycle.gd"
with open(file_path, "r") as f:
    content = f.read()

init_globals = """	RenderingServer.global_shader_parameter_add("global_shadow_skew", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.5)
	RenderingServer.global_shader_parameter_add("global_shadow_scale", RenderingServer.GLOBAL_VAR_TYPE_FLOAT, 0.5)
	RenderingServer.global_shader_parameter_add("global_shadow_color", RenderingServer.GLOBAL_VAR_TYPE_COLOR, Color(0,0,0,0.4))
"""

# add it to _ready
content = content.replace("func _ready() -> void:\n", "func _ready() -> void:\n" + init_globals)

# update apply_color_for_time to also tween these parameters
tween_block = """	if duration <= 0.0:
		color = target_color
		if godrays_material:
			godrays_material.set_shader_parameter("color", target_godray_color)
		RenderingServer.global_shader_parameter_set("global_shadow_skew", target_skew)
		RenderingServer.global_shader_parameter_set("global_shadow_color", target_shadow_color)
	else:
		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "color", target_color, duration)
		
		# Animate global shader parameters using a method tweener
		tween.tween_method(_tween_shadow_skew, RenderingServer.global_shader_parameter_get("global_shadow_skew"), target_skew, duration)
		tween.tween_method(_tween_shadow_color, RenderingServer.global_shader_parameter_get("global_shadow_color"), target_shadow_color, duration)
		
		if godrays_material:
			tween.tween_property(godrays_material, "shader_parameter/color", target_godray_color, duration)
"""

content = re.sub(r'\tif duration <= 0\.0:.*?duration\)\n', tween_block, content, flags=re.DOTALL)

# add the target vars
target_vars = """	var target_color: Color
	var target_godray_color: Color
	var target_skew: float
	var target_shadow_color: Color"""
content = re.sub(r'\tvar target_color: Color\n\tvar target_godray_color: Color', target_vars, content)

# update match
match_block = """		GameStateManager.TimeOfDay.MORNING:
			target_color = morning_color
			target_godray_color = Color(1.0, 0.9, 0.65, 0.4)
			target_skew = 0.8
			target_shadow_color = Color(0.1, 0.1, 0.2, 0.3)
		GameStateManager.TimeOfDay.DAY:
			target_color = day_color
			target_godray_color = Color(1.0, 1.0, 0.9, 0.3)
			target_skew = 0.2
			target_shadow_color = Color(0.0, 0.0, 0.05, 0.4)
		GameStateManager.TimeOfDay.DUSK:
			target_color = dusk_color
			target_godray_color = Color(1.0, 0.6, 0.4, 0.4)
			target_skew = -0.8
			target_shadow_color = Color(0.15, 0.05, 0.1, 0.4)
		GameStateManager.TimeOfDay.NIGHT:
			target_color = night_color
			target_godray_color = Color(0.3, 0.4, 0.7, 0.15)
			target_skew = 0.4
			target_shadow_color = Color(0.02, 0.02, 0.05, 0.2)"""
content = re.sub(r'\t\tGameStateManager\.TimeOfDay\.MORNING:.*?0\.15\)', match_block, content, flags=re.DOTALL)

# add tween methods
methods = """

func _tween_shadow_skew(val: float):
	RenderingServer.global_shader_parameter_set("global_shadow_skew", val)

func _tween_shadow_color(val: Color):
	RenderingServer.global_shader_parameter_set("global_shadow_color", val)
"""
content += methods

with open(file_path, "w") as f:
    f.write(content)
print("Updated day_night_cycle.gd")
