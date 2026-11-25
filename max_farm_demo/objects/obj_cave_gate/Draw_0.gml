// ===== ЗАРОСЛИ (DRAW): кусты по высоте прохода =====
var _h = 32 * image_yscale;
for (var _yy = y - 20; _yy < y + _h - 30; _yy += 26) {
    draw_sprite_ext(spr_bush, 0, x - 18, _yy, 1, 1, 0, make_color_rgb(150, 130, 170), 1);
}
