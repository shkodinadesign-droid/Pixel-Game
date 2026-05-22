// ===== JUSTIN DIALOG — STEP =====

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

    if (!instance_exists(obj_justin)) exit;

    switch (dialog_step) {
        case 3:
            // После реплики Джастина — шаг 4 (реплика Макс)
            obj_justin.cscene_step = 4;
            instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin);
            break;
        case 4:
            // После реплики Макс — прощальная реплика Джастина
            obj_justin.cscene_step = 5;
            instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin);
            break;
        case 5:
            // После прощания — Джастин уходит
            obj_justin.cscene_step = 6;
            break;
    }
}
