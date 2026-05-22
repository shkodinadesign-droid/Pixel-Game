// ===== OBJ_FRIDGE DRAW =====
draw_self();

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _fx   = (bbox_left + bbox_right) / 2;
        var _fy   = (bbox_top  + bbox_bottom) / 2;
        var _dist = point_distance(_fx, _fy, obj_max.x, obj_max.y);
        if (_dist < 96) {
            draw_hint("[E] Открыть", _fx, bbox_top - 6, true);
        }
    }
}
