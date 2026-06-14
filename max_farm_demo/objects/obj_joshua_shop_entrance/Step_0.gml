var p = instance_nearest(x, y, obj_max);
if (p != noone) {
    var foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
    var foot_y  = p.bbox_bottom;
    if (point_distance(x, y, foot_cx, foot_y) < 160) {
        near_player = true;
        if (keyboard_check_pressed(ord("E"))) {
            global.return_spawn_x = p.x;
            global.return_spawn_y = p.y + 32;
            global.next_spawn_x   = 320;
            global.next_spawn_y   = 320;
            room_goto(rm_joshua_shop);
        }
    } else {
        near_player = false;
    }
}
