// ===== КОФЕМАШИНА (STEP) =====

if (room != rm_bakery) exit;
depth = -bbox_bottom;

if (instance_exists(obj_max)) {
    var _d = point_distance(x, y, obj_max.x, obj_max.y);

    if (_d < 100 && !global.control_locked
        && keyboard_check_pressed(ord("E"))
        && !instance_exists(obj_ui_coffee_maker)) {
        global.control_locked = true;
        var _lyr = layer_get_id("GUI");
        if (_lyr == -1) _lyr = layer_get_id("Instances_2");
        if (_lyr == -1) _lyr = layer;
        instance_create_layer(0, 0, _lyr, obj_ui_coffee_maker);
    }
}
