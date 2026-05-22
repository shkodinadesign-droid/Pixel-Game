// Витрина — открыть UI витрины
if (!global.control_locked) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 48 && keyboard_check_pressed(ord("E"))) {
            global.control_locked = true;
            instance_create_layer(0, 0, "GUI", obj_ui_vitrina);
        }
    }
}
