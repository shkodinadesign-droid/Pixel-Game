// =====================
// MEGGI (STEP)
// =====================

// Динамическая глубина
depth = -bbox_bottom;

switch (state) {
    case "appearing":
        // Мэгги появилась сверху — идёт вниз к игроку
        sprite_index = spr_maggie_walk_down;
        image_speed = 0.15;
        state = "walking_to_player";
        break;

    case "walking_to_player":
        // Идём к игроку
        image_speed = 0.15;

        if (instance_exists(obj_max)) {
            // Цель - рядом с игроком (справа от него)
            target_x = obj_max.x + 40;
            target_y = obj_max.y;

            var dist = point_distance(x, y, target_x, target_y);

            if (dist > 8) {
                // Двигаемся к цели
                var dir = point_direction(x, y, target_x, target_y);
                x += lengthdir_x(move_speed, dir);
                y += lengthdir_y(move_speed, dir);

                // Выбираем спрайт ходьбы в зависимости от направления
                var ang = dir;
                if (ang >= 45 && ang < 135) {
                    sprite_index = spr_maggie_walk_up;
                } else if (ang >= 135 && ang < 225) {
                    sprite_index = spr_maggie_walk_left;
                } else if (ang >= 225 && ang < 315) {
                    sprite_index = spr_maggie_walk_down;
                } else {
                    sprite_index = spr_magiie_walk_right;
                }

                // Округляем для избежания ряби пикселей
                x = round(x);
                y = round(y);

                // Когда Мэгги близко - Макс поворачивается к ней и стоит
                if (dist < 80) {
                    obj_max.sprite_index = spr_max_idle_right;
                    obj_max.direction_facing = "right";
                    obj_max.image_speed = 0;
                    obj_max.image_index = 0;
                    obj_max.state = "idle";
                }
            } else {
                // Дошли - начинаем диалог
                state = "talking";

                // Мэгги стоит и смотрит на Макс (влево)
                sprite_index = spr_maggie_idle_left;
                image_speed = 0;

                // Макс смотрит на Мэгги (вправо)
                obj_max.sprite_index = spr_max_idle_right;
                obj_max.direction_facing = "right";
                obj_max.image_speed = 0;

                // Создаём диалоговое окно Мэгги
                var _lyr = layer_get_id("letter");
                if (_lyr == -1) _lyr = layer;
                instance_create_layer(0, 0, _lyr, obj_ui_letter_Maggie);
            }
        }
        break;

    case "talking":
        // Стоим и ждём пока диалог закончится
        image_speed = 0;
        break;

    case "leaving":
        // Уходим влево (в сторону сарая)
        var _leave_tx = -100;
        var _leave_ty = y;
        var _leave_d  = point_distance(x, y, _leave_tx, _leave_ty);
        if (_leave_d > 4) {
            var _leave_dir = point_direction(x, y, _leave_tx, _leave_ty);
            x += lengthdir_x(move_speed, _leave_dir);
            y += lengthdir_y(move_speed, _leave_dir);
            x = round(x);
            y = round(y);
            // Спрайт по направлению
            var _ang = _leave_dir;
            if (_ang >= 45 && _ang < 135) {
                sprite_index = spr_maggie_walk_up;
            } else if (_ang >= 135 && _ang < 225) {
                sprite_index = spr_maggie_walk_left;
            } else if (_ang >= 225 && _ang < 315) {
                sprite_index = spr_maggie_walk_down;
            } else {
                sprite_index = spr_magiie_walk_right;
            }
            image_speed = 0.15;
        } else {
            global.meggi_intro_done = true;
            instance_destroy();
        }
        break;

    case "idle":
        // Стоим на месте
        sprite_index = spr_maggie_idle_down;
        image_speed = 0;
        break;
}
