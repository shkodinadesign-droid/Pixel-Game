if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _p       = instance_find(obj_max, 0);
        var _foot_cx = (_p.bbox_left + _p.bbox_right) * 0.5;
        var _foot_y  = _p.bbox_bottom;
        if (point_distance(x, y, _foot_cx, _foot_y) < 96) {
            draw_hint("[E] На ферму", _foot_cx, _p.bbox_top - 6, true);
        }
    }
}
