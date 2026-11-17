// ===== MAX MUFFIN DIALOG — DRAW GUI =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

// Фон
scr_dialog_draw_bg(win_x, win_y, win_w, win_h);

var tx = win_x + 15 * (win_w / 580) + 8;
var ty = scr_dialog_body_top(win_x, win_y, win_w, win_h);

// Имя говорящего — жирным, в бирке
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, speaker);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Строки диалога
draw_set_font(fnt_ui);
draw_set_color(c_black);
if (line1 != "") { draw_text(tx, ty, line1); ty += line_h; }
if (line2 != "") { draw_text(tx, ty, line2); ty += line_h; }
if (line3 != "") { draw_text(tx, ty, line3); ty += line_h; }
if (line4 != "") { draw_text(tx, ty, line4); }

// Кнопка
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

scr_dialog_draw_button(btn_x1, btn_y1, btn_x2, btn_y2, btn_label, hover);

// Сброс
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
