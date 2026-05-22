// === МАЙЛИ (STEP) ===
if (room != rm_farm) { visible = false; exit; }
depth = -bbox_bottom;

switch (state) {

    case "entering":
        // Выравниваем y по Максу когда она появляется
        if (instance_exists(obj_max)) {
            if (target_x == 0) {
                target_x = obj_max.x + 70;
                target_y = obj_max.y;
                y        = target_y;
                visible  = true;
            }
            // Обновляем цель если Макс двигается
            target_x = obj_max.x + 70;
            target_y = obj_max.y;
        }
        var _dist = point_distance(x, y, target_x, target_y);
        if (_dist > 8) {
            var _dir = point_direction(x, y, target_x, target_y);
            x = round(x + lengthdir_x(move_speed, _dir));
            y = round(y + lengthdir_y(move_speed, _dir));
            image_xscale = (cos(degtorad(_dir)) < 0) ? -1 : 1;
        } else {
            // Дошла — поворачиваем Макс навстречу
            if (instance_exists(obj_max)) {
                obj_max.sprite_index     = spr_max_idle_left;
                obj_max.direction_facing = "left";
                obj_max.image_speed      = 0;
                obj_max.image_index      = 0;
            }
            image_xscale           = -1;
            dlg_show               = true;
            dlg_step               = 1;
            dlg_click_prev         = mouse_check_button(mb_left);
            global.control_locked  = true;
            state                  = "talking";
        }
        break;

    case "talking":
        if (!dlg_show) break;

        var _gui_w  = display_get_gui_width();
        var _win_w  = 600;
        var _pad    = 14;
        var _line_h = 24;
        var _lines  = (dlg_step == 2) ? 1 : 2;
        var _win_h  = 50 + _lines * _line_h + 50;
        var _win_x  = (_gui_w - _win_w) / 2;
        var _win_y  = 20;
        var _btn_w  = 120;
        var _btn_h  = 30;
        var _btn_x1 = _win_x + _win_w - _btn_w - _pad;
        var _btn_y1 = _win_y + _win_h - _btn_h - _pad;
        var _btn_x2 = _btn_x1 + _btn_w;
        var _btn_y2 = _btn_y1 + _btn_h;

        var _mx  = device_mouse_x_to_gui(0);
        var _my  = device_mouse_y_to_gui(0);
        var _clk = mouse_check_button(mb_left);
        var _adv = (!dlg_click_prev && _clk &&
                    _mx >= _btn_x1 && _mx <= _btn_x2 &&
                    _my >= _btn_y1 && _my <= _btn_y2)
                 || keyboard_check_pressed(vk_return)
                 || keyboard_check_pressed(vk_space);
        dlg_click_prev = _clk;

        if (_adv) {
            if (dlg_step < 4) {
                dlg_step++;
                dlg_click_prev = mouse_check_button(mb_left);
            } else {
                // Финал — Майли уходит
                dlg_show              = false;
                global.control_locked = false;
                if (!variable_global_exists("miley_visited")) global.miley_visited = false;
                global.miley_visited  = true;
                state                 = "leaving";
            }
        }
        break;

    case "leaving":
        var _lx = room_width + 100;
        if (x < _lx) {
            x = round(x + move_speed);
            image_xscale = 1;
        } else {
            instance_destroy();
        }
        break;
}
