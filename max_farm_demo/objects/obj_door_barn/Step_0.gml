// Проверяем — ноги Макса рядом с дверью
var p = instance_nearest(x, y, obj_max);
if (p != noone) {
    var foot_cx = (p.bbox_left + p.bbox_right) * 0.5;
    var foot_y  = p.bbox_bottom;
    if (point_distance(x, y, foot_cx, foot_y) < 96) {
        if (keyboard_check_pressed(ord("E"))) {
            // запоминаем позицию для возврата
            global.return_spawn_x = p.x;
            global.return_spawn_y = p.y;
            room_goto(room_barn);
        }
    }
}
