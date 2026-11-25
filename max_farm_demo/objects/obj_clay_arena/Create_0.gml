// ===== ПЕРВОЕ ИСПЫТАНИЕ — ГЛИНЯНЫЙ СТРАЖ (CREATE) =====
// Вид сбоку, арена целиком на экране (960x540): ровный пол для уклонений, каменные уступы, закрытый выход
// наверху справа. Удары по стражу не нужны — победа, когда Макс поднимается на верхнюю площадку после трёх фаз:
//   1) катящийся шар: раскрутка (гул, сыплется земля) -> катится по прямой -> удар о стену, пауза. 3 проката.
//   2) каменный дождь: тень + струйка крошки -> камень. 3 волны. Две глыбы остаются — ступени наверх.
//   3) поднимающаяся глина: по глыбам и уступам наверх, пока глина поднимается.
// Попадание = короткий сброс ТЕКУЩЕЙ фазы (пройденные не повторяются, диалоги тоже). Время суток стоит.
side_room_begin();
F = 480;                        // пол
WALL_L = 32; WALL_R = 928;

// --- поверхности ---
side_solid(0, 0, 960, 24, "stone");                 // потолок
side_solid(0, F, 960, 540, "floor");                // пол — коричневая земля
side_solid(0, 24, WALL_L, 400, "stone");            // левая стена (проём 400..480 — вход)
side_solid(WALL_R, 24, 960, 96, "stone");           // правая стена над выходом
side_solid(WALL_R, 160, 960, F, "stone");           // правая стена под площадкой
side_solid(130, 400, 250, 414, "ledge", true);      // L1 — укрыться от шара
side_solid(700, 400, 820, 414, "ledge", true);      // L2
side_solid(400, 360, 500, 374, "ledge", true);      // M1 — дальше путь наверх
side_solid(560, 288, 660, 302, "ledge", true);      // M2
side_solid(700, 216, 790, 230, "ledge", true);      // M3
side_solid(820, 144, WALL_R, 160, "ledge", true);   // верхняя площадка у выхода
exit_block = global.trial1_done ? noone : side_solid(WALL_R, 96, 960, 144, "barrier");   // закрытый выход
slab       = noone;                                  // перегородка за спиной (опускается при входе)
slab_k     = 0;
stay_rocks = [];                                     // глыбы-ступени (фаза 2)
B1_X = 358; B2_X = 600; ROCK_W = 52; ROCK_H = 44;
if (global.trial1_done) {                            // после победы арена безопасна, ступени на месте
    array_push(stay_rocks, side_solid(B1_X - ROCK_W / 2, F - ROCK_H, B1_X + ROCK_W / 2, F, "rock"));
    array_push(stay_rocks, side_solid(B2_X - ROCK_W / 2, F - ROCK_H, B2_X + ROCK_W / 2, F, "rock"));
}

// --- Макс: из прохода слева, в проёме ---
global.side_spawn = "";
max_side = instance_create_depth(8, F - SIDE_BH, -100, obj_max_side);

// --- страж ---
gx = 480; gr = 44;               // центр по x, радиус (стоя — 44, шаром — 28)
g_ang = 0; g_eye = 0; g_arm = 0; g_arm_up = 0; g_mood = "angry";
g_shake = 0;

state = global.trial1_done ? "done" : "enter";
t = 0;
// фаза 1
roll_i = 0; sub = ""; dir = -1;
ROLL_SPD  = [3.4, 4.0, 5.0];
SPIN_TIME = [100, 90, 80];
// фаза 2
wave_i = 0; rocks = []; wave_sched = []; wave_t = 0; wave_wait = 0;
// фаза 3
clay_y = F; clay_delay = 0;
CLAY_TOP = 156; CLAY_SPD = 0.3;
// общие
hit_t = 0; inv_t = 0; retry_t = 0; banner_t = 0; shake = 0; parts = [];
if (!variable_global_exists("hearts_max") || global.hearts_max <= 0) { global.hearts_max = 3; }   // сироп лягушонка — 3 сердечка
global.hearts = global.hearts_max;
exit_warn_cd = 0;
unlock_wait = 3;
leaving = false;
light_surf = -1; flick = 0;
cave_backdrop_init();
cave_fx_init();
snd_amb = audio_play_sound(snd_cave_ambience, 0, true, 0);
audio_sound_gain(snd_amb, 0.45, 1500);
depth = 1000;

// ---------- помощники ----------
/// частицы земли/камня
add_parts = function(_x, _y, _n, _col, _spd) {
    repeat (_n) array_push(parts, { x: _x, y: _y, vx: random_range(-_spd, _spd), vy: random_range(-_spd * 1.4, -0.5), life: irandom_range(20, 40), c: _col });
};
max_cx = function() { return max_side.x + SIDE_BW * 0.5; };
/// попадание по Макс: минус сердечко и короткая неуязвимость; сердечки кончились — сброс текущей фазы.
/// _reset = true — сразу сброс (глина накрыла)
hurt = function(_reset = false) {
    if (hit_t > 0 || (inv_t > 0 && !_reset)) return;
    shake = 6;
    if (!_reset) {
        global.hearts = max(0, global.hearts - 1);
        inv_t = 80; max_side.hurt_t = 80;
        max_side.vsp = -4;                                   // лёгкий отскок
        audio_play_sound(snd_rock_land, 0, false);
    }
    if (_reset || global.hearts <= 0) {
        hit_t = 1;
        max_side.frozen = true;
        max_side.hurt_t = 60;
    }
};
place_max = function(_x) {
    max_side.x = _x; max_side.y = F - SIDE_BH; max_side.vsp = 0; max_side.hsp = 0;
};
/// --- фаза 1 ---
start_p1 = function() {
    state = "p1"; roll_i = 0; sub = "spin"; t = 0; dir = -1;
    gx = WALL_R - 28; gr = 28; g_eye = 0; g_arm = 0;
    audio_play_sound(snd_clay_rumble, 0, false);
};
/// --- фаза 2 ---
start_p2 = function() {
    state = "p2"; wave_i = 0; t = 0;
    gx = WALL_L + 42; gr = 40; g_eye = 1; g_arm = 1; g_mood = "angry";
    for (var i = 0; i < array_length(stay_rocks); i++) instance_destroy(stay_rocks[i]);
    stay_rocks = [];
    start_wave();
};
start_wave = function() {
    rocks = []; wave_sched = []; wave_t = -50; wave_wait = 0;   // сначала удар по земле (-50..0)
    var _w = wave_i;
    if (_w == 0) {           // отдельные камни — туда, где стоит Макс
        for (var i = 0; i < 4; i++) array_push(wave_sched, { at: i * 75, x: -1, warn: 60, stay: false });
    } else if (_w == 1) {    // друг за другом вдоль арены, слева направо
        for (var i = 0; i < 10; i++) { var _x = 120 + i * 80; array_push(wave_sched, { at: i * 14, x: _x, warn: 55, stay: (_x == B2_X) }); }
    } else {                 // почти одновременно, свободный промежуток виден заранее (486..654)
        var _xs = [150, 250, B1_X, 460, 680, 780, 870];
        for (var i = 0; i < array_length(_xs); i++) array_push(wave_sched, { at: i * 3, x: _xs[i], warn: 80, stay: (_xs[i] == B1_X) });
    }
};
/// --- фаза 3 ---
start_p3 = function() {
    state = "p3"; clay_y = F; clay_delay = 70; t = 0;
    g_arm_up = 0;
    place_max(233);                 // подъём всегда с пола — первая глыба рядом
};
/// --- победа: флаги, плашка, проходы открыты, арена безопасна ---
finish_win = function() {
    global.trial1_done    = true;
    global.diary_has_new  = true;
    global.diary_was_read = false;
    state = "done"; banner_t = 240; shake = 4;
    if (instance_exists(slab)) instance_destroy(slab);
    slab = noone; slab_k = 0;
    if (instance_exists(exit_block)) instance_destroy(exit_block);
    exit_block = noone;
    audio_play_sound(snd_stone_slide, 0, false);
};
