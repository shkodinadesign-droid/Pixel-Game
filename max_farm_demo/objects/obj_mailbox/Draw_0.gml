// === ПОЧТОВЫЙ ЯЩИК (DRAW) ===
draw_self();

if (has_letter) {
    // Мигающий "!" над ящиком — переключается каждые 30 кадров
    var _blink = (current_time mod 600) < 300; // мигает ~1 раз в секунду
    if (_blink) {
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_bottom);
        draw_set_color(c_yellow);
        draw_text(x, bbox_top - 6, "!");
    }

    // Подсказка [E] когда игрок рядом
    if (instance_exists(obj_max)) {
        var p = instance_find(obj_max, 0);
        var foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
        var foot_y  = p.bbox_bottom;
        if (point_distance(x, y, foot_cx, foot_y) < 80) {
            draw_hint("[E] Открыть письмо", x, bbox_top - 8, true);
        }
    }

    draw_set_font(-1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
