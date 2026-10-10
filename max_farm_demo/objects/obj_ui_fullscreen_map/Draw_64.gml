// ===== КАРТА ЛЯГУШОНКА (DRAW GUI) =====
// Схема маршрута: Ферма бабушки -> Деревня -> Лесная тропа -> Развилка -> Большой камень (крестик).
// Направления совпадают с комнатами: деревня справа от фермы, тропа — у правого края деревни,
// в лесу тропа идёт направо-вверх к развилке; тупик — вверх, к камню — направо.

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

var _col_ink    = make_color_rgb(80, 40, 10);
var _col_route  = make_color_rgb(150, 90, 30);
var _col_forest = make_color_rgb(100, 140, 70);
var _col_tree   = make_color_rgb(60, 100, 40);
var _col_red    = make_color_rgb(180, 30, 30);

// Фон — пергамент
draw_set_alpha(1);
draw_set_color(make_color_rgb(210, 185, 120));
draw_rectangle(0, 0, _gw, _gh, false);

// Рамка
var _p = 24;
draw_set_color(make_color_rgb(120, 80, 30));
draw_rectangle(_p, _p, _gw - _p, _gh - _p, true);
draw_rectangle(_p + 6, _p + 6, _gw - _p - 6, _gh - _p - 6, true);

// Заголовок
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(_col_ink);
draw_text(_gw / 2, _p + 16, "~ Карта Таинственного Леса ~");

// --- Точки маршрута (доли экрана) ---
var _nx = [0.15, 0.36, 0.56, 0.70, 0.85];
var _ny = [0.60, 0.60, 0.56, 0.42, 0.27];
var _nm = ["Ферма бабушки", "Деревня", "Лесная тропа", "Развилка", "Большой камень"];
for (var i = 0; i < 5; i++) { _nx[i] *= _gw; _ny[i] *= _gh; }
var _dead_x = 0.69 * _gw, _dead_y = 0.20 * _gh;   // тупик — вверх от развилки

// Лес — зелёное пятно вокруг тропы, развилки и камня
draw_set_alpha(0.45);
draw_set_color(_col_forest);
draw_ellipse(_nx[2] - 50, _dead_y - 40, _gw - _p - 30, _ny[2] + 66, false);
draw_set_alpha(1);
draw_set_color(_col_tree);
for (var i = 0; i < 9; i++) {
    var _tx = lerp(_nx[2] - 10, _gw - _p - 70, i / 8);
    var _ty = (i mod 2 == 0) ? _ny[2] + 48 : _dead_y - 18;
    draw_circle(_tx, _ty, 10, false);
}
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(_col_tree);
draw_text((_nx[3] + _nx[4]) / 2 + 30, _ny[2] + 30, "Лес");

// Ферма — домик, деревня — три домика
draw_set_color(_col_ink);
var _hx = _nx[0], _hy = _ny[0] - 34;
draw_rectangle(_hx - 12, _hy, _hx + 12, _hy + 16, true);
draw_triangle(_hx - 16, _hy, _hx + 16, _hy, _hx, _hy - 12, true);
for (var k = -1; k <= 1; k++) {
    var _vx = _nx[1] + k * 22, _vy = _ny[1] - 30 - abs(k) * 4;
    draw_rectangle(_vx - 7, _vy, _vx + 7, _vy + 10, true);
    draw_triangle(_vx - 10, _vy, _vx + 10, _vy, _vx, _vy - 8, true);
}

// Маршрут — пунктир по точкам, тупик — бледнее
draw_set_color(_col_route);
for (var i = 0; i < 4; i++) {
    var _len = point_distance(_nx[i], _ny[i], _nx[i + 1], _ny[i + 1]);
    var _steps = max(2, floor(_len / 12));
    for (var s = 1; s < _steps; s++) {
        draw_circle(lerp(_nx[i], _nx[i + 1], s / _steps), lerp(_ny[i], _ny[i + 1], s / _steps), 2.5, false);
    }
}
draw_set_alpha(0.45);
var _dl = point_distance(_nx[3], _ny[3], _dead_x, _dead_y);
for (var s = 1; s < floor(_dl / 12); s++) {
    draw_circle(lerp(_nx[3], _dead_x, s / floor(_dl / 12)), lerp(_ny[3], _dead_y, s / floor(_dl / 12)), 2, false);
}
draw_set_alpha(1);
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(_col_ink);
draw_set_alpha(0.6);
draw_text(_dead_x, _dead_y - 6, "тупик");
draw_set_alpha(1);

// Точки и подписи
for (var i = 0; i < 5; i++) {
    draw_set_color(_col_ink);
    draw_circle(_nx[i], _ny[i], 5, false);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(_nx[i], _ny[i] + 8, _nm[i]);
}

// Крестик у большого камня
draw_set_color(_col_red);
var _xx = _nx[4], _xy = _ny[4] - 22;
draw_line_width(_xx - 9, _xy - 9, _xx + 9, _xy + 9, 3);
draw_line_width(_xx + 9, _xy - 9, _xx - 9, _xy + 9, 3);
draw_circle(_xx, _xy, 13, true);

// "Вы здесь" — текущая область
var _area = forest_area();
var _hi = (_area == "farm") ? 0 : ((_area == "village") ? 1 : 2);
var _area_name = (_area == "farm") ? "ферма" : ((_area == "village") ? "деревня" : "лес");
var _pulse = 0.55 + 0.45 * sin(anim_t / 10);
draw_set_color(_col_red);
draw_set_alpha(_pulse);
draw_circle(_nx[_hi], _ny[_hi], 11, true);
draw_circle(_nx[_hi], _ny[_hi], 12, true);
draw_set_alpha(1);
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(_nx[_hi], _ny[_hi] - (_hi == 0 ? 52 : 46), "Вы здесь: " + _area_name);

// "Сейчас нужно: ..." — нижняя плашка
var _goal = "Сейчас нужно: " + forest_current_goal();
var _bx1 = _p + 30, _bx2 = _gw - _p - 30;
var _by2 = _gh - _p - 40;
draw_set_font(fnt_ui);
var _bh = string_height_ext(_goal, 20, _bx2 - _bx1 - 24) + 16;
var _by1 = _by2 - _bh;
draw_set_alpha(0.35);
draw_set_color(make_color_rgb(255, 245, 210));
draw_rectangle(_bx1, _by1, _bx2, _by2, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(120, 80, 30));
draw_rectangle(_bx1, _by1, _bx2, _by2, true);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(_col_ink);
draw_text_ext(_bx1 + 12, _by1 + 8, _goal, 20, _bx2 - _bx1 - 24);

// Подсказка управления
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_alpha(0.7);
draw_text(_gw / 2, _gh - _p - 32, "[M] - открыть карту в пути     [E] / [Esc] - закрыть");
draw_set_alpha(1);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
