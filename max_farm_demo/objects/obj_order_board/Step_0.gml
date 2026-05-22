// Доска заказов — только после того как Джастин зашёл и дал задание
if (!variable_global_exists("justin_bakery_intro_done")) global.justin_bakery_intro_done = false;
if (!global.justin_bakery_intro_done) exit;

if (!global.control_locked) {
    if (instance_exists(obj_max)) {
        var _cx   = (bbox_left + bbox_right) / 2;
        var _cy   = (bbox_top  + bbox_bottom) / 2;
        var _dist = point_distance(_cx, _cy, obj_max.x, obj_max.y);
        if (_dist < 64 && keyboard_check_pressed(ord("E"))) {
            global.control_locked = true;
            instance_create_layer(0, 0, "GUI", obj_ui_orders);
        }
    }
}
