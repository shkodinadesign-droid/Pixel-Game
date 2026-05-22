// ===== UI ВИТРИНА STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Закрытие по E или ESC
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

// Клик по кнопке "Забрать монеты"
if (click_press && global.coins_pending > 0) {
    if (mx >= btn_x && mx <= btn_x + btn_w &&
        my >= btn_y && my <= btn_y + btn_h) {
        vitrina_collect_coins();
    }
}

// Клик по предмету инвентаря → добавить 1 на витрину
if (click_press) {
    var _half_w = panel_w / 2 - 24;
    var _key = ds_map_find_first(global.player_inventory);
    var _idx = 0;
    while (_key != undefined) {
        var _amt = ds_map_find_value(global.player_inventory, _key);
        if (_amt > 0) {
            var _iy = inv_list_y + _idx * item_h;
            if (_iy + item_h <= panel_y + panel_h - 50) {
                if (mx >= inv_list_x && mx <= inv_list_x + _half_w &&
                    my >= _iy && my <= _iy + item_h - 2) {
                    vitrina_add(_key, 1);
                }
            }
            _idx++;
        }
        _key = ds_map_find_next(global.player_inventory, _key);
    }
}
