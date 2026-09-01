with open("scripts/components/extraction_zone.gd", "r") as f:
    content = f.read()

anim_code = """
var anim_timer: float = 0.0
var fps: float = 6.0

func _process(delta: float) -> void:
	anim_timer += delta
	if anim_timer >= 1.0 / fps:
		anim_timer = 0.0
		var sprite = get_node_or_null("Sprite2D")
		if sprite:
			sprite.frame = (sprite.frame + 1) % sprite.hframes
"""

if "func _process" not in content:
    content += anim_code
    with open("scripts/components/extraction_zone.gd", "w") as f:
        f.write(content)
    print("Script patched!")
