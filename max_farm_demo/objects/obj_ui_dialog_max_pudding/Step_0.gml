// ===== MAX PUDDING DIALOG — STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev     = click_now;

var advance = (hover && click_press)
           || keyboard_check_pressed(vk_enter)
           || keyboard_check_pressed(vk_space)
           || keyboard_check_pressed(ord("E"));

if (advance) {
    inventory_add("pudding", 1);

    if (!variable_global_exists("pudding_ready")) global.pudding_ready = false;
    global.pudding_ready = true;

    global.control_locked = false;
    instance_destroy();
}
