// ===== NEIGHBOR DIALOG DRAW GUI =====

// сброс графического состояния
gpu_set_blendmode(bm_normal);
draw_set_alpha(1);
draw_set_color(c_white);

// фон окна
scr_dialog_draw_bg(win_x, win_y, win_w, win_h);

// геометрия спрайта spr_dialog_window (580x234) в масштабе текущего окна
var scale_x = win_w / 580;
var scale_y = win_h / 234;

// основная область текста (в спрайте: начинается под биркой, x 15..565, y 74..220)
var body_x1 = win_x + 15 * scale_x;
var body_y1 = scr_dialog_body_top(win_x, win_y, win_w, win_h);

// плашка-портрет бабули — в свободном месте справа (правее бирки, над кнопкой)
var portrait_size = 104;
var portrait_x2 = win_x + 565 * scale_x - 8;
var portrait_x1 = portrait_x2 - portrait_size;
var portrait_top = win_y + 49 * scale_y;
var portrait_y1 = portrait_top + (btn_y1 - portrait_top - portrait_size) / 2;
var portrait_y2 = portrait_y1 + portrait_size;

draw_set_color(make_color_rgb(60, 38, 20));
draw_roundrect_ext(portrait_x1, portrait_y1, portrait_x2, portrait_y2, 10, 10, false);
draw_set_color(make_color_rgb(120, 85, 50));
draw_roundrect_ext(portrait_x1, portrait_y1, portrait_x2, portrait_y2, 10, 10, true);

var portrait_pad = 6;
var portrait_scale = (portrait_size - portrait_pad * 2) / sprite_get_width(spr_grandma_maggie_portrait);
draw_sprite_ext(spr_grandma_maggie_portrait, 0, portrait_x1 + portrait_pad, portrait_y1 + portrait_pad, portrait_scale, portrait_scale, 0, c_white, 1);

// текст (ограничена справа, чтобы не наезжать на портрет)
var text_max_w = portrait_x1 - body_x1 - 16;

// имя — жирным, по центру ячейки-бирки
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, line1_bold);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// основной текст — под биркой, внутри окна
var tx = body_x1 + 8;
var ty = body_y1;

draw_set_font(fnt_ui);
draw_set_color(c_black);
draw_text_ext(tx, ty, line2, -1, text_max_w); ty += line_h;
draw_text_ext(tx, ty, line3, -1, text_max_w); ty += line_h;
draw_text_ext(tx, ty, line4, -1, text_max_w); ty += line_h;
draw_text_ext(tx, ty, line5, -1, text_max_w);

// кнопка
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

scr_dialog_draw_button(btn_x1, btn_y1, btn_x2, btn_y2, "Закрыть", hover);

// сброс
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
