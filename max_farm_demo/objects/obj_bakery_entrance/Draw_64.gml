if (!instance_exists(obj_max)) exit;
if (variable_global_exists("control_locked") && global.control_locked) exit;

var _p = instance_find(obj_max, 0);
var _foot_cx = (_p.bbox_left + _p.bbox_right) * 0.5;
var _foot_y  = _p.bbox_bottom;
if (point_distance(x, y, _foot_cx, _foot_y) >= 120) exit;

var _cam = camera_get_active();
var _gx = (x - camera_get_view_x(_cam)) / camera_get_view_width(_cam) * display_get_gui_width();
var _gy = (y - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height() - 24;
draw_hint("[E] Войти в пекарню", _gx, _gy, true);
