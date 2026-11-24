// ===== АТМОСФЕРА: ДОЖДЬ, ЗВУКИ ЛЕСА (CREATE) =====
// Один постоянный объект, создаётся obj_day_controller (Create).
// Дождь: весь день после ночи с лягушонком (обычно день 4), global.rain_day — см. Step.
// Лес (rm_forest_entrance): всегда тихие сверчки, еле слышный шум леса и летающие пылинки.
// После дождя (на следующий день) пылинки летают и на улице в деревне и на ферме.
// В огороде днём порхают две бабочки (рисуются кодом — маленькие, спрайт не нужен).
// Звуки — процедурные, tools/audio/ambience_gen.py (snd_rain, snd_night_crickets, snd_forest_ambience).

// --- капли: белые полупрозрачные чёрточки, координаты относительно камеры ---
RAIN_COUNT = 140;
RAIN_ANGLE = 254;                     // чуть наискосок (270 = строго вниз)
drops = array_create(RAIN_COUNT);
for (var i = 0; i < RAIN_COUNT; i++) {
    drops[i] = {
        x: random(1100) - 70, y: random(600) - 30,
        len: random_range(9, 18), spd: random_range(9, 13), a: random_range(0.18, 0.42)
    };
}
splashes = [];                        // маленькие всплески на земле {x, y, t}
rain_alpha = 0;                       // плавное появление/исчезновение дождя (0..1)

// --- пылинки: координаты относительно камеры, медленно дрейфуют и мерцают ---
motes = array_create(46);
for (var m = 0; m < 46; m++) {
    motes[m] = { x: random(960), y: random(540), ph: random(1000),
                 sp: random_range(0.08, 0.25), big: (random(1) < 0.2), a: random_range(0.25, 0.6) };
}
motes_alpha = 0;                      // плавное появление (0..1)

// --- бабочки над огородом (rm_farm, грядки x 128..352, y 416..576) ---
GARDEN_X1 = 110; GARDEN_X2 = 390; GARDEN_Y1 = 380; GARDEN_Y2 = 600;
butterflies = [
    { x: 180, y: 430, tx: 180, ty: 430, vx: 0, vy: 0, ph: 0,   c1: make_color_rgb(255, 250, 225), c2: make_color_rgb(240, 200, 90) },  // белая-лимонная
    { x: 300, y: 520, tx: 300, ty: 520, vx: 0, vy: 0, ph: 500, c1: make_color_rgb(245, 150, 60),  c2: make_color_rgb(120, 60, 30)  }   // рыжая
];
bfly_alpha = 0;

// --- зацикленные звуки ---
// Каждый: ресурс, id воспроизведения, целевая громкость
amb = [
    { snd: snd_rain,            id: -1, tgt: 0 },
    { snd: snd_night_crickets,  id: -1, tgt: 0 },
    { snd: snd_forest_ambience, id: -1, tgt: 0 }
];
