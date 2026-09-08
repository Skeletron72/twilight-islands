shader_type canvas_item;

uniform vec2 player_pos = vec2(0.0);
uniform float occlusion_amount : hint_range(0.0, 1.0) = 0.0; // Для плавной анимации (0 - нет, 1 - есть)
uniform float silhouette_darkness : hint_range(0.0, 1.0) = 0.6;
uniform float circle_alpha : hint_range(0.0, 1.0) = 0.3; // Прозрачность в самом центре (0.0 = пустота)
uniform float circle_radius = 20.0; // Уменьшенный радиус
uniform float pixel_size = 2.0;

varying vec2 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    if (occlusion_amount > 0.0 && tex_color.a > 0.0) {
        // Плавно затемняем дерево
        tex_color.rgb *= mix(1.0, silhouette_darkness, occlusion_amount); 
        
        // Пиксельные координаты для "блочных" краев круга
        vec2 blocky_world = floor(world_pos / pixel_size) * pixel_size;
        vec2 blocky_player = floor(player_pos / pixel_size) * pixel_size;
        
        // Центр на уровне тела
        blocky_player.y -= 12.0; 
        
        float dist = distance(blocky_world, blocky_player);
        
        if (dist < circle_radius) {
            // Градиент от центра (0.0) к краю (1.0)
            float gradient = dist / circle_radius;
            // Плавно переводим альфу: в центре = circle_alpha, на краю = 1.0 (обычный цвет)
            float target_alpha_mult = mix(circle_alpha, 1.0, gradient);
            
            // Плавно применяем это умножение прозрачности в зависимости от анимации (occlusion_amount)
            tex_color.a *= mix(1.0, target_alpha_mult, occlusion_amount);
        }
    }
    
    COLOR = tex_color;
}
