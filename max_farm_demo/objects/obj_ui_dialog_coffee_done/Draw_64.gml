// ===== ДИАЛОГ: КОФЕ ГОТОВ (DRAW GUI) =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
cup_anim++;

// Фон и рамка диалога
draw_set_color(c_black);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, false);
draw_set_color(speaker_col);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, true);

// ==============================================
// КРУЖКА С КОФЕ (левая часть диалога)
// ==============================================
var _cx = win_x + 52;
var _cy = win_y + win_h / 2 + 4;

// Пар над кружкой
var _t = cup_anim * 0.06;
for (var _si = 0; _si < 3; _si++) {
    var _sx    = _cx - 10 + _si * 10;
    var _alpha = 0.25 + sin(_t + _si * 1.8) * 0.15;
    draw_set_alpha(max(0, _alpha));
    draw_set_color(make_color_rgb(200, 200, 215));
    for (var _sh = 0; _sh < 4; _sh++) {
        var _sway = sin(_t * 1.4 + _si + _sh * 0.8) * 2.5;
        draw_circle(_sx + _sway, _cy - 22 - _sh * 6, 2, false);
    }
}
draw_set_alpha(1);

// Блюдце
draw_set_color(make_color_rgb(220, 200, 165));
draw_ellipse(_cx - 24, _cy + 16, _cx + 24, _cy + 22, false);
draw_set_color(make_color_rgb(160, 130, 85));
draw_ellipse(_cx - 24, _cy + 16, _cx + 24, _cy + 22, true);

// Тело кружки
draw_set_color(make_color_rgb(240, 228, 208));
draw_roundrect_ext(_cx - 18, _cy - 16, _cx + 18, _cy + 16, 4, 4, false);
draw_set_color(make_color_rgb(170, 135, 85));
draw_roundrect_ext(_cx - 18, _cy - 16, _cx + 18, _cy + 16, 4, 4, true);

// Ручка
draw_set_color(make_color_rgb(200, 165, 105));
draw_ellipse(_cx + 14, _cy - 8, _cx + 28, _cy + 8, true);
draw_set_color(make_color_rgb(240, 228, 208));
draw_ellipse(_cx + 16, _cy - 5, _cx + 25, _cy + 5, true);

// Кофе внутри (тёмная полоска сверху)
draw_set_color(make_color_rgb(90, 52, 18));
draw_rectangle(_cx - 16, _cy - 13, _cx + 16, _cy - 7, false);
draw_set_color(make_color_rgb(60, 35, 10));
draw_ellipse(_cx - 16, _cy - 15, _cx + 16, _cy - 9, false);

// ==============================================
// ТЕКСТ (правее кружки)
// ==============================================
var tx = win_x + 100;
var ty = win_y + pad;

draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(speaker_col);
draw_text(tx, ty, speaker);
ty += line_h * 1.5;

draw_set_color(c_white);
if (line1 != "") { draw_text(tx, ty, line1); ty += line_h; }
if (line2 != "") { draw_text(tx, ty, line2); }

// ==============================================
// КНОПКА "ДАЛЕЕ"
// ==============================================
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

draw_set_color(hover ? c_white : c_black);
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);
draw_set_color(speaker_col);
draw_line(btn_x1+1, btn_y1, btn_x2-1, btn_y1);
draw_line(btn_x1+1, btn_y2, btn_x2-1, btn_y2);
draw_line(btn_x1+1, btn_y1, btn_x1+1, btn_y2);
draw_line(btn_x2-1, btn_y1, btn_x2-1, btn_y2);

draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(hover ? c_black : c_white);
draw_text((btn_x1+btn_x2)/2, (btn_y1+btn_y2)/2, btn_label);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
