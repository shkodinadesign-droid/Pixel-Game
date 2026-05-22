// Выход из дома — ноги Макса рядом с ковром + E
if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 64 && keyboard_check_pressed(ord("E"))) {
            global.next_spawn_x = 512;
            global.next_spawn_y = 256;
            room_goto(rm_farm);
        }
    }
}
