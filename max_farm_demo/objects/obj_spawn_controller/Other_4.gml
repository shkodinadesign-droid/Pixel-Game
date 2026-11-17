/// obj_spawn_controller : Room Start
// Здесь уже ВСЕ инстансы комнаты существуют — безопасное место для установки позиции игрока.

var p = instance_find(obj_max, 0);
if (p != noone) {
    var placed = false;

    // 1) Спавн по ТЕГУ (если задан)
    if (variable_global_exists("next_spawn_tag") && !is_undefined(global.next_spawn_tag)) {
        var spawn_inst = noone;
        with (obj_spawn) {
            if (tag == global.next_spawn_tag) {
                other.spawn_inst = id; // передадим ссылку наружу
            }
        }
        if (spawn_inst != noone) {
            p.x = spawn_inst.x;
            p.y = spawn_inst.y;
            placed = true;
        }
    }

    // 2) Спавн по КООРДИНАТАМ (если заданы и тега нет/не нашли)
    if (!placed
    && variable_global_exists("next_spawn_x") && !is_undefined(global.next_spawn_x)
    && variable_global_exists("next_spawn_y") && !is_undefined(global.next_spawn_y)) {
        p.x = global.next_spawn_x;
        p.y = global.next_spawn_y;
        placed = true;
    }

    // Выталкиваем из солидов: ищем ближайшую свободную точку по расширяющимся кольцам.
    // Проверка через with(p) — place_meeting берёт маску вызывающего инстанса (Макс, а не контроллера)
    with (p) {
        if (place_meeting(x, y, obj_solid)) {
            var _sx = x, _sy = y;
            var _found = false;
            for (var _r = 4; _r <= 160 && !_found; _r += 4) {
                for (var _a = 0; _a < 360; _a += 15) {
                    var _tx = round(_sx + lengthdir_x(_r, _a));
                    var _ty = round(_sy + lengthdir_y(_r, _a));
                    if (_tx < 0 || _ty < 0 || _tx > room_width || _ty > room_height) continue;
                    if (!place_meeting(_tx, _ty, obj_solid)) {
                        x = _tx; y = _ty;
                        _found = true;
                        break;
                    }
                }
            }
        }
    }

    // Подстраховка от «заморозки» управления (если такие флаги есть у игрока)
    if (variable_instance_exists(p, "can_move"))       p.can_move = true;
    if (variable_instance_exists(p, "freeze"))         p.freeze = false;
    if (variable_instance_exists(p, "is_input_locked")) p.is_input_locked = false;
}

// Направление взгляда после перехода через дверь (scr_doors)
if (p != noone && variable_global_exists("spawn_facing") && global.spawn_facing != "") {
    with (p) {
        direction_facing = global.spawn_facing;
        switch (global.spawn_facing) {
            case "up":    sprite_index = spr_max_idle_up;    break;
            case "down":  sprite_index = spr_max_idle_down;  break;
            case "left":  sprite_index = spr_max_idle_left;  break;
            case "right": sprite_index = spr_max_idle_right; break;
        }
        image_speed = 0; image_index = 0;
    }
    global.spawn_facing = "";
}

// После использования спавн-параметры очищаем (чтобы не «тащились» дальше)
global.next_spawn_tag = undefined;
global.next_spawn_x   = undefined;
global.next_spawn_y   = undefined;

// Разблокировать управление после перехода между комнатами
global.control_locked = false;



