// ===== ФЕРМЕР ДЖО — ПРОДАВЕЦ (STEP) =====
// После зелёной тетради: E у Джо — разговор о пещере и Мече героя (один раз), потом снова магазин
forest_episode_init();
cave_talk_ready = global.secret_room_opened && !global.jack_cave_talk_done;
cave_talk_near  = cave_talk_ready && shop_state == 0 && !global.control_locked && instance_exists(obj_max)
               && point_distance(x, y, obj_max.x, obj_max.y) < talk_radius;
if (cave_talk_near && keyboard_check_pressed(ord("E"))) {
    variable_global_set(first_visit_key, true);
    forest_on_dialog_finished("jack_cave_talk");
    exit;
}
// Первая встреча: Макс подошла к Джо — он сам начинает разговор
if (shop_state == 0 && !variable_global_get(first_visit_key)
&&  !global.control_locked && instance_exists(obj_max)
&&  point_distance(x, y, obj_max.x + 16, obj_max.y + 48) < 72) {
    shop_state = 1;
    global.control_locked = true;
    variable_global_set(first_visit_key, true);
}
event_inherited();
