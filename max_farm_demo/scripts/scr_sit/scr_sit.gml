// === ПОСАДКА МАКС (как в Stardew) ===
// Общая логика для мебели, на которую садятся лицом вперёд: стул (obj_chair), скамейка (obj_village2_bench).
// У объекта начало спрайта — низ по центру. Макс подходит спереди, [E] — прыжком садится на ближайшее место,
// сидит (дышит: spr_max_sit_down / spr_max_sit_down2), [E] или стрелка — спрыгивает туда, откуда садилась.
// Пока Макс сидит, obj_max.sit_chair = этот объект, и её собственный Step не работает.

/// @func sit_init(_seats, _seat_frac)
/// @param _seats      массив смещений центров мест по x от начала объекта, напр. [0] или [-16, 16]
/// @param _seat_frac  высота сиденья от верха спрайта, доля (0.62 — попа на 62% высоты)
function sit_init(_seats, _seat_frac) {
    sit_seats  = _seats;
    sit_state  = "none";          // none / down / sit / up
    sit_t      = 0;
    sit_stand_x = 0; sit_stand_y = 0;
    sit_seat_x  = 0;
    sit_seat_y  = (y - sprite_yoffset + round(sprite_height * _seat_frac)) - 44;   // спрайт Макс 32x48, начало 0,0
    sit_hop     = room_speed * 0.35;
}

/// Индекс места, перед которым стоит Макс (-1 — не перед объектом)
function sit_front_seat() {
    if (!instance_exists(obj_max)) return -1;
    var _mx = (obj_max.bbox_left + obj_max.bbox_right) * 0.5;
    var _my = obj_max.bbox_bottom;
    if (_my < y - 2 || _my > y + 22) return -1;
    var _best = -1, _bd = 16;
    for (var i = 0; i < array_length(sit_seats); i++) {
        var _d = abs(_mx - (x + sit_seats[i]));
        if (_d < _bd) { _bd = _d; _best = i; }
    }
    return _best;
}

function sit_step() {
    if (!instance_exists(obj_max)) return;
    var _m = obj_max;
    switch (sit_state) {
        case "none":
            if (_m.sit_chair == noone && !global.control_locked && keyboard_check_pressed(ord("E"))) {
                var _s = sit_front_seat();
                if (_s >= 0) {
                    sit_stand_x = _m.x; sit_stand_y = _m.y;
                    sit_seat_x  = x + sit_seats[_s] - 16;
                    _m.sit_chair = id;
                    _m.direction_facing = "down";
                    sit_state = "down"; sit_t = 0;
                }
            }
            return;

        case "down":                                   // прыжок на сиденье
            sit_t++;
            var _k = min(1, sit_t / sit_hop);
            _m.x = round(lerp(sit_stand_x, sit_seat_x, _k));
            _m.y = round(lerp(sit_stand_y, sit_seat_y, _k) - sin(_k * pi) * 6);
            _m.sprite_index = (_k < 0.5) ? spr_max_idle_down : spr_max_sit_down;
            if (sit_t >= sit_hop + room_speed * 0.08) { sit_state = "sit"; sit_t = 0; }
            else if (_k >= 1) _m.y = sit_seat_y + 1;   // мягкая посадка: на миг чуть ниже
            break;

        case "sit":                                    // сидит и дышит
            sit_t++;
            _m.x = sit_seat_x; _m.y = sit_seat_y;
            _m.sprite_index = ((sit_t mod round(room_speed * 2.2)) > room_speed * 1.8) ? spr_max_sit_down2 : spr_max_sit_down;
            if (!global.control_locked && sit_t > 5
            && (keyboard_check_pressed(ord("E")) || keyboard_check_pressed(vk_up) || keyboard_check_pressed(vk_down)
             || keyboard_check_pressed(vk_left) || keyboard_check_pressed(vk_right))) {
                sit_state = "up"; sit_t = 0;
            }
            break;

        case "up":                                     // спрыгивает обратно
            sit_t++;
            var _k2 = min(1, sit_t / sit_hop);
            _m.x = round(lerp(sit_seat_x, sit_stand_x, _k2));
            _m.y = round(lerp(sit_seat_y, sit_stand_y, _k2) - sin(_k2 * pi) * 6);
            _m.sprite_index = (_k2 < 0.5) ? spr_max_sit_down : spr_max_idle_down;
            if (_k2 >= 1) {
                _m.x = sit_stand_x; _m.y = sit_stand_y;
                _m.sit_chair = noone;
                _m.state = "idle";
                sit_state = "none";
            }
            break;
    }
    with (_m) { image_speed = 0; image_index = 0; }
    _m.depth = depth - 1;                              // поверх сиденья
}

/// Подсказки «[E] Сесть» / «[E] Встать» (вызывать в Draw после draw_self)
function sit_draw_hint() {
    if (!instance_exists(obj_max) || global.control_locked) return;
    if (sit_state == "none" && obj_max.sit_chair == noone) {
        var _s = sit_front_seat();
        if (_s >= 0) draw_hint("[E] Сесть", x + sit_seats[_s], y - sprite_yoffset, true);
    } else if (sit_state == "sit" && sit_t < room_speed * 3) {
        draw_hint("[E] Встать", sit_seat_x + 16, sit_seat_y + 4, true);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
