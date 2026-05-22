// ===== СЕКРЕТНАЯ ДВЕРЬ В ПЕКАРНЕ (STEP) =====

if (!instance_exists(obj_max)) exit;
if (!variable_global_exists("control_locked")) global.control_locked = false;

var _d = point_distance(x, y, obj_max.x, obj_max.y);

if (_d < 120 && !global.control_locked
    && keyboard_check_pressed(ord("E"))
    && !instance_exists(obj_ui_dialog_secret_door)) {
    global.control_locked = true;
    var _lyr = layer_get_id("GUI");
    if (_lyr == -1) _lyr = layer_get_id("Instances");
    if (_lyr == -1) _lyr = layer;
    instance_create_layer(0, 0, _lyr, obj_ui_dialog_secret_door);
}

