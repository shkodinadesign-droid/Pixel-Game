if (say_timer > 0) say_timer--;

if (!global.control_locked && instance_exists(obj_max)) {
    if (point_distance(x, y, obj_max.x, obj_max.y) < 80
    &&  keyboard_check_pressed(ord("E"))) {
        say_timer = 150;
    }
}
