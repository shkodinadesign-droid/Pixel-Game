// ===== CARPET EXIT STEP =====
if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 64 && keyboard_check_pressed(ord("E"))) {

            // Определяем комнату назначения по текущей комнате
            if (room == rm_house_inside) {
                global.next_spawn_x = 512;
                global.next_spawn_y = 256;
                room_goto(rm_farm);

            } else if (room == rm_bakery) {
                if (variable_global_exists("return_spawn_x") && !is_undefined(global.return_spawn_x)) {
                    global.next_spawn_x = global.return_spawn_x;
                    global.next_spawn_y = global.return_spawn_y;
                } else {
                    global.next_spawn_x = 752;
                    global.next_spawn_y = 208;
                }
                room_goto(rm_farm);

            } else if (room == rm_barn) {
                room_goto(rm_farm);
            }

        }
    }
}
