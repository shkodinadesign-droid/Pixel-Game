// ===== МАКС НАШЛА КЛЮЧ (DRAW) =====
// тень под Макс (сжимается, когда она в прыжке)
draw_set_color(c_black);
draw_set_alpha(0.22);
var _sw = 9 - hop * 0.3;
draw_ellipse(mx + 16 - _sw, my + 45, mx + 16 + _sw, my + 49, false);
draw_set_alpha(1);

// Макс
draw_sprite(spr_max_idle_down, floor(t / 12) mod sprite_get_number(spr_max_idle_down), mx, my - hop);

// мягкое сияние за ключом
var _glow = (t < T_RISE) ? t / T_RISE : 1;
if (t > T_JOY) _glow = max(0, 1 - (t - T_JOY) / (T_END - T_JOY));
draw_set_color(make_color_rgb(255, 236, 150));
draw_set_alpha(0.25 * _glow * (0.8 + 0.2 * sin(current_time / 120)));
draw_circle(kx, ky, 13, false);
draw_set_alpha(0.35 * _glow);
draw_circle(kx, ky, 8, false);
draw_set_alpha(1);

// ключ (иконка 30x30, центр — по kx,ky; в мире чуть меньше)
var _ks = 0.75;
draw_sprite_ext(spr_item_secret_key, 0, kx - 15 * _ks, ky - 15 * _ks, _ks, _ks, 0, c_white, _glow > 0 ? 1 : 0);

// блик-крестик, пробегающий по ключу
if (t > T_RISE && t < T_JOY && (t div 30) mod 2 == 0) {
    var _bx = kx - 6 + ((t mod 30) / 30) * 12;
    draw_set_color(c_white);
    draw_line(_bx - 2, ky - 4, _bx + 2, ky - 4);
    draw_line(_bx, ky - 6, _bx, ky - 2);
}

// искорки
for (var i = 0; i < array_length(sparks); i++) {
    var s = sparks[i];
    draw_set_alpha(min(1, s.life / 20));
    draw_set_color((s.life mod 10 < 5) ? c_white : make_color_rgb(255, 220, 110));
    draw_rectangle(s.x, s.y, s.x + 1, s.y + 1, false);
}
draw_set_alpha(1);

// «!» над головой в начале радости
if (t > T_RISE && t < T_RISE + 50) {
    draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_bottom);
    draw_set_color(make_color_rgb(255, 220, 80));
    draw_text(mx + 28, my - 6 - hop, "!");
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}
draw_set_color(c_white);
