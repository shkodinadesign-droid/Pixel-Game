// ===== UI CHEST DRAW GUI =====

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Панель
draw_set_color(make_color_rgb(240, 225, 190));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, false);
draw_set_color(make_color_rgb(160, 120, 70));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, true);

// Разделитель по центру
draw_set_color(make_color_rgb(160, 120, 70));
draw_line(panel_x + panel_w / 2, panel_y + 10,
          panel_x + panel_w / 2, panel_y + panel_h - 10);

// Заголовки
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(80, 50, 20));
draw_text(panel_x + panel_w / 4,       panel_y + 16, "ЯЩИК");
draw_text(panel_x + panel_w * 3 / 4,   panel_y + 16, "ИНВЕНТАРЬ");

// Вспомогательная функция отрисовки сетки
// side: 0 = ящик, 1 = инвентарь
var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

for (var _side = 0; _side < 2; _side++) {
    var _gx = (_side == 0) ? chest_grid_x : player_grid_x;

    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            var _sx  = _gx    + _c * (slot_size + slot_gap);
            var _sy  = grid_y + _r * (slot_size + slot_gap);

            // Hover
            var _hover = (mx >= _sx && mx <= _sx + slot_size &&
                          my >= _sy && my <= _sy + slot_size);

            // Фон слота
            draw_set_color(_hover ? make_color_rgb(230, 210, 170) : make_color_rgb(210, 190, 150));
            draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, 4, 4, false);
            draw_set_color(make_color_rgb(160, 120, 80));
            draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, 4, 4, true);

            // Предмет
            if (_idx < item_def_count) {
                var _def = item_defs[_idx];
                var _qty = (_side == 0) ? chest_get_amount(_def.id)
                                        : inventory_get_amount(_def.id);

                if (_qty > 0) {
                    if (sprite_exists(_def.spr)) {
                        // Иконка по центру (с учётом origin)
                        var _iw = sprite_get_width(_def.spr);
                        var _ih = sprite_get_height(_def.spr);
                        var _ox = sprite_get_xoffset(_def.spr);
                        var _oy = sprite_get_yoffset(_def.spr);
                        var _sc = min((slot_size - 8) / _iw, (slot_size - 8) / _ih);
                        draw_sprite_ext(_def.spr, 0,
                            _sx + slot_size / 2 - (_iw / 2 - _ox) * _sc,
                            _sy + slot_size / 2 - (_ih / 2 - _oy) * _sc,
                            _sc, _sc, 0, c_white, 1);
                    } else {
                        // Цветной круг-заглушка
                        draw_set_color(_def.col);
                        draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 14, false);
                        draw_set_color(make_color_rgb(0,0,0));
                        draw_set_alpha(0.15);
                        draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 14, true);
                        draw_set_alpha(1);
                    }

                    // Кружок с количеством
                    var _br = 7;
                    var _bx = _sx + slot_size;
                    var _by = _sy + slot_size;
                    draw_set_color(make_color_rgb(70, 40, 10));
                    draw_circle(_bx, _by, _br, false);
                    draw_set_font(fnt_ui);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_set_color(c_white);
                    draw_text(_bx, _by, string(_qty));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
            }
        }
    }
}

// Подсказки внизу
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(panel_x + panel_w / 4,     panel_y + panel_h - 10, "Клик — взять");
draw_text(panel_x + panel_w * 3 / 4, panel_y + panel_h - 10, "Клик — положить");

// Кнопка закрытия
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(160, 120, 70));
draw_text(panel_x + panel_w - 12, panel_y + 10, "[E] закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
