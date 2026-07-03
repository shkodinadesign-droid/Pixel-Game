if (phase < 1 || phase > 3) exit;

// Силуэт лягушонка (заменим на спрайт когда будет готов)
var _bob = sin(frog_anim * 0.18) * 3; // покачивание при ходьбе
var _fx = x;
var _fy = y + _bob;
var _sc = frog_dir; // зеркалим по направлению

// Проверяем спрайт
var _spr = asset_get_index("spr_frog");
if (sprite_exists(_spr)) {
    draw_sprite_ext(_spr, 0, _fx, _fy, _sc, 1, 0, c_black, 0.9);
} else {
    // Заглушка — тёмный силуэт
    var _dark = make_color_rgb(20, 20, 30);
    draw_set_color(_dark);
    draw_set_alpha(0.9);
    // Тело
    draw_ellipse(_fx - 14 * _sc, _fy - 8, _fx + 14 * _sc, _fy + 10, false);
    // Голова
    draw_ellipse(_fx - 9 * _sc, _fy - 22, _fx + 9 * _sc, _fy - 6, false);
    // Колпак
    draw_set_color(make_color_rgb(80, 0, 0));
    draw_triangle(
        _fx - 8 * _sc, _fy - 22,
        _fx + 8 * _sc, _fy - 22,
        _fx, _fy - 40, false
    );
    draw_set_alpha(1);
}
