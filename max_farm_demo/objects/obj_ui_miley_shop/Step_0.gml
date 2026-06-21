// ===== UI МАГАЗИН МАЙЛИ (STEP) =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("E"))) {
    global.control_locked = false;
    instance_destroy();
    exit;
}

if (click_press && (mx < panel_x || mx > panel_x + panel_w ||
                    my < panel_y || my > panel_y + panel_h)) {
    global.control_locked = false;
    instance_destroy();
    exit;
}

hover_item = -1;
for (var i = 0; i < array_length(shop_items); i++) {
    var _iy = panel_y + 60 + i * item_h;
    if (mx >= panel_x + pad && mx <= panel_x + panel_w - pad &&
        my >= _iy           && my <= _iy + item_h - 4) {
        hover_item = i;
        if (click_press) {
            var _item = shop_items[i];
            if (global.coins >= _item.price) {
                global.coins -= _item.price;
                inventory_add(_item.id, 1);
            }
        }
    }
}
