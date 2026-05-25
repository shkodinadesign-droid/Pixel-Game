if (!variable_global_exists("fruit_states")) global.fruit_states = ds_map_create();
my_tree     = instance_nearest(x, y, obj_apple_tree_fruit);
regrow_days = 1;
depth       = -y - 10;
var _key = "apple_" + string(x) + "_" + string(y);
if (ds_map_exists(global.fruit_states, _key)) {
    var _d       = global.fruit_states[? _key];
    collected        = _d[0];
    collected_on_day = _d[1];
} else {
    collected        = false;
    collected_on_day = -1;
}
