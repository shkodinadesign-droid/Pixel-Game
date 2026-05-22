// ===== ДИАЛОГ: УТРО ДНЯ 2 (DRAW GUI) =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон и рамка
draw_set_color(c_black);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, false);
draw_set_color(speaker_col);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, true);

// ==============================================
// ИКОНКА: ВОСХОДЯЩЕЕ СОЛНЦЕ (левая часть)
// ==============================================
var _cx = win_x + 52;
var _cy = win_y + win_h / 2;

// Горизонт
draw_set_color(make_color_rgb(180, 130, 80));
draw_rectangle(_cx - 24, _cy + 10, _cx + 24, _cy + 12, false);

// Солнечный диск
draw_set_color(make_color_rgb(255, 195, 50));
draw_ellipse(_cx - 18, _cy - 14, _cx + 18, _cy + 10, false);
draw_set_color(make_color_rgb(255, 220, 100));
draw_ellipse(_cx - 14, _cy - 10, _cx + 14, _cy + 6, false);

// Лучи (только верхняя полусфера)
draw_set_color(make_color_rgb(255, 220, 80));
for (var _r = 0; _r < 7; _r++) {
    var _angle = -150 + _r * 25;
    var _rx1 = _cx + lengthdir_x(22, _angle);
    var _ry1 = _cy - 2 + lengthdir_y(22, _angle);
    var _rx2 = _cx + lengthdir_x(30, _angle);
    var _ry2 = _cy - 2 + lengthdir_y(22, _angle) + (_ry1 - (_cy - 2 + lengthdir_y(30, _angle)));
    draw_line_width(_rx1, _ry1, _cx + lengthdir_x(30, _angle), _cy - 2 + lengthdir_y(30, _angle), 2);
}

// ==============================================
// ТЕКСТ (правее иконки)
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
if (line2 != "") { draw_text(tx, ty, line2); ty += line_h; }
if (line3 != "") { draw_text(tx, ty, line3); ty += line_h; }

// Подсказка: жёлтая, с треугольником
if (line4 != "") {
    draw_set_color(make_color_rgb(255, 220, 80));
    draw_text(tx, ty, "▸ " + line4);
}

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
