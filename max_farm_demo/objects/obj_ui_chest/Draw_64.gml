// ===== UI CHEST DRAW GUI (подложка-книга spr_storage_bg и ячейки дневника spr_ui_*) =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Книга
draw_sprite(spr_storage_bg, 0, panel_x, panel_y);

// Крестик
var _cl_hover = (mx >= close_x && mx < close_x + 30 && my >= close_y && my < close_y + 30);
draw_sprite(_cl_hover ? spr_ui_close_hover : spr_ui_close_normal, 0, close_x, close_y);

// Заголовки — в табличках
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(70, 40, 15));
draw_text(chest_cx,  title_y, "Ящик");
draw_text(player_cx, title_y, "Инвентарь");

// side: 0 = ящик, 1 = инвентарь
for (var _side = 0; _side < 2; _side++) {
    var _gx = (_side == 0) ? chest_grid_x : player_grid_x;

    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            var _sx  = _gx    + _c * (slot_size + slot_gap);
            var _sy  = grid_y + _r * (slot_size + slot_gap);
            var _hover = (mx >= _sx && mx < _sx + slot_size && my >= _sy && my < _sy + slot_size);

            var _qty = 0;
            if (_idx < item_def_count) {
                _qty = (_side == 0) ? chest_get_amount(item_defs[_idx].id) : inventory_get_amount(item_defs[_idx].id);
            }
            var _spr = (_qty > 0) ? (_hover ? spr_ui_inventory_slot_hover : spr_ui_inventory_slot_item) : spr_ui_inventory_slot_empty;
            draw_sprite(_spr, 0, _sx, _sy);

            if (_qty > 0) {
                var _def = item_defs[_idx];
                if (sprite_exists(_def.spr)) {
                    // Иконка по центру (с учётом origin); 32x32 — 1:1
                    var _iw = sprite_get_width(_def.spr);
                    var _ih = sprite_get_height(_def.spr);
                    var _sc = (max(_iw, _ih) <= 40) ? 1 : 36 / max(_iw, _ih);
                    draw_sprite_ext(_def.spr, 0,
                        _sx + (slot_size - _iw * _sc) / 2 + sprite_get_xoffset(_def.spr) * _sc,
                        _sy + (slot_size - _ih * _sc) / 2 + sprite_get_yoffset(_def.spr) * _sc,
                        _sc, _sc, 0, c_white, 1);
                } else {
                    draw_set_color(_def.col);
                    draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 14, false);
                }

                // Бейдж с количеством
                draw_sprite(spr_ui_count_badge, 0, _sx + slot_size - 12, _sy + slot_size - 12);
                draw_set_font(fnt_ui);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_sx + slot_size - 4, _sy + slot_size - 4, string(_qty));
            }
        }
    }
}

// Подсказки внизу страниц
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(chest_cx,  hint_y, "Клик - взять");
draw_text(player_cx, hint_y, "Клик - положить");
draw_text(player_cx, panel_y + 343, "[E] закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
