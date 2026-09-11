shader_type canvas_item;

// Единый шейдер пиксельного освещения (Pixel-art Cel-shaded Lighting)
// Создает аутентичный круговой ступенчатый свет с пикселизацией и спадом без квадратных артефактов

uniform vec4 light_color : source_color = vec4(1.0, 0.95, 0.85, 1.0);
uniform float energy : hint_range(0.0, 5.0) = 1.0;
uniform float pixel_size : hint_range(1.0, 16.0) = 2.0;
uniform int bands : hint_range(1, 8) = 4;
uniform float falloff : hint_range(0.1, 4.0) = 1.3;

void fragment() {
    vec2 pixel_grid = vec2(pixel_size) * TEXTURE_PIXEL_SIZE;
    vec2 blocky_uv = floor(UV / pixel_grid) * pixel_grid + (pixel_grid * 0.5);
    vec2 delta = blocky_uv - vec2(0.5);
    
    float dist = length(delta) * 2.0;
    
    if (dist >= 1.0) {
        discard;
    }
    
    float raw_intensity = clamp(1.0 - pow(dist, falloff), 0.0, 1.0);
    float stepped = ceil(raw_intensity * float(bands)) / float(bands);
    
    COLOR = vec4(light_color.rgb * energy, stepped * light_color.a);
}
