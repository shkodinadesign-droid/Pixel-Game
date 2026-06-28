var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click_now   = mouse_check_button(mb_left);
var _click_press = (_click_now && !_click_prev);
_click_prev = _click_now;

// Автодиалог при первом входе
if (intro_timer > 0 && !global.control_locked) {
    intro_timer--;
    if (intro_timer == 0 && shop_state == 0) {
        shop_state = 1;
        global.control_locked = true;
        global.miley_first_visit_done = true;
    }
}

// Открыть диалог по E
if (shop_state == 0 && !global.control_locked && instance_exists(obj_max)) {
    if (point_distance(x, y, obj_max.x, obj_max.y) < 160
    &&  keyboard_check_pressed(ord("E"))) {
        shop_state = 1;
        global.control_locked = true;
    }
}

// Диалог (фазы 1-3)
if (shop_state >= 1 && shop_state <= 3) {
    var _gui_w = display_get_gui_width();
    dx = (_gui_w - dw) / 2;
    var _bx1 = dx + dw - btn_w - dpad;
    var _by1 = dy + dh - btn_h - dpad;
    var _bx2 = _bx1 + btn_w;
    var _by2 = _by1 + btn_h;

    var _advance = (_click_press && _mx >= _bx1 && _mx <= _bx2 && _my >= _by1 && _my <= _by2)
        || keyboard_check_pressed(vk_return)
        || keyboard_check_pressed(vk_space);

    if (_advance) {
        shop_state++;
        if (shop_state == 4) {
            _click_prev  = true;
            _click_press = false;
            rebuild_sell_items();
        }
    }
}

// Магазин (фаза 4)
if (shop_state == 4) {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E"))) {
        shop_state = 0;
        global.control_locked = false;
        exit;
    }
    if (_click_press && (_mx < shop_panel_x || _mx > shop_panel_x + shop_panel_w ||
                         _my < shop_panel_y || _my > shop_panel_y + shop_panel_h)) {
        shop_state = 0;
        global.control_locked = false;
        exit;
    }

    if (_click_press) {
        var _clicked = false;
        var _bar_y   = shop_panel_y + shop_panel_h - 62;
        var _arr_w   = 24; var _arr_h = 24;

        // === Левая сторона: клик по слоту магазина → выбрать для покупки ===
        for (var _r = 0; _r < shop_grid_rows; _r++) {
            for (var _c = 0; _c < shop_grid_cols; _c++) {
                var _idx = _r * shop_grid_cols + _c;
                var _sx  = shop_grid_x + _c * (shop_slot_size + shop_slot_gap);
                var _sy  = shop_grid_y + _r * (shop_slot_size + shop_slot_gap);
                if (_mx >= _sx && _mx <= _sx + shop_slot_size &&
                    _my >= _sy && _my <= _sy + shop_slot_size &&
                    _idx < array_length(shop_items)) {
                    shop_selected = _idx;
                    shop_buy_qty  = 1;
                    sell_selected = -1;
                    _clicked = true;
                }
            }
        }

        // === Правая сторона: клик по слоту продажи ===
        if (!_clicked) {
            for (var _r = 0; _r < shop_grid_rows; _r++) {
                for (var _c = 0; _c < shop_grid_cols; _c++) {
                    var _idx = _r * shop_grid_cols + _c;
                    var _sx  = shop_inv_x + _c * (shop_slot_size + shop_slot_gap);
                    var _sy  = shop_grid_y + _r * (shop_slot_size + shop_slot_gap);
                    if (_mx >= _sx && _mx <= _sx + shop_slot_size &&
                        _my >= _sy && _my <= _sy + shop_slot_size &&
                        _idx < array_length(sell_items)) {
                        sell_selected = _idx;
                        sell_qty      = 1;
                        shop_selected = -1;
                        _clicked = true;
                    }
                }
            }
        }

        // === Кнопки покупки (снизу слева) ===
        if (!_clicked && shop_selected >= 0) {
            var _item   = shop_items[shop_selected];
            var _bar_cx = shop_panel_x + shop_panel_w / 4;
            var _qty_y  = _bar_y + 16;

            if (_mx >= _bar_cx - 50 && _mx <= _bar_cx - 26 &&
                _my >= _qty_y && _my <= _qty_y + _arr_h) {
                shop_buy_qty = max(1, shop_buy_qty - 1);
            }
            if (_mx >= _bar_cx + 26 && _mx <= _bar_cx + 50 &&
                _my >= _qty_y && _my <= _qty_y + _arr_h) {
                shop_buy_qty++;
            }

            var _btn_x = shop_panel_x + shop_panel_w / 2 - 60;
            var _btn_w = 120; var _btn_h = 32;
            var _btn_y = _bar_y + 4;
            if (_mx >= _btn_x && _mx <= _btn_x + _btn_w &&
                _my >= _btn_y && _my <= _btn_y + _btn_h) {
                var _total = _item.price * shop_buy_qty;
                if (global.coins >= _total) {
                    global.coins -= _total;
                    inventory_add(_item.id, shop_buy_qty);
                    shop_selected = -1;
                    shop_buy_qty  = 1;
                    rebuild_sell_items();
                }
            }
        }

        // === Кнопки продажи (снизу справа) ===
        if (!_clicked && sell_selected >= 0) {
            var _sitem  = sell_items[sell_selected];
            var _bar_cx = shop_panel_x + shop_panel_w * 3 / 4;
            var _qty_y  = _bar_y + 16;

            if (_mx >= _bar_cx - 50 && _mx <= _bar_cx - 26 &&
                _my >= _qty_y && _my <= _qty_y + _arr_h) {
                sell_qty = max(1, sell_qty - 1);
            }
            if (_mx >= _bar_cx + 26 && _mx <= _bar_cx + 50 &&
                _my >= _qty_y && _my <= _qty_y + _arr_h) {
                sell_qty = min(inventory_get_amount(_sitem.id), sell_qty + 1);
            }

            var _btn_x = shop_panel_x + shop_panel_w - 140;
            var _btn_w = 120; var _btn_h = 32;
            var _btn_y = _bar_y + 4;
            if (_mx >= _btn_x && _mx <= _btn_x + _btn_w &&
                _my >= _btn_y && _my <= _btn_y + _btn_h) {
                if (inventory_get_amount(_sitem.id) >= sell_qty) {
                    inventory_remove(_sitem.id, sell_qty);
                    global.coins += _sitem.price * sell_qty;
                    var _cur = ds_map_find_value(global.miley_inventory, _sitem.id);
                    if (is_undefined(_cur)) _cur = 0;
                    ds_map_set(global.miley_inventory, _sitem.id, _cur + sell_qty);
                    sell_selected = -1;
                    sell_qty      = 1;
                }
            }
        }
    }
}
