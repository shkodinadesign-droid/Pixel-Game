// ===== ТОБИ (DRAW GUI) — окно диалога с говорящим портретом =====
var _ln;
if (state == "talk")      _ln = lines[dlg_i];
else if (state == "note") _ln = note_line;
else exit;

var _gw = display_get_gui_width();
var _dx = (_gw - dlg_w) / 2;
var _bx1 = _dx + dlg_w - btn_w - dlg_pad, _by1 = dlg_y + dlg_h - btn_h - dlg_pad;
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
scr_dialog_draw_bg(_dx, dlg_y, dlg_w, dlg_h);
scr_dialog_draw_speaker(_dx, dlg_y, dlg_w, dlg_h, _ln[0]);

var _tx = _dx + 15 * (dlg_w / 580) + 8;
var _ty = scr_dialog_body_top(_dx, dlg_y, dlg_w, dlg_h);
var _ps = 72;
var _talking = ((current_time div 250) mod 2 == 0) ? 0 : 1;
if (_ln[0] == "Тоби:") scr_dialog_draw_portrait(_dx, dlg_y, dlg_w, dlg_h, _by1, spr_toby_portrait_anim, _ps, _talking);
else                   scr_dialog_draw_portrait(_dx, dlg_y, dlg_w, dlg_h, _by1, spr_max_portrait, _ps);
var _tw = (_dx + 565 * (dlg_w / 580) - 8 - _ps) - _tx - 16;

draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text_ext(_tx, _ty, _ln[1], 24, _tw);

var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _last = (state == "note") || (dlg_i == array_length(lines) - 1);
scr_dialog_draw_button(_bx1, _by1, _bx1 + btn_w, _by1 + btn_h, _last ? "Хорошо" : "Далее",
                       _mx >= _bx1 && _mx <= _bx1 + btn_w && _my >= _by1 && _my <= _by1 + btn_h);
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
