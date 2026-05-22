// ===== OBJ_FRIDGE STEP =====

if (!variable_global_exists("control_locked") || !global.control_locked) {
    if (instance_exists(obj_max)) {
        // Центр спрайта холодильника
        var _fx = (bbox_left + bbox_right) / 2;
        var _fy = (bbox_top  + bbox_bottom) / 2;
        var _dist = point_distance(_fx, _fy, obj_max.x, obj_max.y);

        // Приоритет: стол готовки и кофемашина ближе — холодильник не открываем
        var _dist_table = 9999;
        if (instance_exists(obj_cooking_table)) {
            var _ctx = (obj_cooking_table.bbox_left + obj_cooking_table.bbox_right) / 2;
            var _cty = (obj_cooking_table.bbox_top  + obj_cooking_table.bbox_bottom) / 2;
            _dist_table = point_distance(_ctx, _cty, obj_max.x, obj_max.y);
        }
        var _dist_coffee = 9999;
        if (instance_exists(obj_coffee_machine)) {
            _dist_coffee = point_distance(obj_coffee_machine.x, obj_coffee_machine.y, obj_max.x, obj_max.y);
        }

        if (_dist < 64 && _dist <= _dist_table && _dist <= _dist_coffee && keyboard_check_pressed(ord("E"))) {
            global.control_locked = true;
            instance_create_layer(0, 0, "Instances", obj_ui_fridge);
        }
    }
}
