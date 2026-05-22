// ===== ДИАЛОГ-НАПОМИНАНИЕ: ПОСАДИ СЕМЕНА (DRAW GUI) =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон
draw_set_color(c_black);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, false);

// Рамка — цвет говорящего
draw_set_color(speaker_col);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, true);

var tx = win_x + pad;
var ty = win_y + pad;

// Имя говорящего
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(speaker_col);
draw_text(tx, ty, speaker);
ty += line_h * 1.5;

// Строки диалога
draw_set_color(c_white);
if (line1 != "") { draw_text(tx, ty, line1); ty += line_h; }
if (line2 != "") { draw_text(tx, ty, line2); ty += line_h; }
if (line3 != "") { draw_text(tx, ty, line3); }

// Кнопка
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

// Сброс
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
