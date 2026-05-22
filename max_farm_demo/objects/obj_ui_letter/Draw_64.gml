// =============================================
// УНИВЕРСАЛЬНОЕ ОКНО ПИСЬМА (DRAW GUI)
// =============================================

if (!ready) exit;

// --- фон ---
draw_set_alpha(1);
draw_set_color(c_black);
draw_rectangle(win_x, win_y, win_x + win_w, win_y + win_h, false);

// --- рамка ---
draw_set_color(c_white);
draw_rectangle(win_x + 2, win_y + 2, win_x + win_w - 2, win_y + win_h - 2, true);

// --- текст ---
var tx = win_x + pad;
var ty = win_y + pad;

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// отправитель (жирный)
draw_set_font(fnt_ui);
draw_set_color(c_white);
draw_text(tx, ty, sender + ":");

ty += line_h * 1.2;

// заголовок (жирный)
draw_text(tx, ty, title_text);

ty += line_h * 1.6;

// основной текст
draw_set_font(fnt_ui);
draw_set_color(c_white);
for (var i = 0; i < array_length(lines); i++) {
    draw_text(tx, ty, lines[i]);
    ty += line_h;
}

// подсказка-туториал (жёлтая плашка)
if (hint_text != "") {
    ty += line_h * 0.5;

    var hw = win_w - pad * 2;
    draw_set_alpha(0.3);
    draw_set_color(c_yellow);
    draw_rectangle(tx - 4, ty - 2, tx + hw + 4, ty + line_h + 4, false);
    draw_set_alpha(1);

    draw_set_font(fnt_ui);
    draw_set_color(c_yellow);
    draw_text(tx, ty, "Подсказка: " + hint_text);
}

// --- КНОПКА «ЗАКРЫТЬ» ---
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

draw_set_color(hover ? c_white : c_black);
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);

draw_set_color(c_white);
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, true);

draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(hover ? c_black : c_white);
draw_text((btn_x1 + btn_x2) / 2, (btn_y1 + btn_y2) / 2, "Закрыть");

// --- сброс ---
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
