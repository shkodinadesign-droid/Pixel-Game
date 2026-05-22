// ===== JUSTIN DAY 2 — CREATE =====
// Сцена: Джастин приходит за пирогом на 2-й день

if (!variable_global_exists("potato_pie_done"))  global.potato_pie_done  = false;
if (!variable_global_exists("justin_day2_done")) global.justin_day2_done = false;

var _day = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 1;

// Уничтожаем если условия не выполнены
if (global.justin_day2_done || !global.potato_pie_done || _day < 2) {
    instance_destroy();
    exit;
}

sprite_index = spr_justin_idle_down;
image_speed  = 0;
image_index  = 0;
visible      = false;

cscene_step = 0;
entry_timer = -1;   // таймер 5 сек (300 кадров) — стартует когда Макс в комнате
walk_spd    = 2;

// Путевые точки входа (обход стульев)
wp1_x = 220; wp1_y = 570; wp1_reached = false;
wp2_x = 220; wp2_y = 380; wp2_reached = false;
counter_x = 160; counter_y = 356;

// Путевые точки выхода
leave_wp1_x = 220; leave_wp1_y = 380; leave_wp1_done = false;
leave_wp2_x = 220; leave_wp2_y = 570; leave_wp2_done = false;

// Анимация передачи пирога (круг летит от Макс к Джастину)
pie_anim_t  = -1;
pie_start_x = 0; pie_start_y = 0;
pie_end_x   = 0; pie_end_y   = 0;

depth = -bbox_bottom;
