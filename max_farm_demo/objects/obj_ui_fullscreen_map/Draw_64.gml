// ===== КАРТА ТАИНСТВЕННОГО ЛЕСА (DRAW GUI) =====
// Рисунок автора — spr_map_forest (810x540, b40_forest_map.py): кадр 0 — тайный лес под туманом,
// кадр 1 — после разговора с Джо карта целиком. Поверх — «Вы здесь», крестик цели и текст «Сейчас нужно».
// Точки маршрута — в координатах исходного рисунка 1536x1024.

var _gw = display_get_gui_width();
var _gh = display_get_gui_height();
var _col_ink = make_color_rgb(80, 40, 10);
var _col_red = make_color_rgb(180, 30, 30);
var _ext = global.jack_cave_talk_done;

// фон по краям — тёмное дерево стола, карта по центру
draw_set_alpha(1);
draw_rectangle_colour(0, 0, _gw, _gh, make_color_rgb(58, 38, 24), make_color_rgb(58, 38, 24), make_color_rgb(34, 22, 14), make_color_rgb(34, 22, 14), false);
var _ms = _gh / sprite_get_height(spr_map_forest);
var _mx = (_gw - sprite_get_width(spr_map_forest) * _ms) / 2;
draw_sprite_ext(spr_map_forest, _ext ? 1 : 0, _mx, 0, _ms, _ms, 0, c_white, 1);
var _k = sprite_get_height(spr_map_forest) * _ms / 1024;   // исходный рисунок -> экран

var _nx = [160, 356, 583, 765, 965, 1146, 1353];
var _ny = [592, 580, 557, 469, 382, 354, 455];
var _n = array_length(_nx);
for (var i = 0; i < _n; i++) { _nx[i] = _mx + _nx[i] * _k; _ny[i] = _ny[i] * _k; }

// крестик цели: у большого камня, после разговора с Джо — у пещеры
var _xx = _ext ? _nx[6] + 20 : _nx[4] + 14, _xy = _ext ? _ny[6] - 30 : _ny[4] - 22;
draw_set_color(_col_red);
draw_line_width(_xx - 7, _xy - 7, _xx + 7, _xy + 7, 3);
draw_line_width(_xx + 7, _xy - 7, _xx - 7, _xy + 7, 3);
draw_circle(_xx, _xy, 11, true);

// "Вы здесь" — текущая область
var _area = forest_area();
var _hi = 0, _area_name = "ферма";
switch (_area) {
    case "village": _hi = 1; _area_name = "деревня";    break;
    case "forest":  _hi = 2; _area_name = "лес";        break;
    case "mystic":  _hi = min(5, _n - 1); _area_name = "тайный лес"; break;
    case "cave":    _hi = min(6, _n - 1); _area_name = "пещера";     break;
}
var _pulse = 0.55 + 0.45 * sin(anim_t / 10);
draw_set_color(_col_red);
draw_set_alpha(_pulse);
draw_circle(_nx[_hi], _ny[_hi], 11, true);
draw_circle(_nx[_hi], _ny[_hi], 12, true);
draw_set_alpha(1);
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
var _yt = "Вы здесь: " + _area_name, _ty = _ny[_hi] - (_hi == 0 ? 40 : 18);
var _tw = string_width(_yt) / 2 + 8, _th = string_height(_yt);
draw_set_color(make_color_rgb(252, 230, 188)); draw_set_alpha(0.92);           // светлая плашка — читается поверх леса
draw_roundrect_ext(_nx[_hi] - _tw, _ty - _th - 4, _nx[_hi] + _tw, _ty + 2, 8, 8, false);
draw_set_alpha(1); draw_set_color(_col_red);
draw_roundrect_ext(_nx[_hi] - _tw, _ty - _th - 4, _nx[_hi] + _tw, _ty + 2, 8, 8, true);
draw_text(_nx[_hi], _ty, _yt);

// "Сейчас нужно: ..." — в плашку рисунка
var _goal = "Сейчас нужно: " + forest_current_goal();
var _bx1 = _mx + 290 * _k, _bx2 = _mx + 1262 * _k, _by1 = 760 * _k, _by2 = 838 * _k;
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_col_ink);
draw_text_ext((_bx1 + _bx2) / 2, (_by1 + _by2) / 2, _goal, 17, _bx2 - _bx1);
// подсказка управления уже нарисована на карте

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
