// ===== JUSTIN DAY 2 DIALOG — STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var hover = (mx >= btn_x1 && mx <= btn_x2 && my >= btn_y1 && my <= btn_y2);

var click_now   = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev     = click_now;

var advance = (hover && click_press)
           || keyboard_check_pressed(vk_enter)
           || keyboard_check_pressed(vk_space);

if (advance) {
    instance_destroy();

    if (!instance_exists(obj_justin_day2)) exit;

    switch (dialog_step) {
        case 3:
            // После реплики Джастина — реплика Макс (передать пирог)
            obj_justin_day2.cscene_step = 4;
            instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin_day2);
            break;
        case 4:
            // Макс передаёт пирог → запускаем анимацию передачи и монеты
            obj_justin_day2.cscene_step = 6;
            break;
        case 8:
            // Джастин прощается → уходит
            obj_justin_day2.cscene_step = 10;
            break;
    }
}
