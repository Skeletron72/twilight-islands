shader_type canvas_item;

// Объемный туман в стиле Project Zomboid: медленные, клубящиеся, закрученные вихри белесого тумана
uniform vec4 fog_color : source_color = vec4(0.92, 0.94, 0.97, 0.82);
uniform float fog_density : hint_range(0.0, 1.0) = 0.70;
uniform float fog_speed : hint_range(0.001, 0.1) = 0.007; // Медленный плавный перекат тумана
uniform float fog_scale : hint_range(0.1, 4.0) = 0.75;
uniform vec2 world_offset = vec2(0.0, 0.0);
uniform vec2 view_size = vec2(640.0, 360.0);

vec2 hash(vec2 p) {
	p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
	return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(dot(hash(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
	               dot(hash(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
	           mix(dot(hash(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
	               dot(hash(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	mat2 rot = mat2(vec2(0.8, 0.6), vec2(-0.6, 0.8));
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = rot * p * 2.02 + vec2(23.1, 17.4);
		a *= 0.5;
	}
	return v;
}

// Domain warping для создания клубящихся вихрей и мягких языков тумана
float domain_warp(vec2 p, float t) {
	vec2 q = vec2(
		fbm(p + vec2(t * 0.9, t * 0.3)),
		fbm(p + vec2(1.7, 9.2) - vec2(t * 0.6, t * 0.8))
	);
	
	vec2 r = vec2(
		fbm(p + 2.8 * q + vec2(8.3, 2.8) + vec2(t * 0.5, -t * 0.4)),
		fbm(p + 2.8 * q + vec2(3.2, 7.5) - vec2(t * 0.4, t * 0.6))
	);
	
	return fbm(p + 3.2 * r);
}

void fragment() {
	// Привязка к мировым координатам: туман стелется по земле острова
	vec2 world_pos = world_offset + (UV - 0.5) * view_size;
	vec2 p = (world_pos / 240.0) * fog_scale;
	
	float t = TIME * fog_speed;
	
	// Медленный общий снос тумана
	vec2 drift = vec2(-t * 2.8, sin(t * 1.8) * 0.6);
	
	// Клубящийся объемный туман с турбулентностью
	float f = domain_warp(p + drift, t);
	
	// Мягкие переходы и плотные клубы
	float mist = smoothstep(-0.28, 0.52, f);
	
	// Легкий фоновый слой дымки
	float haze = smoothstep(-0.35, 0.35, fbm(p * 0.55 + vec2(-t * 1.5, t * 0.9))) * 0.32;
	
	float density = clamp((mist * 0.88 + haze) * fog_density, 0.0, 1.0);
	
	// Цвет тумана: мягкий светлый белесо-серый туман (без темноты!)
	vec3 col = fog_color.rgb;
	// Мягкое высветление в самых густых клубах тумана
	col = mix(col, vec3(0.98, 0.99, 1.0), smoothstep(0.45, 0.85, density) * 0.35);
	
	COLOR = vec4(col, density * fog_color.a);
}
