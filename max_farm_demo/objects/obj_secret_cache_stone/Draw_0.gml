// ===== КАМЕНЬ СО ЗВЁЗДОЧКОЙ (DRAW) — spr_stone_01 32x32, видимая часть ~ x 6..24, y 12..23 =====
// Временная графика: камень + мох + едва заметная звёздочка. Нарисуешь свой спрайт — поставь его объекту.
var _dx = global.secret_cache_found ? 12 : 0;      // после тайника камень отодвинут вправо
if (global.secret_cache_found) {                   // ямка, где лежала коробка
    draw_set_color(make_color_rgb(70, 50, 35));
    draw_ellipse(x + 8, y + 16, x + 22, y + 23, false);
}
draw_sprite(sprite_index, 0, x + _dx, y);
// мох
draw_set_color(make_color_rgb(96, 128, 60));
draw_rectangle(x + _dx + 7,  y + 13, x + _dx + 11, y + 15, false);
draw_rectangle(x + _dx + 16, y + 12, x + _dx + 21, y + 14, false);
draw_rectangle(x + _dx + 12, y + 18, x + _dx + 14, y + 19, false);
// звёздочка — почти не видна
draw_set_alpha(0.45);
draw_set_color(make_color_rgb(70, 64, 76));
var _sx = x + _dx + 15, _sy = y + 16;
draw_line(_sx - 2, _sy, _sx + 2, _sy);
draw_line(_sx, _sy - 2, _sx, _sy + 2);
draw_point(_sx - 1, _sy - 1); draw_point(_sx + 1, _sy + 1);
draw_point(_sx + 1, _sy - 1); draw_point(_sx - 1, _sy + 1);
draw_set_alpha(1);
draw_set_color(c_white);
if (near_player && !global.control_locked) draw_hint("[E] Осмотреть камень", x + 15, y + 6, true);
