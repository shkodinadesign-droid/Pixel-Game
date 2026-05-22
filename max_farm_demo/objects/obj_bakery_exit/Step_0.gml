// Выход из пекарни обратно на ферму
if (!global.control_locked) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 96 && keyboard_check_pressed(ord("E"))) {
            global.control_locked = true;
            // Вернуть игрока к двери пекарни на ферме
            if (variable_global_exists("return_spawn_x") && !is_undefined(global.return_spawn_x)) {
                global.next_spawn_x = global.return_spawn_x;
                global.next_spawn_y = global.return_spawn_y;
            } else {
                global.next_spawn_x = 752; // резервная позиция у входа в пекарню на ферме
                global.next_spawn_y = 208;
            }
            room_goto(rm_farm);
        }
    }
}
