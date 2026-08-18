depth = -y;

// Прозрачность только когда Макс ВЫШЕ ствола (сзади дерева)
if (instance_exists(obj_max)) {
    var _stump_y = y;  // основание дерева = позиция объекта
    var _in_x    = obj_max.x > x - 40 && obj_max.x < x + 40;
    if (obj_max.y < _stump_y && _in_x) {
        image_alpha = 0.4;
    } else {
        image_alpha = 1;
    }
} else {
    image_alpha = 1;
}

if (!instance_exists(obj_max)) exit;

// Считаем несобранные яблоки
var _apple_count = 0;
with (obj_apple_on_tree) {
    if (my_tree == other.id && !collected) _apple_count++;
}
has_fruit = (_apple_count > 0);

if (!has_fruit) exit;

if (point_distance(x, y, obj_max.x, obj_max.y) < 96
&&  keyboard_check_pressed(ord("E"))) {
    var _today = instance_exists(obj_day_controller) ? obj_day_controller.day_index : 0;
    var _picked = noone;
    with (obj_apple_on_tree) {
        if (my_tree == other.id && !collected) {
            _picked = id;
            break;
        }
    }
    if (_picked != noone) {
        _picked.collected        = true;
        _picked.collected_on_day = _today;
        if (!variable_global_exists("fruit_states")) global.fruit_states = ds_map_create();
        global.fruit_states[? "apple_" + string(_picked.x) + "_" + string(_picked.y)] = [true, _today];
        inventory_add(fruit_item, 1);
        var _hud = instance_find(obj_ui_inventory, 0);
        if (_hud != noone) with (_hud) show_item_pop(spr_apple_icon, "+1");
    }
}
