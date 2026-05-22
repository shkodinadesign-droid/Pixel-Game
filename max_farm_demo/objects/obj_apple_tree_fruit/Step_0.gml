depth = -bbox_bottom;

if (!instance_exists(obj_max)) exit;

// Считаем несобранные яблоки на этом дереве
var _apple_count = 0;
with (obj_apple_on_tree) {
    if (my_tree == other.id && !collected) _apple_count++;
}
has_fruit = (_apple_count > 0);

if (!has_fruit) exit;

var _cx = (bbox_left + bbox_right) * 0.5;
var _cy = (bbox_top + bbox_bottom) * 0.5;

if (point_distance(_cx, _cy, obj_max.x, obj_max.y) < 96
&&  keyboard_check_pressed(ord("E"))) {
    inventory_add(fruit_item, _apple_count);
    // Помечаем все яблоки этого дерева как собранные
    var _today = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 0;
    with (obj_apple_on_tree) {
        if (my_tree == other.id) {
            collected        = true;
            collected_on_day = _today;
        }
    }
    has_fruit = false;
    var _hud = instance_find(obj_ui_inventory, 0);
    if (_hud != noone) with (_hud) show_item_pop(spr_apple_icon, "+" + string(_apple_count));
}
