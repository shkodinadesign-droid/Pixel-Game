// ===== ДЕРЕВНЯ: УКАЗАТЕЛЬ "ЛЕСНАЯ ТРОПА" (DRAW) =====
draw_self();
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(60, 32, 18));
draw_text(x + 60, y + 15, "Лесная тропа");
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
