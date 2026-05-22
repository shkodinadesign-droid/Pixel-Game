// ===== МЭГГИ ДЕНЬ 2 — ПРИНОСИТ КОТИКА (CREATE) =====

if (!variable_global_exists("kitten_arrived"))       global.kitten_arrived       = false;
if (!variable_global_exists("maggie_day2_started"))  global.maggie_day2_started  = false;

var _day = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;

// Уничтожаем если котик уже пришёл или День 1
if (global.kitten_arrived || _day < 2) {
    instance_destroy();
    exit;
}
// Если сцена уже была запущена другим экземпляром — тоже не нужны дубли
if (global.maggie_day2_started && instance_number(obj_maggie_day2) > 1) {
    instance_destroy();
    exit;
}

persistent = true;  // выживаем при смене комнаты
global.maggie_day2_started = true;

sprite_index = spr_maggie_idle_down;
image_speed  = 0;
image_index  = 0;
visible      = false;

// Состояния: "waiting", "walking_to_player", "talking", "leaving"
state      = "waiting";
move_speed = 1.5;
wait_timer = -1;  // 5 секунд после входа Макс на ферму

target_x = x;
target_y = y;

// Ссылка на котика (создаём когда Мэгги появляется)
kitten_id = noone;

if (!variable_global_exists("control_locked")) global.control_locked = false;
