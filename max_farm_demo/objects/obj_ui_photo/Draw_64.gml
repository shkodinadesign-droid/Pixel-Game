// ===== СТАРАЯ ФОТОГРАФИЯ (DRAW GUI) =====
var _gw = display_get_gui_width(), _gh = display_get_gui_height();
draw_set_alpha(0.55); draw_set_color(c_black); draw_rectangle(0, 0, _gw, _gh, false); draw_set_alpha(1);

if (sprite_exists(photo_spr)) {
    // у рисунка своя потёртая рамка — только мягкая тень под ним
    draw_set_alpha(0.35); draw_set_color(c_black);
    draw_roundrect(px + 6, py + 8, px + pw + 6, py + ph + 8, false);
    draw_set_alpha(1);
    draw_sprite(photo_spr, 0, px, py);
} else {
    draw_set_color(make_color_rgb(236, 228, 210));
    draw_rectangle(px - 12, py - 12, px + pw + 12, py + ph + 12, false);
    // --- временная картинка в сепии ---
    var _sky = make_color_rgb(214, 190, 150), _grass = make_color_rgb(160, 132, 92);
    var _dark = make_color_rgb(92, 70, 48), _mid = make_color_rgb(128, 100, 70);
    draw_set_color(_sky);   draw_rectangle(px, py, px + pw, py + ph, false);
    draw_set_color(_grass); draw_rectangle(px, py + ph * 0.62, px + pw, py + ph, false);
    // молодая яблоня
    var _tx = px + pw * 0.55, _ty = py + ph * 0.70;
    draw_set_color(_dark); draw_rectangle(_tx - 3, _ty - 70, _tx + 3, _ty, false);
    draw_set_color(_mid);  draw_circle(_tx, _ty - 88, 30, false);
    draw_set_color(_dark); draw_circle(_tx - 10, _ty - 92, 4, false); draw_circle(_tx + 12, _ty - 80, 4, false);
    // большой плоский камень со звёздочкой у корней
    draw_set_color(make_color_rgb(150, 138, 120)); draw_ellipse(_tx + 6, _ty - 6, _tx + 52, _ty + 12, false);
    draw_set_color(_dark);
    var _sx = _tx + 29, _sy = _ty + 3;
    draw_line(_sx - 5, _sy, _sx + 5, _sy); draw_line(_sx, _sy - 4, _sx, _sy + 4);
    draw_line(_sx - 3, _sy - 3, _sx + 3, _sy + 3); draw_line(_sx - 3, _sy + 3, _sx + 3, _sy - 3);
    // две девочки: Соня (пучок) и Мэгги (косички)
    for (var _g = 0; _g < 2; _g++) {
        var _gx = px + pw * (0.22 + _g * 0.13), _gy = py + ph * 0.80;
        draw_set_color(_dark);  draw_rectangle(_gx - 9, _gy - 34, _gx + 9, _gy, false);      // платье
        draw_set_color(make_color_rgb(200, 170, 130)); draw_circle(_gx, _gy - 44, 9, false); // лицо
        draw_set_color(_dark);
        if (_g == 0) draw_circle(_gx, _gy - 56, 5, false);                                 // пучок
        else { draw_rectangle(_gx - 11, _gy - 46, _gx - 9, _gy - 34, false); draw_rectangle(_gx + 9, _gy - 46, _gx + 11, _gy - 34, false); }
    }
    // потёртости
    draw_set_alpha(0.18); draw_set_color(c_white);
    draw_line(px + 20, py + 30, px + 90, py + 12); draw_line(px + pw - 60, py + ph - 20, px + pw - 10, py + ph - 40);
    draw_set_alpha(1);
}

// подпись под фото
draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(250, 238, 210));
draw_text(px + pw / 2, py + ph + 18, caption);

// кнопка
var _mx = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
scr_dialog_draw_button(btn_x1, btn_y1, btn_x1 + btn_w, btn_y1 + btn_h, "Закрыть",
                       _mx >= btn_x1 && _mx <= btn_x1 + btn_w && _my >= btn_y1 && _my <= btn_y1 + btn_h);
draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white); draw_set_alpha(1);
