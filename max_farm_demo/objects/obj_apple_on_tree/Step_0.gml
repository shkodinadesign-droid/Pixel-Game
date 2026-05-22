if (!variable_instance_exists(id, "my_tree")) {
    my_tree          = instance_nearest(x, y, obj_apple_tree_fruit);
    collected        = false;
    collected_on_day = -1;
    regrow_days      = 1;
}

if (my_tree == noone || !instance_exists(my_tree)) {
    my_tree = instance_nearest(x, y, obj_apple_tree_fruit);
}

// Регенерация: яблоки вырастают на следующий день
if (collected && collected_on_day >= 0 && instance_exists(obj_day_controller)) {
    var _cur_day = obj_day_controller.day_index;
    if (_cur_day >= collected_on_day + regrow_days) {
        collected        = false;
        collected_on_day = -1;
    }
}

visible = !collected;
depth = (my_tree != noone && instance_exists(my_tree)) ? (my_tree.depth - 1) : -bbox_bottom;
