// ===== СЕКРЕТНАЯ ДВЕРЬ В ПЕКАРНЕ (DRAW) =====

draw_self();

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _p       = instance_find(obj_max, 0);
        var _foot_cx = (_p.bbox_left + _p.bbox_right) * 0.5;
        var _foot_y  = _p.bbox_bottom;
        if (point_distance(x, y, _foot_cx, _foot_y) < 120) {
            var _has_key = variable_global_exists("has_secret_key") && global.has_secret_key;
            var _hint = _has_key ? "[E] Открыть дверь" : "[E] Открыть";
            draw_hint(_hint, x, y - 32, true);
        }
    }
}
