if (!variable_instance_exists(id, "my_tree")) {
    if (!variable_global_exists("fruit_states")) global.fruit_states = ds_map_create();
    my_tree      = instance_nearest(x, y, obj_pear_tree);
    regrow_days  = 2;
    image_xscale = 27/24;
    image_yscale = 27/24;
    var _key = "pear_" + string(x) + "_" + string(y);
    if (ds_map_exists(global.fruit_states, _key)) {
        var _d       = global.fruit_states[? _key];
        collected        = _d[0];
        collected_on_day = _d[1];
    } else {
        collected        = false;
        collected_on_day = -1;
    }
}
if (my_tree == noone || !instance_exists(my_tree)) {
    my_tree = instance_nearest(x, y, obj_pear_tree);
}

// Регенерация: груши вырастают через 2 дня
if (collected && collected_on_day >= 0 && instance_exists(obj_day_controller)) {
    var _cur_day = obj_day_controller.day_index;
    if (_cur_day >= collected_on_day + regrow_days) {
        collected        = false;
        collected_on_day = -1;
        if (variable_global_exists("fruit_states"))
            ds_map_delete(global.fruit_states, "pear_" + string(x) + "_" + string(y));
    }
}

visible = !collected;
depth = (my_tree != noone && instance_exists(my_tree)) ? (my_tree.depth - 1) : -bbox_bottom;
