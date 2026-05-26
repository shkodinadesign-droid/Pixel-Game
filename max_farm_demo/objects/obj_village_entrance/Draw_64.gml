// Подсказка "E → Деревня" когда игрок рядом
if (!near_player) exit;

var _gx = device_mouse_x_to_gui(0); // просто чтоб инициализировать контекст
var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

var _lbl = "E — В деревню";
draw_set_font(fnt_dialog);
var _tw = string_width(_lbl) + 16;
var _th = string_height(_lbl) + 8;
var _tx = (_gui_w - _tw) / 2;
var _ty = _gui_h - 120;

draw_set_alpha(0.8);
draw_set_color(make_color_rgb(40, 30, 20));
draw_roundrect_ext(_tx, _ty, _tx + _tw, _ty + _th, 4, 4, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(_tx + _tw / 2, _ty + _th / 2, _lbl);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
