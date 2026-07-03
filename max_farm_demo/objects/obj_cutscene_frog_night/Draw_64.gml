var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Ночное затемнение поверх всего
draw_set_alpha(darkness);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Текст в фазе 2 (ест пуддинг)
if (phase == 2 && phase_timer > 30) {
    draw_set_alpha(min((phase_timer - 30) * 0.03, 0.85));
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh - 52, "...");
    draw_set_alpha(1);
}

// Текст когда лягушонок уходит
if (phase == 3 && phase_timer > 20) {
    draw_set_alpha(min((phase_timer - 20) * 0.03, 0.85));
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_gw / 2, _gh - 52, "Кто это был?");
    draw_set_alpha(1);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
