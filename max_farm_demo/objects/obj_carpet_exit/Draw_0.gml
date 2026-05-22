// ===== CARPET EXIT DRAW =====

// Рисуем ковёр — спрайт или заглушка
if (sprite_exists(spr_carpet)) {
    draw_sprite_ext(spr_carpet, 0, x, y, 1, 1, 0, c_white, 1);
} else {
    // Заглушка — тёмно-красный эллипс (коврик у двери)
    draw_set_color(make_color_rgb(110, 40, 40));
    draw_ellipse(x - 28, y - 14, x + 28, y + 14, false);
    draw_set_color(make_color_rgb(160, 70, 70));
    draw_ellipse(x - 28, y - 14, x + 28, y + 14, true);
    draw_set_color(make_color_rgb(180, 100, 100));
    draw_ellipse(x - 20, y - 8, x + 20, y + 8, true);
}

// Подсказка [E] Выйти
if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 96) {
            draw_hint("[E] Выйти", x, y - 16, true);
        }
    }
}
