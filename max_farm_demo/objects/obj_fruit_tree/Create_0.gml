// tree_type задаётся в редакторе комнаты: "apple" | "pear" | "peach"
if (!variable_instance_exists(id, "tree_type")) tree_type = "apple";

stage          = 2;   // 0=саженец, 1=молодое, 2=взрослое (стартуем взрослым)
days_grown     = 0;
days_per_stage = 2;
// На день 2+ дерево уже взрослое и с фруктами
var _dc = instance_find(obj_day_controller, 0);
fruit_count = (_dc != noone && _dc.day_index >= 2) ? 3 : 0;

switch (tree_type) {
    case "apple": fruit_item = ITEM_APPLE; break;
    case "pear":  fruit_item = ITEM_PEAR;  break;
    case "peach": fruit_item = ITEM_PEACH; break;
    default:      fruit_item = ITEM_APPLE;
}

function tree_update_sprite() {
    var _name = "";
    if (stage == 0) {
        _name = "spr_fruit_tree_sapling";
    } else if (stage == 1) {
        _name = "spr_fruit_tree_young";
    } else {
        _name = (fruit_count > 0) ? ("spr_fruit_tree_" + tree_type + "_fruit")
                                  : ("spr_fruit_tree_" + tree_type);
    }
    var _spr = asset_get_index(_name);
    if (_spr == -1) _spr = asset_get_index("spr_trees_1");
    if (_spr != -1) sprite_index = _spr;
    image_speed = 0;
    image_index = 0;
}
tree_update_sprite();
