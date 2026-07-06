var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Ночное затемнение
draw_set_alpha(darkness);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Фаза 3 — перемотка часов
if (phase == 3) {
    draw_set_alpha(text_alpha);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh / 2, "09:00  ☀");
    draw_set_alpha(1);
}

// Фаза 5 — лягушонок у пуддинга
if (phase == 5 && phase_timer > 30) {
    draw_set_alpha(min((phase_timer - 30) * 0.03, 0.85));
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh - 52, "...");
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
