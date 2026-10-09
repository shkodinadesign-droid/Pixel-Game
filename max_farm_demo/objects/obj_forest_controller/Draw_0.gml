// ===== ЛЕС: КРЕСТИК НА ЗЕМЛЕ (DRAW) =====
// Временная графика: крестик процарапан на земле у большого камня — то же место, что на карте.
var _c1 = make_color_rgb(110, 62, 34);
var _c2 = make_color_rgb(150, 96, 56);
draw_set_color(_c2);
draw_line_width(x - 8, y - 6, x + 8, y + 6, 3);
draw_line_width(x + 8, y - 6, x - 8, y + 6, 3);
draw_set_color(_c1);
draw_line_width(x - 7, y - 6, x + 7, y + 5, 2);
draw_line_width(x + 7, y - 6, x - 7, y + 5, 2);
draw_set_color(c_white);
