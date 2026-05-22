// === ПОЧТОВЫЙ ЯЩИК (DRAW) ===
draw_self();

if (has_letter) {
    // индикатор "!" над ящиком
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_yellow);
    draw_text(x, bbox_top - 6, "!");

    // подсказка "E" когда игрок рядом
    if (instance_exists(obj_max)) {
        var p = instance_find(obj_max, 0);
        if (point_distance(x, y, p.x, p.y) < 48) {
            draw_set_color(c_white);
            draw_text(x, bbox_top - 24, "E");
        }
    }

    // сброс состояния отрисовки
    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
