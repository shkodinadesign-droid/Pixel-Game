// ===== JUSTIN DAY 2 — STEP =====
depth = -bbox_bottom;

switch (cscene_step) {

    // --- Ждём Макс в комнате, запускаем таймер ---
    case 0:
        if (instance_exists(obj_max) && entry_timer < 0) {
            entry_timer = 300; // 5 секунд при 60fps
            cscene_step = 1;
        }
        break;

    // --- Отсчёт таймера ---
    case 1:
        if (entry_timer > 0) {
            entry_timer--;
        } else {
            // Пора входить!
            visible = true;
            global.control_locked = true;
            cscene_step = 2;
        }
        break;

    // --- Ходьба: spawn → wp1 → wp2 → counter ---
    case 2:
        var _tx, _ty;
        if (!wp1_reached) {
            _tx = wp1_x; _ty = wp1_y;
        } else if (!wp2_reached) {
            _tx = wp2_x; _ty = wp2_y;
        } else {
            _tx = counter_x; _ty = counter_y;
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

                // Макс смотрит на Джастина
                if (instance_exists(obj_max)) {
                    obj_max.sprite_index = spr_max_idle_up;
                    obj_max.image_speed  = 0;
                    obj_max.image_index  = 0;
                }

                cscene_step = 3;
                instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin_day2);
            }
        }
        break;

    // --- Диалоги 3, 4, 5 управляются obj_ui_dialog_justin_day2 ---
    case 3:
    case 4:
    case 5:
        break;

    // --- Передача пирога: убираем из инвентаря, даём монеты, анимация ---
    case 6:
        inventory_remove("potato_pie", 1);
        global.coins += 20;

        // Запускаем анимацию счётчика в HUD
        if (!variable_global_exists("coins_anim_target"))  global.coins_anim_target  = 0;
        if (!variable_global_exists("coins_anim_current")) global.coins_anim_current = 0;
        global.coins_anim_target  = global.coins;
        global.coins_anim_current = max(0, global.coins - 20);

        // Начало анимации пирога: от Макс к Джастину
        if (instance_exists(obj_max)) {
            pie_start_x = obj_max.x;
            pie_start_y = obj_max.y - 16;
        } else {
            pie_start_x = x + 48; pie_start_y = y;
        }
        pie_end_x = x;
        pie_end_y = y - 20;
        pie_anim_t = 0;

        cscene_step = 7;
        break;

    // --- Пирог летит, потом прощальный диалог ---
    case 7:
        if (pie_anim_t >= 0) {
            pie_anim_t += 0.05;
            if (pie_anim_t >= 1) {
                pie_anim_t = -1;
                // Прощальный диалог
                cscene_step = 8;
                instance_create_layer(0, 0, "GUI", obj_ui_dialog_justin_day2);
            }
        }
        break;

    // --- Прощальный диалог управляется dialog-объектом ---
    case 8:
    case 9:
        break;

    // --- Джастин уходит ---
    case 10:
        global.justin_day2_done = true;
        global.control_locked   = false;

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
