precision highp float;

varying vec2 v_coords;
uniform vec2 size;        // Разрешение экрана
uniform float alpha;      // Прозрачность
uniform vec2 u_camera;    // Смещение камеры
uniform float u_time;     // Время

// Коэффициент параллакса: чем меньше значение, тем дальше кажется фон
const float PARALLAX_FACTOR = 0.3333;

// Простой шум для текстуры кирпича
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void main() {
    // 1. НАСТРОЙКИ РАЗМЕРА КИРПИЧЕЙ (в пикселях)
    float brickW = 120.0;
    float brickH = 60.0;
    float mortar = 4.0;   // Толщина шва
    
    vec2 brick_size = vec2(brickW, brickH);

    // 2. РАСЧЕТ ПАРАЛЛАКСА
    vec2 parallax_camera = u_camera * PARALLAX_FACTOR;
    
    // Вычисляем позицию пикселя без зацикливания, чтобы стена была бесконечно уникальной
    vec2 pixelPos = (v_coords * size) + parallax_camera;
    
    // Переводим пиксели в пространство бесконечных "тайлов"
    vec2 tile_uv = pixelPos / brick_size;

    // 3. СЕТКА КИРПИЧЕЙ (используем tile_uv напрямую)
    float row = floor(tile_uv.y);
    float isOddRow = step(1.0, mod(row, 2.0)); 
    float offset = isOddRow * 0.5;
    
    // Координаты внутри одного кирпича (0.0 -> 1.0)
    vec2 brickUV = fract(vec2(tile_uv.x + offset, tile_uv.y));

    // 4. ОПРЕДЕЛЯЕМ ШОВ ИЛИ КИРПИЧ
    vec2 mortarScale = vec2(mortar / brickW, mortar / brickH);
    vec2 isBrickStep = step(mortarScale, brickUV) * step(mortarScale, 1.0 - brickUV);
    float isBrick = isBrickStep.x * isBrickStep.y;

    // 5. ЦВЕТА И ТЕКСТУРА
    vec3 brickBase = vec3(0.65, 0.30, 0.20);
    
    // Вычисляем индекс конкретного кирпича на основе глобальных координат
    vec2 gridIdx = floor(vec2(tile_uv.x + offset, tile_uv.y));
    float noiseVal = hash(gridIdx);

    // Вариация цвета (увеличил множитель с 0.1 до 0.15 для чуть большей заметности, можешь менять под себя)
    vec3 brickColor = brickBase + (noiseVal - 0.5) * 0.15;
    vec3 mortarColor = vec3(0.45, 0.45, 0.42);
    
    // Смешиваем шов и кирпич
    vec3 color = mix(mortarColor, brickColor, isBrick);

    // 6. ВИНЬЕТКА
    float vignette = 1.0 - length(v_coords - 0.5) * 0.4;
    color *= vignette;

    // Вывод итогового цвета
    gl_FragColor = vec4(color, 1.0) * alpha;
}
