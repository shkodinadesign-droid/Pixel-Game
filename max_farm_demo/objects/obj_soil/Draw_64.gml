if (!instance_exists(obj_max)) exit;
if (variable_global_exists("control_locked") && global.control_locked) exit;

var _p = instance_find(obj_max, 0);
if (point_distance(x, y, _p.x, _p.y) > 64) exit;

var _hint = "";
if (!dug && _p.selected_shovel) {
    _hint = "[E] Вскопать";
} else if (dug && !watered && _p.selected_watering_can) {
    _hint = "[E] Полить";
} else if (dug && !has_seed && _p.selected_seed != "") {
    _hint = "[E] Посадить";
}
if (_hint == "") exit;

var _cam = camera_get_active();
var _gx = (x - camera_get_view_x(_cam)) / camera_get_view_width(_cam) * display_get_gui_width();
var _gy = (y - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height() - 24;
draw_hint(_hint, _gx, _gy, true);
