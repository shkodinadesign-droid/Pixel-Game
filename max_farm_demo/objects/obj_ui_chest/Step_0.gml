// ===== UI CHEST STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Закрытие по ESC или E
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E"))) {
    global.control_locked = false;
    instance_destroy();
    exit;
}

// Закрытие по клику вне панели
if (click_press) {
    if (mx < panel_x || mx > panel_x + panel_w ||
        my < panel_y || my > panel_y + panel_h) {
        global.control_locked = false;
        instance_destroy();
        exit;
    }
}

// Клик по слоту ящика → перекладываем в инвентарь игрока
if (click_press) {
    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            var _sx  = chest_grid_x + _c * (slot_size + slot_gap);
            var _sy  = grid_y       + _r * (slot_size + slot_gap);
            if (mx >= _sx && mx <= _sx + slot_size &&
                my >= _sy && my <= _sy + slot_size) {
                if (_idx < item_def_count) {
                    var _id  = item_defs[_idx].id;
                    if (chest_get_amount(_id) > 0) {
                        chest_remove(_id, 1);
                        inventory_add(_id, 1);
                    }
                }
            }
        }
    }

    // Клик по слоту инвентаря → перекладываем в ящик
    for (var _r = 0; _r < grid_rows; _r++) {
        for (var _c = 0; _c < grid_cols; _c++) {
            var _idx = _r * grid_cols + _c;
            var _sx  = player_grid_x + _c * (slot_size + slot_gap);
            var _sy  = grid_y        + _r * (slot_size + slot_gap);
            if (mx >= _sx && mx <= _sx + slot_size &&
                my >= _sy && my <= _sy + slot_size) {
                if (_idx < item_def_count) {
                    var _id  = item_defs[_idx].id;
                    if (inventory_get_amount(_id) > 0) {
                        inventory_remove(_id, 1);
                        chest_add(_id, 1);
                    }
                }
            }
        }
    }
}
