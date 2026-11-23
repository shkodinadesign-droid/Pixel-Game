// ===== ТОБИ (STEP) =====
depth = -y;
var _gw  = display_get_gui_width();
var _dx  = (_gw - dlg_w) / 2;
var _bx1 = _dx + dlg_w - btn_w - dlg_pad, _by1 = dlg_y + dlg_h - btn_h - dlg_pad;
var _mx  = device_mouse_x_to_gui(0), _my = device_mouse_y_to_gui(0);
var _clk = mouse_check_button(mb_left);
var _adv = (!_click_prev && _clk && _mx >= _bx1 && _mx <= _bx1 + btn_w && _my >= _by1 && _my <= _by1 + btn_h)
        || keyboard_check_pressed(vk_return) || keyboard_check_pressed(vk_space);
_click_prev = _clk;

var _walk = function(_pts) {                       // шаг к текущей точке пути; true — путь пройден
    var _t = _pts[wp];
    if (point_distance(x, y, _t[0], _t[1]) > spd) {
        var _d = point_direction(x, y, _t[0], _t[1]);
        x = round(x + lengthdir_x(spd, _d)); y = round(y + lengthdir_y(spd, _d));
        if (abs(lengthdir_x(1, _d)) > 0.2) face = (lengthdir_x(1, _d) < 0) ? -1 : 1;
        move_v = abs(lengthdir_x(1, _d)) < 0.5;
        vdir   = (lengthdir_y(1, _d) < 0) ? -1 : 1;
        return false;
    }
    x = _t[0]; y = _t[1]; wp++;
    return (wp >= array_length(_pts));
};

switch (state) {
    case "enter":
        if (_walk(path_in)) {
            state = "talk"; dlg_i = 0; _click_prev = true;
            global.control_locked = true;
            if (instance_exists(obj_max)) {                       // Макс поворачивается к посетителю
                obj_max.sprite_index = spr_max_idle_up; obj_max.direction_facing = "up";
                obj_max.image_speed = 0; obj_max.image_index = 0;
            }
        }
        break;
    case "talk":
        if (_adv) {
            dlg_i++;
            if (dlg_i >= array_length(lines)) {
                if (visit == "order") {
                    global.toby_order_taken = true;               // задание в дневнике + рецепт пиццы
                    global.coins += 8;                            // аванс на колбасу
                    global.diary_has_new = true; global.diary_was_read = false;
                } else if (inventory_remove(ITEM_PIZZA, 1)) {
                    global.coins += 15;
                    global.toby_pizza_done = true;
                    global.diary_has_new = true; global.diary_was_read = false;
                }
                global.control_locked = false;
                state = "leave"; wp = 0;
            }
        }
        break;
    case "leave":
        if (_walk(path_out)) {
            if (visit == "order" && inventory_get_amount("pepperoni") < 1) {
                state = "note"; _click_prev = true; global.control_locked = true;
            } else instance_destroy();
        }
        break;
    case "note":
        if (_adv) { global.control_locked = false; instance_destroy(); }
        break;
}
