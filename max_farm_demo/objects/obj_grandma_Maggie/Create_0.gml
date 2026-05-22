// =====================
// MEGGI (CREATE)
// =====================

visible = true;
image_speed = 0;
image_blend = c_white;
image_alpha = 1;
sprite_index = spr_maggie_idle_up;

// Глобальный флаг: показывали ли уже встречу с Мэгги
if (!variable_global_exists("meggi_intro_done")) {
    global.meggi_intro_done = false;
}

// Состояния:
// "appearing" - появляется, Макс поворачивается
// "waiting_for_max" - ждёт пока Макс повернётся
// "walking_to_player" - идёт к Максу
// "talking" - диалог
// "leaving" - уходит
// "idle" - стоит
state = "appearing";

// Таймер для этапов
wait_timer = 0;

// Блокируем управление
if (!variable_global_exists("control_locked")) global.control_locked = false;
global.control_locked = true;

// Останавливаем Макса сразу
if (instance_exists(obj_max)) {
    obj_max.image_speed = 0;
    obj_max.image_index = 0;
    obj_max.state = "idle";
}

// Скорость движения
move_speed = 1.5;

// Фаза ухода
leave_phase = 0;

// Цель (позиция игрока)
target_x = x;
target_y = y;

// Вход слева (со стороны сарая)
x = -60;
y = 300;

// Если intro уже было - удаляемся
if (global.meggi_intro_done) {
    global.control_locked = false;
    instance_destroy();
}
