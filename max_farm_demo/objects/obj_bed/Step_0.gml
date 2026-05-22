// === КРОВАТЬ (STEP) ===

var cx = x;
var cy = bbox_top - 16;

// Игрок рядом?
var p = instance_nearest(cx, cy, obj_max);
var near = (p != noone) && (point_distance(cx, cy, p.x, p.y) <= 32);

// Можно ли спать? (только вечером/ночью)
var can_sleep = false;
if (instance_exists(obj_day_controller)) {
    can_sleep = (obj_day_controller.hour >= 18);
}

// Флаги для Draw
show_sleep_hint = near;
sleep_available = can_sleep;

// Запуск сна
if (near && can_sleep && keyboard_check_pressed(ord("E"))) {
    if (instance_exists(obj_day_controller)) {
        obj_day_controller.day_go_to_sleep();
    }
}
