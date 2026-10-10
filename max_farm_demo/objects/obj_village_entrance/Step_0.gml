// Вход в центр деревни (правый край фермы)
var p = instance_nearest(x, y, obj_max);
if (p != noone) {
    var foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
    var foot_y  = p.bbox_bottom;
    if (point_distance(x, y, foot_cx, foot_y) < 160) {
        near_player = true;
        if (keyboard_check_pressed(ord("E"))) {
            // Отдельная точка возврата на ферму — return_spawn_* перезаписывается
            // магазином Майли в деревне, и Макс потом появлялась на ферме в чужих координатах
            global.farm_return_x  = p.x;
            global.farm_return_y  = p.y;
            global.next_spawn_x   = 96;
            global.next_spawn_y   = 368;
            room_goto(rm_village);
        }
    } else {
        near_player = false;
    }
}
