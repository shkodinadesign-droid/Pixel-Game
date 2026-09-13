// ===== ДИАЛОГ: ЗАДАНИЕ ПОСАДКИ (DRAW GUI) =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон и рамка диалога
scr_dialog_draw_bg(win_x, win_y, win_w, win_h);

// ==============================================
// ИКОНКА РОСТКА (левая часть диалога)
// ==============================================
var _cx = win_x + 52;
var _cy = win_y + win_h / 2 + 4;

// Земля
draw_set_color(make_color_rgb(120, 75, 35));
draw_ellipse(_cx - 18, _cy + 10, _cx + 18, _cy + 20, false);
draw_set_color(make_color_rgb(80, 45, 15));
draw_ellipse(_cx - 18, _cy + 10, _cx + 18, _cy + 20, true);

// Стебель
draw_set_color(make_color_rgb(80, 160, 60));
draw_rectangle(_cx - 2, _cy - 12, _cx + 2, _cy + 12, false);

// Лист влево
draw_set_color(make_color_rgb(90, 175, 65));
draw_ellipse(_cx - 14, _cy - 8, _cx, _cy + 2, false);

// Лист вправо
draw_ellipse(_cx, _cy - 18, _cx + 14, _cy - 6, false);

// ==============================================
// ТЕКСТ (правее иконки)
// ==============================================
var tx = win_x + 100;
var ty = scr_dialog_body_top(win_x, win_y, win_w, win_h);

// Имя говорящего — жирным, в бирке
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, speaker);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_font(fnt_ui);
draw_set_color(c_black);
if (line1 != "") { draw_text_ext(tx, ty, line1, -1, win_w - 120); ty += line_h; }
if (line2 != "") { draw_text(tx, ty, line2); ty += line_h; }
if (line3 != "") { draw_text_ext(tx, ty, line3, -1, win_w - 120); }

// ==============================================
// КНОПКА "ПОНЯТНО!"
// ==============================================
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

scr_dialog_draw_button(btn_x1, btn_y1, btn_x2, btn_y2, btn_label, hover);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
