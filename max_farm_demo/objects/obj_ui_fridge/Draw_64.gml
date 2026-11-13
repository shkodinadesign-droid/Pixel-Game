// ===== UI FRIDGE DRAW GUI (голубая книга spr_fridge_bg и ячейки spr_ui_fridge_*) =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var _txt_dark = make_color_rgb(30, 60, 95);
var _txt_mid  = make_color_rgb(70, 105, 140);

// Затемнение фона
draw_set_alpha(0.5);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Книга
draw_sprite(spr_fridge_bg, 0, panel_x, panel_y);

// Крестик
var _cl_hover = (mx >= close_x && mx < close_x + 30 && my >= close_y && my < close_y + 30);
draw_sprite(_cl_hover ? spr_ui_fridge_close_hover : spr_ui_fridge_close_normal, 0, close_x, close_y);

// Заголовки — в табличках
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_txt_dark);
draw_text(fridge_cx, title_y, "Холодильник");
draw_text(player_cx, title_y, "Инвентарь");

for (var _side = 0; _side < 2; _side++) {
    var _gx = (_side == 0) ? fridge_grid_x : player_grid_x;

    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            if (_idx >= item_def_count) continue;
            var _sx  = _gx    + _c * slot_step_x;
            var _sy  = grid_y + _r * slot_step_y;
            var _def = item_defs[_idx];
            var _qty = (_side == 0) ? fridge_get_amount(_def.id) : inventory_get_amount(_def.id);
            var _hover = (mx >= _sx && mx < _sx + slot_size && my >= _sy && my < _sy + slot_size);

            var _spr = (_qty > 0) ? (_hover ? spr_ui_fridge_slot_hover : spr_ui_fridge_slot_item) : spr_ui_fridge_slot_empty;
            draw_sprite(_spr, 0, _sx, _sy);

            // Иконка по центру ячейки (бледная, если пусто); 32x32 — 1:1
            var _alpha_slot = (_qty > 0) ? 1.0 : 0.3;
            var _info_ic = storage_get_item_info(_def.id);
            if (_info_ic != undefined && variable_struct_exists(_info_ic, "icon") && sprite_exists(_info_ic.icon)) {
                var _ic  = _info_ic.icon;
                var _iw  = sprite_get_width(_ic), _ih = sprite_get_height(_ic);
                var _sc  = (max(_iw, _ih) <= 40) ? 1 : 36 / max(_iw, _ih);
                if (variable_struct_exists(_info_ic, "icon_scale")) _sc *= _info_ic.icon_scale;
                draw_sprite_ext(_ic, 0, _sx + (slot_size - _iw * _sc) / 2 + sprite_get_xoffset(_ic) * _sc,
                                _sy + (slot_size - _ih * _sc) / 2 + sprite_get_yoffset(_ic) * _sc, _sc, _sc, 0, c_white, _alpha_slot);
            } else {
                draw_set_alpha(_alpha_slot);
                draw_set_color(_def.col);
                draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 14, false);
                draw_set_alpha(1);
            }

            // Бейдж с количеством
            if (_qty > 0) {
                draw_sprite(spr_ui_fridge_count_badge, 0, _sx + slot_size - 12, _sy + slot_size - 12);
                draw_set_font(fnt_ui);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_sx + slot_size - 4, _sy + slot_size - 4, string(_qty));
            }

            // Название — под ячейкой
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(_txt_dark);
            draw_text(_sx + slot_size / 2, _sy + slot_size + 8, _def.name);
        }
    }
}

// Подсказки внизу страниц
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_txt_mid);
draw_text(fridge_cx, hint_y, "Клик - взять");
draw_text(player_cx, hint_y, "Клик - положить");
draw_text(player_cx, panel_y + 343, "[E] закрыть");

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
