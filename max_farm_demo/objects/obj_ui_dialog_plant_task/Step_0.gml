// ===== ДИАЛОГ: ЗАДАНИЕ ПОСАДКИ (STEP) =====

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
    if (!variable_global_exists("plant_quest_started")) global.plant_quest_started = false;
    global.plant_quest_started  = true;
    global.plant_task_shown     = true;
    global.diary_has_new        = true;
    global.diary_was_read       = false;
    global.control_locked       = false;
    instance_destroy();
}
