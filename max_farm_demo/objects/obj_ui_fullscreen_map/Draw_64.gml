var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Фон — пергамент
draw_set_alpha(1);
draw_set_color(make_color_rgb(210, 185, 120));
draw_rectangle(0, 0, _gw, _gh, false);

// Рамка
draw_set_color(make_color_rgb(120, 80, 30));
draw_set_alpha(1);
var _p = 24;
draw_rectangle(_p, _p, _gw - _p, _gh - _p, true);
draw_rectangle(_p + 6, _p + 6, _gw - _p - 6, _gh - _p - 6, true);

// Заголовок
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(80, 40, 10));
draw_text(_gw / 2, _p + 20, "~ Карта Таинственного Леса ~");

// Заглушка карты — контур леса и путь
var _mx = _gw / 2;
var _my = _gh / 2;

// Лес
draw_set_color(make_color_rgb(100, 140, 70));
draw_set_alpha(0.6);
draw_ellipse(_mx - 120, _my - 80, _mx + 120, _my + 90, false);
draw_set_alpha(1);

// Деревья (кружки)
draw_set_color(make_color_rgb(60, 100, 40));
for (var _i = 0; _i < 8; _i++) {
    var _tx = _mx - 100 + _i * 28;
    var _ty = _my - 50 + sin(_i * 1.3) * 30;
    draw_circle(_tx, _ty, 14, false);
}

// Пунктирный путь от деревни к лесу
draw_set_color(make_color_rgb(150, 90, 30));
var _px1 = _p + 60; var _py1 = _gh - _p - 60;
var _px2 = _mx - 40; var _py2 = _my + 20;
for (var _s = 0; _s <= 1; _s += 0.08) {
    var _dx = lerp(_px1, _px2, _s);
    var _dy = lerp(_py1, _py2, _s);
    draw_circle(_dx, _dy, 3, false);
}

// X — метка
draw_set_color(make_color_rgb(180, 30, 30));
draw_set_alpha(1);
draw_line(_mx - 10, _my - 10, _mx + 10, _my + 10);
draw_line(_mx + 10, _my - 10, _mx - 10, _my + 10);
draw_circle(_mx, _my, 12, true);

// Деревня
draw_set_color(make_color_rgb(80, 40, 10));
draw_set_font(fnt_ui);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text(_p + 40, _gh - _p - 80, "Деревня");
draw_set_halign(fa_center);
draw_text(_mx, _my - 110, "Лес");

// Подсказка закрыть
draw_set_alpha(0.6);
draw_set_color(make_color_rgb(80, 40, 10));
draw_text(_gw / 2, _gh - _p - 30, "[E] Закрыть");
draw_set_alpha(1);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
