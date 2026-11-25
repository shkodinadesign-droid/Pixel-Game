// ===== СКАЛЫ С НИЗКИМ ВХОДОМ (DRAW): две скалы, между ними тёмный проход, фиолетовое свечение из глубины =====
draw_set_color(make_color_rgb(14, 10, 18));
draw_ellipse(x - 15, y - 50, x + 15, y - 18, false);
draw_rectangle(x - 15, y - 34, x + 15, y, false);
draw_set_color(make_color_rgb(70, 40, 110)); draw_set_alpha(0.35 + 0.15 * sin(current_time / 600));
draw_ellipse(x - 9, y - 40, x + 9, y - 10, false);
draw_set_alpha(1);
draw_sprite_ext(spr_village2_rocks, 0, x - 46, y + 2,  1.25, 1.25, 0, c_white, 1);
draw_sprite_ext(spr_village2_rocks, 0, x + 46, y + 2, -1.25, 1.25, 0, c_white, 1);
draw_set_color(c_white);
