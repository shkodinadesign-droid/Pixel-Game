// ===== ТАЙНЫЙ ЛЕС (CREATE) =====
// Продолжение пути от поляны лягушонка: тёмная тропинка, сосны и много кустов, фиолетовое свечение,
// светлячки, уханье совы и шум леса (obj_ambience). На середине пути подбегает лягушонок (obj_mystic_frog).
// В конце, у верхнего края поляны, — скалы со входом в старую пещеру (obj_cave_rocks / obj_cave_entrance_door).
forest_episode_init();
owl_timer = irandom_range(240, 600);
fireflies = [];
for (var i = 0; i < 46; i++) {
    array_push(fireflies, { x: random(room_width), y: random(room_height), ph: random(1000), sp: random_range(0.2, 0.5), dir: random(360), c: choose(0, 0, 1) });
}
// пятна фиолетового свечения (грибы/мох) — в случайных местах у тропы
glows = [];
random_set_seed(77);
for (var i = 0; i < 18; i++) array_push(glows, { x: random_range(60, room_width - 60), y: random_range(120, room_height - 60), r: random_range(26, 60), ph: random(100) });
randomize();
depth = -9000;
