shader_type canvas_item;

uniform float wave_speed = 1.5;
uniform float wave_freq = 0.05;
uniform float wave_amp = 1.5;

void vertex() {
    // Плавно двигаем вершины тайлов воды, создавая эффект покачивания волн.
    // Это не ломает атлас тайлов (в отличие от искажения UV).
    VERTEX.y += sin(VERTEX.x * wave_freq + TIME * wave_speed) * wave_amp;
    VERTEX.x += cos(VERTEX.y * wave_freq + TIME * wave_speed) * wave_amp;
}
