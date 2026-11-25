// ===== СЕКРЕТНАЯ ДВЕРЬ В ПЕКАРНЕ (DRAW) =====

draw_self();

// Знак прежнего владельца Меча героя — такой же, как на большом камне в лесу (только в пекарне).
// До разговора с лягушонком — едва заметная резьба, после — светится.
if (room == rm_bakery) {
    forest_episode_init();
    var _sa = global.frog_talk_done ? 0.55 + 0.35 * sin(current_time / 300) : 0.22;
    forest_draw_sign(x + 16, y + 18, _sa);
}

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _p       = instance_find(obj_max, 0);
        var _foot_cx = (_p.bbox_left + _p.bbox_right) * 0.5;
        var _foot_y  = _p.bbox_bottom;
        if (point_distance(x, y, _foot_cx, _foot_y) < 120) {
            var _has_key = (room == rm_bakery) && variable_global_exists("has_secret_key") && global.has_secret_key;
            var _opened  = variable_global_exists("secret_room_opened") && global.secret_room_opened;
            var _hint = !_has_key ? "[E] Открыть" : (_opened ? "[E] Войти" : "[E] Открыть ключом");
            draw_hint(_hint, x, y - 32, true);
        }
    }
}
