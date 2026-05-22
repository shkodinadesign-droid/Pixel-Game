// ===== UI ЗАКАЗЫ STEP =====

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

// Клик по кнопке "Выполнить"
if (click_press) {
    var _count = array_length(global.daily_orders);
    for (var i = 0; i < _count; i++) {
        var _cy = cards_y + i * (card_h + card_pad);
        var _bx = panel_x + panel_w - btn_w - 12;
        var _by = _cy + (card_h - btn_h) / 2;
        if (mx >= _bx && mx <= _bx + btn_w &&
            my >= _by && my <= _by + btn_h) {
            orders_fulfill(i);
        }
    }
}
