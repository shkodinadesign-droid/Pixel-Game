if (global.pudding_on_porch) exit;
if (!variable_global_exists("pudding_ready") || !global.pudding_ready) exit;
if (!instance_exists(obj_max)) exit;
if (point_distance(x, y, obj_max.x, obj_max.y) >= 36) exit;

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();
var _vx = camera_get_view_x(view_camera[0]);
var _vy = camera_get_view_y(view_camera[0]);
var _vw = camera_get_view_width(view_camera[0]);
var _vh = camera_get_view_height(view_camera[0]);
var _sx = (x - _vx) * (_gui_w / _vw);
var _sy = (y - _vy) * (_gui_h / _vh);

var _pw = 210; var _ph = 28;
var _px = _sx - _pw / 2;
var _py = _sy - 44;

draw_set_alpha(0.88);
draw_set_color(c_black);
draw_roundrect_ext(_px, _py, _px + _pw, _py + _ph, 6, 6, false);
draw_set_alpha(1);
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(_px + _pw / 2, _py + _ph / 2, "[E]  Положить пуддинг");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
