// ===== АТМОСФЕРА: ДОЖДЬ, ЗВУКИ ЛЕСА (CREATE) =====
// Один постоянный объект, создаётся obj_day_controller (Create).
// Дождь: весь 3-й день и до утра 4-го (пока идёт ночная сцена с лягушонком) — см. ambience_rain_on() в Step.
// Лес (rm_forest_entrance): всегда тихие сверчки и еле слышный шум леса + несколько светлячков.
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

// --- светлячки в лесу (мировые координаты задаются при входе в комнату) ---
flies = [];
flies_room = -1;

// --- зацикленные звуки ---
// Каждый: ресурс, id воспроизведения, целевая громкость
amb = [
    { snd: snd_rain,            id: -1, tgt: 0 },
    { snd: snd_night_crickets,  id: -1, tgt: 0 },
    { snd: snd_forest_ambience, id: -1, tgt: 0 }
];
