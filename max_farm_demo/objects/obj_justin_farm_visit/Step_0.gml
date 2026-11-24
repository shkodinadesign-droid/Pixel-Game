// ===== ДЖАСТИН НА ФЕРМЕ (STEP) =====
depth = -(y + 56);
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
        var _vx = lengthdir_x(1, _d), _vy = lengthdir_y(1, _d);
        if (abs(_vx) >= abs(_vy)) face = (_vx < 0) ? "left" : "right";
        else                      face = (_vy < 0) ? "up" : "down";
        moving = true;
        return false;
    }
    x = _t[0]; y = _t[1]; wp++;
    return (wp >= array_length(_pts));
};
var _max_face = function(_dir) {                   // Макс поворачивается к Джастину
    if (!instance_exists(obj_max)) return;
    obj_max.direction_facing = _dir;
    obj_max.image_speed = 0; obj_max.image_index = 0;
    switch (_dir) {
        case "left":  obj_max.sprite_index = spr_max_idle_left;  break;
        case "right": obj_max.sprite_index = spr_max_idle_right; break;
        case "up":    obj_max.sprite_index = spr_max_idle_up;    break;
        default:      obj_max.sprite_index = spr_max_idle_down;
    }
};

moving = false;
switch (state) {
    case "enter":
        if (wp == 0 && dlg_i == 0) {                              // Макс замирает, пока он подходит
            global.control_locked = true;
            global.clock_paused   = true;
        }
        if (_walk(path_in)) {
            state = "talk"; dlg_i = 0; pause_t = 0; _click_prev = true;
            face = (side > 0) ? "left" : "right";
            _max_face((side > 0) ? "right" : "left");
        }
        break;

    case "talk":
        var _ln = lines[dlg_i];
        if (_ln[0] == "~") {                                      // пауза без окна
            look = _ln[2];
            pause_t++;
            if (pause_t >= _ln[1]) { pause_t = 0; look = ""; dlg_i++; _click_prev = true; }
        } else if (_adv) {
            dlg_i++;
        }
        if (dlg_i >= array_length(lines)) {
            global.justin_farm_talk_done = true;                  // разговор состоялся (один раз)
            global.control_locked = false;
            global.clock_paused   = false;
            state = "leave"; wp = 0;
        }
        break;

    case "leave":
        if (_walk(path_out)) instance_destroy();
        break;
}
