// ===== OBJ_COOKING_TABLE STEP =====

if (!variable_global_exists("justin_bakery_intro_done")) global.justin_bakery_intro_done = false;

// Пекарня доступна только после визита Джастина с заданием
if (!global.justin_bakery_intro_done) exit;

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        var _ctx  = (bbox_left + bbox_right) / 2;
        var _cty  = (bbox_top  + bbox_bottom) / 2;
        var _dist = point_distance(_ctx, _cty, obj_max.x, obj_max.y);

        var _dist_fridge = 9999;
        if (instance_exists(obj_fridge)) {
            var _frx = (obj_fridge.bbox_left + obj_fridge.bbox_right) / 2;
            var _fry = (obj_fridge.bbox_top  + obj_fridge.bbox_bottom) / 2;
            _dist_fridge = point_distance(_frx, _fry, obj_max.x, obj_max.y);
        }

        if (_dist < 96 && _dist < _dist_fridge && keyboard_check_pressed(ord("E"))) {
            global.control_locked = true;
            instance_create_layer(0, 0, "Instances", obj_ui_bakery);
        }
    }
}
