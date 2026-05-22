// =====================
// JUSTIN (STEP)
// =====================
depth = -bbox_bottom;

switch (cscene_step) {

    case 0:
        // Ждём триггера от витрины
        break;

    case 1:
        // Задержка перед входом
        if (entry_timer < 0) entry_timer = 240; // 4 секунды
        if (entry_timer > 0) {
            entry_timer--;
        } else {
            visible = true;
            cscene_step = 2;
        }
        break;

    case 2:
        // Джастин входит: wp1 → wp2 → counter
        var _tx, _ty;
        if (!wp1_reached) {
            _tx = wp1_x; _ty = wp1_y;
        } else if (!wp2_reached) {
            _tx = wp2_x; _ty = wp2_y;
        } else {
            _tx = counter_justin_x;
            _ty = counter_justin_y;
        }

        var _jd = point_distance(x, y, _tx, _ty);
        if (_jd > walk_spd) {
            var _jdir = point_direction(x, y, _tx, _ty);
            var _jdx  = lengthdir_x(walk_spd, _jdir);
            var _jdy  = lengthdir_y(walk_spd, _jdir);
            x = round(x + _jdx);
            y = round(y + _jdy);

            if (abs(_jdx) >= abs(_jdy)) {
                sprite_index = (_jdx > 0) ? spr_justin_idle_walk_rightt_strip4 : spr_justin_idle_walk_left_strip4;
            } else {
                sprite_index = (_jdy > 0) ? spr_justin_walk_down : spr_justin_idle_walk_up_strip4;
            }
            image_speed = 0.15;
        } else {
            x = _tx; y = _ty;
            if (!wp1_reached) {
                wp1_reached = true;
            } else if (!wp2_reached) {
                wp2_reached = true;
            } else {
                // Дошёл до прилавка — стоит спиной к игроку
                sprite_index = spr_justin_idle_walk_up_strip4;
                image_speed = 0;
                image_index = 0;
                cscene_step = 3;
                // Гарантируем что Макс смотрит на Джастина
                if (instance_exists(obj_max)) {
                    obj_max.direction_facing = "down";
                    obj_max.sprite_index = spr_max_idle_up;
                    obj_max.image_speed  = 0;
                    obj_max.image_index  = 0;
                }
                instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin);
            }
        }
        break;

    case 3:
    case 4:
    case 5:
        // Диалоговый UI управляет переходами
        break;

    case 6:
        // Сразу блокируем повторный запуск сцены
        global.justin_bakery_intro_done = true;
        global.diary_has_new  = true;
        global.diary_was_read = false;
        global.control_locked = false;
        // Уходит через те же путевые точки (обход мебели)
        var _lx, _ly;
        if (!leave_wp1_done) {
            _lx = leave_wp1_x; _ly = leave_wp1_y;
        } else if (!leave_wp2_done) {
            _lx = leave_wp2_x; _ly = leave_wp2_y;
        } else {
            _lx = 288; _ly = 820;
        }

        var _ld = point_distance(x, y, _lx, _ly);
        if (_ld > walk_spd) {
            var _ldir = point_direction(x, y, _lx, _ly);
            var _ldx  = lengthdir_x(walk_spd, _ldir);
            var _ldy  = lengthdir_y(walk_spd, _ldir);
            x = round(x + _ldx);
            y = round(y + _ldy);

            if (abs(_ldx) >= abs(_ldy)) {
                sprite_index = (_ldx > 0) ? spr_justin_idle_walk_rightt_strip4 : spr_justin_idle_walk_left_strip4;
            } else {
                sprite_index = (_ldy > 0) ? spr_justin_walk_down : spr_justin_idle_walk_up_strip4;
            }
            image_speed = 0.15;
        } else {
            x = _lx; y = _ly;
            if (!leave_wp1_done) {
                leave_wp1_done = true;
            } else if (!leave_wp2_done) {
                leave_wp2_done = true;
            } else {
                instance_destroy();
            }
        }
        break;
}
