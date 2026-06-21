// ===== ДИАЛОГ МАЙЛИ — МАГАЗИН (DRAW GUI) =====

var _speaker, _col, _l1, _l2, _l3;
switch (phase) {
    case 0:
        _speaker = "Майли:";
        _col     = make_color_rgb(80, 180, 120);
        _l1      = "Добро пожаловать в магазин!";
        _l2      = "Для новых посетителей у нас будут скидки!";
        _l3      = "";
        break;
    case 1:
        _speaker = "Макс:";
        _col     = make_color_rgb(255, 210, 100);
        _l1      = "Добрый день! Рада новому знакомству!";
        _l2      = "Хочу тут прикупить у вас новые товары!";
        _l3      = "";
        break;
    case 2:
        _speaker = "Майли:";
        _col     = make_color_rgb(80, 180, 120);
        _l1      = "Посмотрите что у нас есть!";
        _l2      = "У нас большой выбор =)";
        _l3      = "";
        break;
    default:
        _speaker = "";
        _col     = c_white;
        _l1      = ""; _l2 = ""; _l3 = "";
}

gpu_set_blendmode(bm_normal);
draw_set_alpha(1);

// Фон и рамка
draw_set_color(c_black);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, false);
draw_set_color(_col);
draw_roundrect_ext(win_x, win_y, win_x + win_w, win_y + win_h, 12, 12, true);

// Текст
var tx = win_x + pad + 8;
var ty = win_y + pad;

draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_col);
draw_text(tx, ty, _speaker);
ty += line_h * 1.5;

draw_set_color(c_white);
if (_l1 != "") { draw_text(tx, ty, _l1); ty += line_h; }
if (_l2 != "") { draw_text(tx, ty, _l2); ty += line_h; }
if (_l3 != "") { draw_text(tx, ty, _l3); ty += line_h; }

// Кнопка "Далее"
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

draw_set_color(hover ? c_white : c_black);
draw_rectangle(btn_x1, btn_y1, btn_x2, btn_y2, false);
draw_set_color(_col);
draw_line(btn_x1 + 1, btn_y1, btn_x2 - 1, btn_y1);
draw_line(btn_x1 + 1, btn_y2, btn_x2 - 1, btn_y2);
draw_line(btn_x1 + 1, btn_y1, btn_x1 + 1, btn_y2);
draw_line(btn_x2 - 1, btn_y1, btn_x2 - 1, btn_y2);

draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(hover ? c_black : c_white);
draw_text((btn_x1 + btn_x2) / 2, (btn_y1 + btn_y2) / 2, btn_label);

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1);
