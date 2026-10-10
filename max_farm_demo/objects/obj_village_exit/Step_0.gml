// Выход из деревни обратно на ферму (левый край rm_village)
if (global.control_locked) exit;

if (instance_exists(obj_max)) {
    var _dist = point_distance(x, y, obj_max.x, obj_max.y);
    if (_dist < 96) {
        near_player = true;
        if (keyboard_check_pressed(ord("E"))) {
            if (variable_global_exists("farm_return_x") && !is_undefined(global.farm_return_x)) {
                global.next_spawn_x = global.farm_return_x;
                global.next_spawn_y = global.farm_return_y;
            } else {
                global.next_spawn_x = 1200;
                global.next_spawn_y = 368;
            }
            room_goto(rm_farm);
        }
    } else {
        near_player = false;
    }
}
