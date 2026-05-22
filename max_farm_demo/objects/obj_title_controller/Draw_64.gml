/// DRAW GUI: Title art + prompt + fade

var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Белый фон
draw_clear_alpha(c_white, 1);

// --- Рисуем титульный арт во весь экран ---
if (sprite_exists(spr_title_screen)) {

    var sw = sprite_get_width(spr_title_screen);
    var sh = sprite_get_height(spr_title_screen);

    // Масштабируем максимально, сохраняя пропорции
    var scale = min(gw / sw, gh / sh);

    var draw_w = sw * scale;
    var draw_h = sh * scale;

    var dx = (gw - draw_w) * 0.5;
    var dy = (gh - draw_h) * 0.5;

    draw_sprite_ext(spr_title_screen, 0, dx, dy, scale, scale, 0, c_white, 1);

} else {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text(gw * 0.5, gh * 0.5, "spr_title_screen not found");
}

// --- Мигающая подсказка ---
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var blink = 0.5 + 0.5 * sin(t * blink_speed);

draw_set_color(c_white);
draw_set_alpha(0.25 + 0.75 * blink);
draw_text(gw * 0.5, gh * 0.9, press_text);
draw_set_alpha(1);

// --- Fade слой ---
if (fade_alpha > 0) {
    draw_set_alpha(fade_alpha);
    draw_set_color(c_black);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
}
