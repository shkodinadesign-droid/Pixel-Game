// ===== ОКНО ДОСКИ ОБЪЯВЛЕНИЙ (STEP) =====

if (open_delay > 0) { open_delay--; _click_prev = mouse_check_button(mb_left); exit; }

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Взять задание Ивана
var _q_hover = (qbtn_x1 >= 0 && mx >= qbtn_x1 && mx <= qbtn_x2 && my >= qbtn_y1 && my <= qbtn_y2);
if (_q_hover && click_press && !global.ivan_quest_started) {
    global.ivan_quest_started = true;
    // Дневник прыгает с "!" — новое задание
    global.diary_has_new  = true;
    global.diary_was_read = false;
    exit;
}

// Закрытие
var _c_hover = (point_distance(mx, my, close_cx, close_cy) <= close_r);
if ((_c_hover && click_press)
||  keyboard_check_pressed(ord("E"))
||  keyboard_check_pressed(vk_escape)) {
    global.control_locked = false;
    instance_destroy();
}
