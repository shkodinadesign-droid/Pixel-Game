// Взаимодействие с сервантом — книги бабушки
var _near = false;

if (!global.control_locked && instance_exists(obj_max)) {
    var _dist = point_distance(x, y, obj_max.x, obj_max.y);
    _near = (_dist < 40);

    if (_near && keyboard_check_pressed(ord("E"))) {
        var _bcase_idx = asset_get_index("obj_ui_bookcase");
        if (_bcase_idx != -1 && !instance_exists(_bcase_idx)) {
            instance_create_layer(0, 0, "Instances", _bcase_idx);
        }
    }
}

show_hint = _near;
