// Выход из сарая
if (instance_exists(obj_max)) {
    var _dist = point_distance(x, y, obj_max.x, obj_max.y);
    if (_dist < 96 && keyboard_check_pressed(ord("E"))) {
        room_goto(rm_farm);
    }
}
