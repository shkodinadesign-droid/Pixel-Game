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

// Подсказки «[E] Выйти» больше нет — входы и выходы шагом (scr_doors)
