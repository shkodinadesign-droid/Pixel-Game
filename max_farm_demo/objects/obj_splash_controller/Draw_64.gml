var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Белый фон на весь экран
draw_clear_alpha(c_white, 1);


// --- РИСУЕМ ЛОГОТИП, ЗАНИМАЮЩИЙ 50% ШИРИНЫ ЭКРАНА ---
if (sprite_exists(spr_splash_logo)) {

    var sw = sprite_get_width(spr_splash_logo);
    var sh = sprite_get_height(spr_splash_logo);

    // целевая ширина = 50% GUI
    var target_width = gw * 0.5;
    var logo_scale = target_width / sw;

    // итоговые размеры
    var draw_w = sw * logo_scale;
    var draw_h = sh * logo_scale;

    // центрируем
    var dx = (gw - draw_w) * 0.5;
    var dy = (gh - draw_h) * 0.5;

    draw_sprite_ext(spr_splash_logo, 0, dx, dy, logo_scale, logo_scale, 0, c_white, 1);

} else {
    // Фолбэк, если вдруг спрайта нет
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(gw * 0.5, gh * 0.5, "NANO KITTY LABS");
}

// --- ЧЁРНЫЙ FADE-СЛОЙ СВЕРХУ ---
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
}

