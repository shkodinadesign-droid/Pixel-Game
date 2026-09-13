// ===== ДИАЛОГ: ЗАКРЫТАЯ ТАЙНАЯ ДВЕРЬ (DRAW GUI) =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон окна
scr_dialog_draw_bg(win_x, win_y, win_w, win_h);

var tx = win_x + pad + icon_size + pad;
var ty = scr_dialog_body_top(win_x, win_y, win_w, win_h);

// Имя говорящего — жирным, в бирке
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, speaker);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Фон портрета
draw_set_color(make_color_rgb(40, 28, 14));
draw_roundrect_ext(icon_x, icon_y, icon_x + icon_size, icon_y + icon_size, 8, 8, false);
draw_set_color(make_color_rgb(120, 85, 50));
draw_roundrect_ext(icon_x, icon_y, icon_x + icon_size, icon_y + icon_size, 8, 8, true);

// TODO: заменить на спрайт бабушки
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_white);
draw_text(icon_x + icon_size * 0.5, icon_y + icon_size * 0.5, "?");

// Текст справа от портрета
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_black);
draw_text(tx, ty,          line1);
draw_text(tx, ty + line_h, line2);
if (line_count >= 3) draw_text(tx, ty + line_h * 2, line3);
if (line_count >= 4) draw_text(tx, ty + line_h * 3, line4);

// Кнопка "Понятно"
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
