var _click = mouse_check_button(mb_left);
var _press = (_click && !_click_prev);
_click_prev = _click;

if (_press || keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_escape)) {
    global.control_locked = false;
    instance_destroy();
}
