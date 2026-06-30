if (!global.pudding_on_porch) exit;

var _spr = asset_get_index("spr_pudding_icon");
if (sprite_exists(_spr)) {
    draw_sprite(_spr, 0, x, y);
} else {
    draw_set_color(make_color_rgb(255, 220, 140));
    draw_circle(x, y - 8, 12, false);
    draw_set_color(make_color_rgb(200, 140, 80));
    draw_circle(x, y - 8, 12, true);
}
