depth = -bbox_bottom;

if (fruit_count <= 0 || !instance_exists(obj_max)) exit;

var _dist = point_distance(x, y, obj_max.x, obj_max.y);
if (_dist < 64 && keyboard_check_pressed(ord("E"))) {
    inventory_add(fruit_item, fruit_count);
    var _hud = instance_find(obj_ui_inventory, 0);
    if (_hud != noone) {
        var _icon = asset_get_index("spr_" + tree_type + "_icon");
        with (_hud) show_item_pop(_icon, "+" + string(other.fruit_count));
    }
    fruit_count = 0;
    tree_update_sprite();
    // Проверяем — собраны ли все фрукты со всех деревьев
    if (variable_global_exists("fruit_quest_started") && global.fruit_quest_started
    &&  !(variable_global_exists("fruit_quest_done") && global.fruit_quest_done)) {
        var _any_left = false;
        with (obj_fruit_tree) { if (fruit_count > 0) { _any_left = true; break; } }
        if (!_any_left) {
            global.fruit_quest_done       = true;
            global.show_fruit_done_popup  = true;
        }
    }
}
