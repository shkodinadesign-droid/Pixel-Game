// Проверяем — Макс касается двери
var p = instance_nearest(x, y, obj_max);
if (p != noone && point_distance(x, y, p.x, p.y) < 96) {
    // и жмёт стрелку вверх
    if (keyboard_check_pressed(ord("E"))) {
        // Сохраняем позицию спавна возле выхода из дома
        global.next_spawn_x = 192;  // x двери выхода
        global.next_spawn_y = 480;  // чуть выше двери
        room_goto(rm_house_inside);
    }
}


