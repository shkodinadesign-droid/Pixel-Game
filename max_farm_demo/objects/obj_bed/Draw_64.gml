// === КРОВАТЬ (DRAW GUI) ===

if (show_sleep_hint) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var txt;
    if (sleep_available) {
        txt = "E : лечь спать";
    } else {
        txt = "Спать можно после 18:00";
    }

    // Позиция над кроватью (конвертируем в GUI координаты)
    var cam = view_camera[0];
    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var cam_w = camera_get_view_width(cam);
    var cam_h = camera_get_view_height(cam);
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var cx = (x - cam_x) / cam_w * gui_w;
    var cy = (bbox_top - 24 - cam_y) / cam_h * gui_h;

    // Размеры текста
    var pad = 6;
    var tw = string_width(txt) + pad * 2;
    var th = string_height(txt) + pad * 2;

    // Ограничиваем, чтобы не вылезало за экран
    cx = clamp(cx, tw/2 + 8, gui_w - tw/2 - 8);
    cy = clamp(cy, th/2 + 8, gui_h - th/2 - 8);

    // Фон
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_roundrect_ext(cx - tw/2, cy - th/2, cx + tw/2, cy + th/2, 6, 6, false);
    draw_set_alpha(1);

    // Текст
    draw_set_color(sleep_available ? c_white : c_gray);
    draw_text(cx, cy, txt);

    // Сброс
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
