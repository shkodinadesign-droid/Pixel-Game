// ===== ДИАЛОГ: ПРИГОТОВИТЬ КОФЕ (STEP) =====

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _click_now = mouse_check_button(mb_left);

var _advance = (!_click_prev && _click_now &&
    _mx >= btn_x1 && _mx <= btn_x2 &&
    _my >= btn_y1 && _my <= btn_y2)
    || keyboard_check_pressed(vk_return)
    || keyboard_check_pressed(vk_space);
_click_prev = _click_now;

if (_advance) {
    var _lyr = layer_get_id("GUI");
    if (_lyr == -1) _lyr = layer_get_id("Instances_2");
    if (_lyr == -1) _lyr = layer;
    instance_create_layer(0, 0, _lyr, obj_ui_coffee_maker);
    instance_destroy();
    // control_locked остаётся — coffee_maker разблокирует сам
}
