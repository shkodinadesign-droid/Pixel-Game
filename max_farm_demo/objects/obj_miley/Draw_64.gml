// === МАЙЛИ — ДИАЛОГ (DRAW GUI) ===
if (!dlg_show || room != rm_farm) exit;

var _gui_w  = display_get_gui_width();
var _win_w  = 600;
var _pad    = 14;
var _line_h = 24;
var _win_x  = (_gui_w - _win_w) / 2;
var _win_y  = 20;
var _btn_w  = 120;
var _btn_h  = 30;

// Контент по шагам
var _speaker = "";
var _sp_col  = c_white;
var _line1   = "";
var _line2   = "";
var _btn_lbl = "Далее";

switch (dlg_step) {
    case 1:
        _speaker = "Майли:";
        _sp_col  = dlg_miley_col;
        _line1   = "Добрый день! А где бабушка?";
        _line2   = "Я пришла за любимым ароматным кофе =)";
        break;
    case 2:
        _speaker = "Макс:";
        _sp_col  = dlg_max_col;
        _line1   = "Я помогаю бабушке по хозяйству — могу сварить вам чашечку!";
        _line2   = "";
        break;
    case 3:
        _speaker = "Майли:";
        _sp_col  = dlg_miley_col;
        _line1   = "Хорошо! Буду рада =)";
        _line2   = "";
        break;
    case 4:
        _speaker = "Майли:";
        _sp_col  = dlg_miley_col;
        _line1   = "Это очень вкусно! Спасибо!";
        _line2   = "Завтра я приду снова =)";
        _btn_lbl = "Пока!";
        break;
}

var _lines = (_line2 != "") ? 2 : 1;
var _win_h  = 50 + _lines * _line_h + 50;
var _btn_x1 = _win_x + _win_w - _btn_w - _pad;
var _btn_y1 = _win_y + _win_h - _btn_h - _pad;
var _btn_x2 = _btn_x1 + _btn_w;
var _btn_y2 = _btn_y1 + _btn_h;

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон и рамка
draw_set_color(c_black);
draw_roundrect_ext(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, 12, 12, false);
draw_set_color(_sp_col);
draw_roundrect_ext(_win_x, _win_y, _win_x + _win_w, _win_y + _win_h, 12, 12, true);

// Иконка: кружка кофе (левая часть)
var _cx = _win_x + 52;
var _cy = _win_y + _win_h / 2 + 4;
draw_set_color(make_color_rgb(220, 200, 165));
draw_ellipse(_cx - 24, _cy + 16, _cx + 24, _cy + 22, false);
draw_set_color(make_color_rgb(240, 228, 208));
draw_roundrect_ext(_cx - 18, _cy - 16, _cx + 18, _cy + 16, 4, 4, false);
draw_set_color(make_color_rgb(200, 165, 105));
draw_ellipse(_cx + 14, _cy - 8, _cx + 28, _cy + 8, true);
draw_set_color(make_color_rgb(240, 228, 208));
draw_ellipse(_cx + 16, _cy - 5, _cx + 25, _cy + 5, true);
draw_set_color(make_color_rgb(90, 52, 18));
draw_rectangle(_cx - 16, _cy - 13, _cx + 16, _cy - 7, false);
draw_set_color(make_color_rgb(60, 35, 10));
draw_ellipse(_cx - 16, _cy - 15, _cx + 16, _cy - 9, false);
// Пар
draw_set_color(make_color_rgb(200, 200, 215));
draw_set_alpha(0.35);
draw_circle(_cx - 5, _cy - 22, 3, false);
draw_circle(_cx + 5, _cy - 26, 2, false);
draw_set_alpha(1);

// Текст
var _tx = _win_x + 100;
var _ty = _win_y + _pad;
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_sp_col);
draw_text(_tx, _ty, _speaker);
_ty += _line_h * 1.5;
draw_set_color(c_white);
if (_line1 != "") { draw_text_ext(_tx, _ty, _line1, -1, _win_w - 120); _ty += _line_h; }
if (_line2 != "") { draw_text_ext(_tx, _ty, _line2, -1, _win_w - 120); }

// Кнопка
var _mx  = device_mouse_x_to_gui(0);
var _my  = device_mouse_y_to_gui(0);
var _hov = (_mx >= _btn_x1 && _mx <= _btn_x2 && _my >= _btn_y1 && _my <= _btn_y2);
draw_set_color(_hov ? c_white : c_black);
draw_rectangle(_btn_x1, _btn_y1, _btn_x2, _btn_y2, false);
draw_set_color(_sp_col);
draw_line(_btn_x1+1, _btn_y1, _btn_x2-1, _btn_y1);
draw_line(_btn_x1+1, _btn_y2, _btn_x2-1, _btn_y2);
draw_line(_btn_x1+1, _btn_y1, _btn_x1+1, _btn_y2);
draw_line(_btn_x2-1, _btn_y1, _btn_x2-1, _btn_y2);
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_hov ? c_black : c_white);
draw_text((_btn_x1+_btn_x2)/2, (_btn_y1+_btn_y2)/2, _btn_lbl);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
