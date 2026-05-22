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
}
