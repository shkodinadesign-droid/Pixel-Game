// =============================================
// УНИВЕРСАЛЬНОЕ ОКНО ПИСЬМА (DRAW GUI)
// =============================================

if (!ready) exit;

// --- фон ---
draw_set_alpha(1);
scr_dialog_draw_bg(win_x, win_y, win_w, win_h);

// --- портрет бабушки — в свободном месте справа ---
var scale_x = win_w / 580;
var scale_y = win_h / 234;

var portrait_size = 140;
var portrait_x2 = win_x + 565 * scale_x - 8;
var portrait_x1 = portrait_x2 - portrait_size;
var portrait_top = win_y + 49 * scale_y;
var portrait_y1 = portrait_top + (btn_y1 - portrait_top - portrait_size) / 2;
var portrait_y2 = portrait_y1 + portrait_size;

draw_set_color(make_color_rgb(60, 38, 20));
draw_roundrect_ext(portrait_x1, portrait_y1, portrait_x2, portrait_y2, 10, 10, false);
draw_set_color(make_color_rgb(120, 85, 50));
draw_roundrect_ext(portrait_x1, portrait_y1, portrait_x2, portrait_y2, 10, 10, true);

var portrait_pad = 8;
var portrait_scale = (portrait_size - portrait_pad * 2) / sprite_get_width(spr_grandma_max_portrait);
draw_sprite_ext(spr_grandma_max_portrait, 0, portrait_x1 + portrait_pad, portrait_y1 + portrait_pad, portrait_scale, portrait_scale, 0, c_white, 1);

// --- текст (ограничен справа, чтобы не наезжать на портрет) ---
var tx = win_x + 15 * scale_x + 8;
var ty = scr_dialog_body_top(win_x, win_y, win_w, win_h);
var text_max_w = portrait_x1 - tx - 16;

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// отправитель — жирным, в ячейке-бирке
scr_dialog_draw_speaker(win_x, win_y, win_w, win_h, sender + ":");
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// основной текст (высота каждой строки считается с учётом переноса)
draw_set_font(fnt_ui);
draw_set_color(c_black);
for (var i = 0; i < array_length(lines); i++) {
    draw_text_ext(tx, ty, lines[i], -1, text_max_w);
    ty += string_height_ext(lines[i], -1, text_max_w) + 6;
}

// подсказка-туториал (жёлтая плашка)
if (hint_text != "") {
    ty += line_h * 0.5;

    var _hint_full = "Подсказка: " + hint_text;
    var _hint_h = string_height_ext(_hint_full, -1, text_max_w);

    draw_set_alpha(0.3);
    draw_set_color(c_yellow);
    draw_rectangle(tx - 4, ty - 2, tx + text_max_w + 4, ty + _hint_h + 4, false);
    draw_set_alpha(1);

    draw_set_font(fnt_ui);
    draw_set_color(make_color_rgb(110, 80, 10));
    draw_text_ext(tx, ty, _hint_full, -1, text_max_w);
}

// --- КНОПКА «ЗАКРЫТЬ» ---
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

scr_dialog_draw_button(btn_x1, btn_y1, btn_x2, btn_y2, "Закрыть", hover);

// --- сброс ---
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
