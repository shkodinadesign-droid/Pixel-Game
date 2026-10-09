// ===== ДОСКА ОБЪЯВЛЕНИЙ (DRAW) =====
draw_self();

// Подсказка [E] когда игрок рядом
if (near_player && !global.control_locked) {
    draw_hint("[E] Смотреть", (bbox_left + bbox_right) * 0.5, bbox_top - 8, true);
}

draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
