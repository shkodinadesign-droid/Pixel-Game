// ===== UI FRIDGE DRAW GUI =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Панель
draw_set_color(make_color_rgb(210, 230, 245));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, false);
draw_set_color(make_color_rgb(100, 140, 180));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, true);

// Разделитель по центру
draw_set_color(make_color_rgb(100, 140, 180));
draw_line(panel_x + panel_w / 2, panel_y + 10,
          panel_x + panel_w / 2, panel_y + panel_h - 10);

// Заголовки
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(40, 70, 110));
draw_text(panel_x + panel_w / 4,     panel_y + 16, "ХОЛОДИЛЬНИК");
draw_text(panel_x + panel_w * 3 / 4, panel_y + 16, "ИНВЕНТАРЬ");

// Сетка слотов
for (var _side = 0; _side < 2; _side++) {
    var _gx = (_side == 0) ? fridge_grid_x : player_grid_x;

    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            var _sx  = _gx    + _c * (slot_size + slot_gap_x);
            var _sy  = grid_y + _r * (slot_size + slot_gap);

            var _hover = (mx >= _sx && mx <= _sx + slot_size &&
                          my >= _sy && my <= _sy + slot_size);

            // Фон слота
            draw_set_color(_hover ? make_color_rgb(185, 215, 240) : make_color_rgb(165, 200, 230));
            draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, 6, 6, false);
            draw_set_color(make_color_rgb(100, 140, 180));
            draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, 6, 6, true);

            if (_idx < item_def_count) {
                var _def = item_defs[_idx];
                var _qty = (_side == 0) ? fridge_get_amount(_def.id)
                                        : inventory_get_amount(_def.id);

                // Иконка по центру ячейки
                var _alpha_slot = (_qty > 0) ? 1.0 : 0.3;
                draw_set_alpha(_alpha_slot);
                var _info_ic  = storage_get_item_info(_def.id);
                var _has_icon = (_info_ic != undefined && variable_struct_exists(_info_ic, "icon"));
                if (_has_icon) {
                    var _spr_ic  = _info_ic.icon;
                    var _icon_fit = slot_size - 10;
                    var _isc      = variable_struct_exists(_info_ic, "icon_scale") ? _info_ic.icon_scale : 1.0;
                    var _sw       = sprite_get_width(_spr_ic);
                    var _sh       = sprite_get_height(_spr_ic);
                    var _sc       = min(_icon_fit / _sw, _icon_fit / _sh) * _isc;
                    var _dw       = _sw * _sc;
                    var _dh       = _sh * _sc;
                    var _ccx      = _sx + slot_size / 2;
                    var _ccy      = _sy + slot_size / 2;
                    draw_sprite_stretched_ext(_spr_ic, 0,
                        _ccx - _dw / 2, _ccy - _dh / 2, _dw, _dh,
                        c_white, _alpha_slot);
                } else {
                    draw_set_color(_def.col);
                    draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 18, false);
                    draw_set_color(make_color_rgb(0, 0, 0));
                    draw_set_alpha(_alpha_slot * 0.15);
                    draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 18, true);
                }
                draw_set_alpha(1);

                // Количество — сверху справа внутри ячейки
                if (_qty > 0) {
                    draw_set_font(fnt_ui);
                    draw_set_halign(fa_right);
                    draw_set_valign(fa_top);
                    draw_set_color(make_color_rgb(30, 80, 140));
                    draw_text(_sx + slot_size - 3, _sy + 3, string(_qty));
                }

                // Название — под ячейкой
                draw_set_font(fnt_ui);
                draw_set_halign(fa_center);
                draw_set_valign(fa_top);
                draw_set_color(make_color_rgb(40, 70, 110));
                draw_text(_sx + slot_size / 2, _sy + slot_size + 3, _def.name);
            }
        }
    }
}

// Подсказки внизу
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(70, 110, 150));
draw_text(panel_x + panel_w / 4,     panel_y + panel_h - 10, "Клик — взять");
draw_text(panel_x + panel_w * 3 / 4, panel_y + panel_h - 10, "Клик — положить");

// Кнопка закрытия
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(70, 110, 150));
draw_text(panel_x + panel_w - 12, panel_y + 10, "[E] закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
