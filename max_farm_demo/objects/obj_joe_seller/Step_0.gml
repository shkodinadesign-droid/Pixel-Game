// ===== ФЕРМЕР ДЖО — ПРОДАВЕЦ (STEP) =====
// Первая встреча: Макс подошла к Джо — он сам начинает разговор
if (shop_state == 0 && !variable_global_get(first_visit_key)
&&  !global.control_locked && instance_exists(obj_max)
&&  point_distance(x, y, obj_max.x + 16, obj_max.y + 48) < 72) {
    shop_state = 1;
    global.control_locked = true;
    variable_global_set(first_visit_key, true);
}
event_inherited();
