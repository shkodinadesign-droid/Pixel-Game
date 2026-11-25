// ===== СКАЛЫ С НИЗКИМ ВХОДОМ В ПЕЩЕРУ (DRAW) =====
// Две скалы (spr_village2_rocks, правая зеркально), между ними — тёмный проход. Временная графика.
draw_set_color(make_color_rgb(18, 14, 14));
draw_ellipse(877, 146, 907, 178, false);
draw_rectangle(877, 162, 907, 196, false);
draw_set_color(make_color_rgb(36, 30, 28));
draw_rectangle(880, 188, 904, 196, false);              // пол прохода чуть светлее
draw_sprite_ext(spr_village2_rocks, 0, 846, 198,  1.25, 1.25, 0, c_white, 1);
draw_sprite_ext(spr_village2_rocks, 0, 938, 198, -1.25, 1.25, 0, c_white, 1);
draw_set_color(c_white);
