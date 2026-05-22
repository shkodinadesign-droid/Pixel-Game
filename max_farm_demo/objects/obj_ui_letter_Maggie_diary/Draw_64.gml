// ===== MEGGI DIARY DIALOG DRAW GUI =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

// фон окна
draw_set_color(c_black);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, false);

// текст
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var tx = win_x + pad;
var ty = win_y + pad;

// заголовок
draw_set_font(fnt_ui);
draw_set_color(c_white);
draw_text(tx, ty, line1_bold);

ty += line_h * 1.6;

// основной текст
draw_set_font(fnt_ui);
draw_text(tx, ty, line2); ty += line_h;
draw_text(tx, ty, line3); ty += line_h;
draw_text(tx, ty, line4); ty += line_h;
draw_text(tx, ty, line5);

// кнопка
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

draw_set_color(hover ? c_white : c_black);
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);

draw_set_color(c_white);
draw_line(btn_x1 + 1, btn_y1, btn_x2 - 1, btn_y1);
draw_line(btn_x1 + 1, btn_y2, btn_x2 - 1, btn_y2);
draw_line(btn_x1 + 1, btn_y1, btn_x1 + 1, btn_y2);
draw_line(btn_x2 - 1, btn_y1, btn_x2 - 1, btn_y2);

draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(hover ? c_black : c_white);
draw_text((btn_x1 + btn_x2) / 2, (btn_y1 + btn_y2) / 2, "Спасибо!");

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
