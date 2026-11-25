// ===== ПЕРВОЕ ИСПЫТАНИЕ (DRAW): фон и поверхности =====
cave_draw_backdrop();
draw_set_color(make_color_rgb(14, 10, 16));
draw_rectangle(WALL_R, 96, 960, 144, false);            // проём выхода наверху справа
draw_rectangle(0, 400, WALL_L, F, false);               // проём входа слева
side_draw_solids();

// страж, падающие камни и глина рисуются поверх света (Draw End) — их всегда видно
draw_set_color(c_white);
