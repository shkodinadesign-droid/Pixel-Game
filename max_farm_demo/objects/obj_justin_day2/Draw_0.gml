// ===== JUSTIN DAY 2 — DRAW =====
draw_self();

// Анимация передачи пирога: круг летит дугой от Макс к Джастину
if (pie_anim_t >= 0 && pie_anim_t <= 1) {
    var _px = lerp(pie_start_x, pie_end_x, pie_anim_t);
    var _py = lerp(pie_start_y, pie_end_y, pie_anim_t) - sin(pie_anim_t * pi) * 48;

    // Пирог — коричневый круг
    draw_set_color(make_color_rgb(190, 120, 55));
    draw_circle(_px, _py, 13, false);
    draw_set_color(make_color_rgb(140, 80, 25));
    draw_circle(_px, _py, 13, true);

    // Маленькие "искры" вокруг
    draw_set_color(make_color_rgb(255, 200, 100));
    draw_set_alpha(1 - pie_anim_t);
    for (var _i = 0; _i < 4; _i++) {
        var _angle = (_i / 4) * 360 + pie_anim_t * 90;
        var _sx = _px + lengthdir_x(18, _angle);
        var _sy = _py + lengthdir_y(18, _angle);
        draw_circle(_sx, _sy, 3, false);
    }
    draw_set_alpha(1);
}
