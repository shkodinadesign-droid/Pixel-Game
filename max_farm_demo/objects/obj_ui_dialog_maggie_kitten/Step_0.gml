// ===== ДИАЛОГ МЭГГИ — КОТИК (STEP) =====

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
    if (dialog_step < 3) {
        var _next = dialog_step + 1;
        var _dlayer = layer_get_id("GUI");
        if (_dlayer == -1) _dlayer = layer_get_id("UI_hp");
        if (_dlayer == -1) _dlayer = layer_get_id("Instances_2");
        if (_dlayer == -1) _dlayer = layer;
        instance_destroy();
        var _new = instance_create_layer(0, 0, _dlayer, obj_ui_dialog_maggie_kitten);
        _new.dialog_step = _next;

        with (_new) {
            switch (dialog_step) {
                case 2:
                    speaker     = "Макс:";
                    line1       = "О тётушка Мэгги — как здорово!";
                    line2       = "Теперь мне не будет одиноко здесь! =)";
                    line3       = "";
                    speaker_col = make_color_rgb(255, 210, 100);
                    btn_label   = "Далее";
                    break;
                case 3:
                    speaker     = "Тётя Мэгги:";
                    line1       = "Я рада, моя дорогая девочка — мне пора!";
                    line2       = "Если что-то нужно — приходи ко мне в гости! =)";
                    line3       = "";
                    speaker_col = make_color_rgb(200, 140, 200);
                    btn_label   = "Пока!";
                    break;
            }
            var _lines = (line3 != "") ? 3 : ((line2 != "") ? 2 : 1);
            win_h  = 50 + _lines * 24 + 50;
            btn_y1 = win_y + win_h - btn_h - pad;
            btn_y2 = btn_y1 + btn_h;
        }
    } else {
        // Финал — Мэгги уходит, разблокируем управление
        instance_destroy();
        if (instance_exists(obj_maggie_day2)) {
            obj_maggie_day2.state = "leaving";
        }
        global.control_locked = false;
    }
}
