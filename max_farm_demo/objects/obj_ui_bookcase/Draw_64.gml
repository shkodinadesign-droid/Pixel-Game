// ===== BOOKCASE DIALOG DRAW GUI =====

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Лёгкое затемнение фона
draw_set_alpha(0.35);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Фон окна
draw_set_color(make_color_rgb(20, 14, 8));
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 10, 10, false);

// Тонкая рамка — тёплый оттенок
draw_set_color(make_color_rgb(160, 120, 60));
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 10, 10, true);

// Текст
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var tx = win_x + pad;
var ty = win_y + pad;

// Имя говорящего — выделено тёплым цветом
draw_set_font(fnt_ui);
draw_set_color(make_color_rgb(220, 170, 80));
draw_text(tx, ty, speaker);
ty += line_h * 1.5;

// Основной текст — мягкий белый
draw_set_font(fnt_ui);
draw_set_color(make_color_rgb(235, 225, 210));
draw_text(tx, ty, line1); ty += line_h;
draw_text(tx, ty, line2); ty += line_h;
draw_text(tx, ty, line3); ty += line_h;
draw_text(tx, ty, line4); ty += line_h;
draw_text(tx, ty, line5);

// Кнопка закрытия
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

draw_set_color(hover ? make_color_rgb(220, 170, 80) : make_color_rgb(20, 14, 8));
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);

// Рамка кнопки
draw_set_color(make_color_rgb(160, 120, 60));
draw_line(btn_x1 + 1, btn_y1, btn_x2 - 1, btn_y1);
draw_line(btn_x1 + 1, btn_y2, btn_x2 - 1, btn_y2);
draw_line(btn_x1 + 1, btn_y1, btn_x1 + 1, btn_y2);
draw_line(btn_x2 - 1, btn_y1, btn_x2 - 1, btn_y2);

// Текст кнопки
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(hover ? make_color_rgb(20, 14, 8) : make_color_rgb(235, 225, 210));
draw_text((btn_x1 + btn_x2) / 2, (btn_y1 + btn_y2) / 2, "Закрыть [E]");

// Сброс
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
