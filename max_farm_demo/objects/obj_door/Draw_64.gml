// ===== OBJ_DOOR DRAW GUI =====
// DrawGUI работает независимо от visible и кэша IDE

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _p   = instance_find(obj_max, 0);
        var _dist = point_distance(x, y, _p.x, _p.y);
        if (_dist < 150) {
            // Конвертируем room coords → GUI coords
            var _cam = view_camera[0];
            var _cx  = camera_get_view_x(_cam);
            var _cy  = camera_get_view_y(_cam);
            var _cw  = camera_get_view_width(_cam);
            var _ch  = camera_get_view_height(_cam);
            var _gw  = display_get_gui_width();
            var _gh  = display_get_gui_height();
            var _hx  = (x      - _cx) / _cw * _gw;
            var _hy  = (y - 16 - _cy) / _ch * _gh;
            draw_hint("[E] Войти", _hx, _hy, true);
        }
    }
}
