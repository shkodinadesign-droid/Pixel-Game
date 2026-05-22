// === СЕРВАНТ (DRAW GUI) ===

if (show_hint) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    var _q  = chr(34);
    var txt = "Когда я была маленькой, бабушка мне читала\nэти книги. Моей любимой была\n" + _q + "Волшебник страны Оз" + _q;
    var max_w   = 300;
    var line_sep = -1;

    // Конвертируем мировые координаты объекта в GUI
    var cam   = view_camera[0];
    var cam_x = 0;
    var cam_y = 0;
    var cam_w = room_width;
    var cam_h = room_height;
    if (cam != -1) {
        var _w = camera_get_view_width(cam);
        var _h = camera_get_view_height(cam);
        if (_w > 0 && _h > 0) {
            cam_x = camera_get_view_x(cam);
            cam_y = camera_get_view_y(cam);
            cam_w = _w;
            cam_h = _h;
        }
    }
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var cx = (x - cam_x) / cam_w * gui_w;
    var cy = (bbox_top - 24 - cam_y) / cam_h * gui_h;

    // Размеры таблички (многострочный текст)
    var pad = 8;
    var tw  = string_width_ext(txt, line_sep, max_w)  + pad * 2;
    var th  = string_height_ext(txt, line_sep, max_w) + pad * 2;

    // Не вылезаем за экран
    cx = clamp(cx, tw / 2 + 8, gui_w - tw / 2 - 8);
    cy = clamp(cy, th / 2 + 8, gui_h - th / 2 - 8);

    // Фон
    draw_set_alpha(0.8);
    draw_set_color(c_black);
    draw_roundrect_ext(cx - tw / 2, cy - th / 2, cx + tw / 2, cy + th / 2, 6, 6, false);
    draw_set_alpha(1);

    // Текст (многострочный)
    draw_set_color(c_white);
    draw_text_ext(cx, cy, txt, line_sep, max_w);

    // Сброс
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
