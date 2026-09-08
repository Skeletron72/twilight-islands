with open("scripts/components/player.gd", "r") as f:
    content = f.read()

# Remove var declarations
content = content.replace("var hp_bar: ProgressBar\n", "")
content = content.replace("var stamina_bar: ProgressBar\n", "")
content = content.replace("var hunger_bar: ProgressBar\n", "")

# Remove the entire _process block with old bars
old_block = """func _process(delta: float) -> void:
\tif hp_bar and stamina_bar and hunger_bar:
\t\thp_bar.max_value = GameStateManager.max_health
\t\thp_bar.value = GameStateManager.current_health
\t\tstamina_bar.max_value = GameStateManager.max_stamina
\t\tstamina_bar.value = GameStateManager.current_stamina
\t\thunger_bar.max_value = GameStateManager.max_hunger
\t\thunger_bar.value = GameStateManager.current_hunger
\t\t
\t\t# Hunger logic
\t\tvar hunger_pct = GameStateManager.current_hunger / GameStateManager.max_hunger
\t\tif hunger_pct <= 0.25:
\t\t\thunger_wrapper.visible = true
\t\t\tif hunger_pct <= 0.05:
\t\t\t\thunger_bar.position = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0))
\t\t\t\t# Flicker
\t\t\t\tif randi() % 10 < 2:
\t\t\t\t\thunger_bar.modulate = Color(1.5, 0.5, 0.5)
\t\t\t\telse:
\t\t\t\t\thunger_bar.modulate = Color.WHITE
\t\t\telse:
\t\t\t\thunger_bar.position = Vector2.ZERO
\t\t\t\thunger_bar.modulate = Color.WHITE
\t\telse:
\t\t\thunger_wrapper.visible = false

\t\t
\t\thp_bar.visible = (hp_bar.value < hp_bar.max_value)
\t\tstamina_bar.visible = (stamina_bar.value < stamina_bar.max_value)
\t\t
\t\tvar style = stamina_bar.get_theme_stylebox("fill")
\t\tif GameStateManager.is_exhausted:
\t\t\tstyle.bg_color = Color(0.8, 0.2, 0.2, 1)
\t\telse:
\t\t\tstyle.bg_color = Color(0.15, 0.85, 0.25, 1)"""

if old_block in content:
    content = content.replace(old_block, "")
    print("Old bar block removed!")
else:
    print("Block not found exactly, trying partial...")

# Also remove hunger_wrapper reference if any
content = content.replace("var hunger_wrapper\n", "")

with open("scripts/components/player.gd", "w") as f:
    f.write(content)
print("Done")
