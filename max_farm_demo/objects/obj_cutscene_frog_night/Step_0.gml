phase_timer++;
frog_anim++;

switch (phase) {

    case 0: // Темнеет — ночь наступает
        darkness = min(darkness + 0.012, 0.85);
        if (darkness >= 0.85) { phase = 1; phase_timer = 0; }
    break;

    case 1: // Макс автоматически идёт к двери дома
        if (instance_exists(obj_max)) {
            var _dist = point_distance(obj_max.x, obj_max.y, door_x, door_y);
            if (_dist > 10) {
                obj_max.x += (door_x - obj_max.x) / _dist * 2;
                obj_max.y += (door_y - obj_max.y) / _dist * 2;
            } else {
                obj_max.visible = false;
                phase = 2; phase_timer = 0;
            }
        } else {
            phase = 2; phase_timer = 0;
        }
    break;

    case 2: // Полное затемнение
        darkness = min(darkness + 0.04, 1);
        if (phase_timer > 60) { phase = 3; phase_timer = 0; text_alpha = 0; }
    break;

    case 3: // Перемотка времени "09:00 ☀"
        text_alpha = min(text_alpha + 0.04, 1);
        if (phase_timer > 150) {
            darkness  = 0.78;
            phase     = 4;
            phase_timer = 0;
        }
    break;

    case 4: // Лягушонок идёт справа к пуддингу (240, 430)
        if (x > 244) {
            x -= 1.8;
        } else {
            x = 240;
            phase = 5; phase_timer = 0;
        }
    break;

    case 5: // Лягушонок у пуддинга — забирает его
        if (phase_timer > 120) {
            global.pudding_on_porch = false;
            if (instance_exists(obj_pudding_icon)) obj_pudding_icon.visible = false;
            global.magic_map_placed = true;
            instance_create_depth(240, 430, 0, obj_frog_map);
            phase = 6; phase_timer = 0;
        }
    break;

    case 6: // Лягушонок уходит вправо
        x += 2;
        if (x > 960) { phase = 7; phase_timer = 0; }
    break;

    case 7: // Рассвет — экран светлеет
        darkness = max(darkness - 0.007, 0);
        if (darkness <= 0 && phase_timer > 60) { phase = 8; phase_timer = 0; }
    break;

    case 8: // Переход в дом — Макс просыпается
        if (phase_timer > 90) {
            global.frog_night_done = true;
            global.control_locked  = false;
            if (instance_exists(obj_max)) obj_max.visible = true;
            global.next_spawn_x = 96;
            global.next_spawn_y = 200;
            room_goto(rm_house_inside);
            instance_destroy();
        }
    break;
}
