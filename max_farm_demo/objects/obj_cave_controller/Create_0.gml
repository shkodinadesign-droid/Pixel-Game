// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (CREATE) =====
// Вид сбоку. Вход слева (из леса). Фонарь на каменном выступе у входа -> безопасные уступы, чтобы освоить
// прыжок -> проход расширяется, в свете фонаря — хранитель меча -> он ударяет посохом, перегородка уходит
// в землю -> справа переход на арену первого испытания (rm_cave_arena).
// Цвета тёмные с приглушённым фиолетовым (как тайная комната Сони), пылинки, капли, глухой сквозняк.
side_room_begin();
FLOOR_Y   = 470;
LANTERN_X = 266;            // фонарь на выступе
KEEPER_X  = 1480;           // хранитель
BARRIER_X = 1660;

// --- поверхности ---
side_solid(0, 0, 1100, 150, "stone");         // низкий потолок у входа
side_solid(1100, 0, 1920, 70, "stone");       // дальше проход расширяется
side_solid(0, FLOOR_Y, 1920, 540, "floor");   // пол — коричневая земля
side_solid(232, 420, 300, 432, "ledge", true);   // выступ с фонарём
side_solid(520, 430, 580, FLOOR_Y, "rock");      // ступенька — первый прыжок
side_solid(620, 394, 740, 406, "ledge", true);   // уступ — попробовать запрыгнуть
side_solid(800, 440, 850, FLOOR_Y, "rock");
barrier = global.keeper_talk_done ? noone : side_solid(BARRIER_X, 70, BARRIER_X + 60, FLOOR_Y, "barrier");
barrier_sink = 0;

// --- Макс: вошла из тайного леса (слева) или вернулась с арены (справа) ---
var _from_arena = (variable_global_exists("side_spawn") && global.side_spawn == "right");
global.side_spawn = "";
max_side = instance_create_depth(_from_arena ? 1880 : 70, FLOOR_Y - SIDE_BH, -100, obj_max_side);
if (_from_arena) max_side.facing = -1;

lantern_glow = global.has_lantern ? 1 : 0;   // 0..1 — фонарь разгорается после подбора
lantern_near = false;
keeper_state = global.keeper_talk_done ? "gone" : "wait";   // wait -> talk -> strike -> gone
keeper_t     = 0;
keeper_alpha = 0;
keeper_dx    = 0;
flash        = 0;
shake        = 0;
first_enter  = !global.cave_entered;
enter_wait   = 30;
dark_warn_cd = 0;
unlock_wait  = 3;          // переход из леса блокирует управление — снимаем сами
leaving      = false;
light_surf   = -1;
flick        = 0;
cave_backdrop_init();
cave_fx_init();
snd_amb = audio_play_sound(snd_cave_ambience, 0, true, 0);
audio_sound_gain(snd_amb, 0.5, 1500);
depth = 1000;              // фон и поверхности — под всеми; свет и эффекты — Draw End
