// ===== СТОЛ С ЗЕЛЁНОЙ ТЕТРАДЬЮ (DRAW) =====
draw_self();
// мягкое свечение, пока тетрадь не прочитана
if (!global.secret_room_opened) {
    draw_set_color(make_color_rgb(190, 255, 170));
    draw_set_alpha(0.18 + 0.1 * sin(current_time / 300));
    draw_ellipse(book_x - 12, book_y - 6, book_x + 26, book_y + 16, false);
    draw_set_alpha(1);
}
// зелёная тетрадь (временная графика)
draw_set_color(make_color_rgb(30, 70, 40));   draw_rectangle(book_x - 1, book_y - 1, book_x + 15, book_y + 11, false);
draw_set_color(make_color_rgb(60, 130, 70));  draw_rectangle(book_x, book_y, book_x + 14, book_y + 10, false);
draw_set_color(make_color_rgb(235, 225, 200)); draw_rectangle(book_x + 14, book_y + 1, book_x + 15, book_y + 10, false);
draw_set_color(make_color_rgb(200, 170, 90)); draw_rectangle(book_x + 3, book_y + 4, book_x + 10, book_y + 5, false);
draw_set_color(c_white);
if (near_player && !global.control_locked) draw_hint("[E] Зелёная тетрадь", x, y - 40, true);
