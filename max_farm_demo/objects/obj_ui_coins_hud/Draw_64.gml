// ===== COINS HUD DRAW GUI =====
// Левый верхний угол (вместо HP)

if ((variable_global_exists("coins") && global.coins > 0) || global.coins_anim_target > 0) {

    draw_set_alpha(fade_in);

    var _cx = 20;  // левый край
    var _cy = 20;

    // --- Круглая монета ---
    draw_set_color(make_color_rgb(255, 210, 50));
    draw_circle(_cx, _cy + 9, 11, false);
    draw_set_color(make_color_rgb(200, 155, 20));
    draw_circle(_cx, _cy + 9, 11, true);
    // Буква "C" на монете
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(130, 85, 5));
    draw_text(_cx, _cy + 9, "C");

    // --- Счётчик ---
    var _amount = global.coins_anim_current;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(255, 235, 110));
    draw_text(_cx + 15, _cy + 1, string(_amount));

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
}
