shader_type canvas_item;

// Эффект сужения в круг и одновременного затемнения экрана (iris-in / iris-out)
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(0.5, 0.5);
uniform vec2 resolution = vec2(320.0, 180.0);

void fragment() {
	if (progress <= 0.001) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else if (progress >= 0.999) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Квантование координат для идеального совпадения с пиксель-артом
		vec2 pixel_uv = floor(UV * resolution) / resolution;
		
		// Коррекция соотношения сторон для круглого радиуса (не овала)
		vec2 diff = pixel_uv - center;
		diff.x *= (resolution.x / resolution.y);
		float dist = length(diff);
		
		// Радиус раскрытия
		float max_radius = 0.85;
		float cur_radius = (1.0 - progress) * max_radius;
		
		// Ступенчатый пиксельный круг
		float is_outside = step(cur_radius, dist);
		
		// Плавное общее затемнение внутри круга по мере сужения
		float darken = progress * 0.45;
		
		float alpha = clamp(max(is_outside, darken), 0.0, 1.0);
		COLOR = vec4(0.0, 0.0, 0.0, alpha);
	}
}
