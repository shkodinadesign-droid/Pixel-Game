// Спрайт карты на земле
// Замени spr_tab_diary на свою иконку папируса когда будет готова
var _spr = asset_get_index("spr_frog_map_icon");
if (sprite_exists(_spr)) {
    draw_sprite(_spr, 0, x, y);
} else {
    // Заглушка — свёрнутый свиток
    draw_set_color(make_color_rgb(210, 175, 90));
    draw_set_alpha(1);
    draw_roundrect_ext(x - 10, y - 14, x + 10, y + 14, 3, 3, false);
    draw_set_color(make_color_rgb(160, 120, 50));
    draw_roundrect_ext(x - 10, y - 14, x + 10, y + 14, 3, 3, true);
    draw_set_color(make_color_rgb(120, 80, 30));
    draw_line(x - 6, y - 8, x + 6, y - 8);
    draw_line(x - 6, y,     x + 6, y);
    draw_line(x - 6, y + 8, x + 6, y + 8);
    draw_set_alpha(1);
}
