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

    // Аккуратно выталкиваем из солидов (замени obj_solid на свой класс коллизий, если он другой)
    var tries = 0;
    while (place_meeting(p.x, p.y, obj_solid) && tries < 16) {
        p.y -= 1;
        tries++;
    }
    if (place_meeting(p.x, p.y, obj_solid)) {
        p.x += 2; p.y -= 2;
    }

    // Подстраховка от «заморозки» управления (если такие флаги есть у игрока)
    if (variable_instance_exists(p, "can_move"))       p.can_move = true;
    if (variable_instance_exists(p, "freeze"))         p.freeze = false;
    if (variable_instance_exists(p, "is_input_locked")) p.is_input_locked = false;
}

// После использования спавн-параметры очищаем (чтобы не «тащились» дальше)
global.next_spawn_tag = undefined;
global.next_spawn_x   = undefined;
global.next_spawn_y   = undefined;

// Разблокировать управление после перехода между комнатами
global.control_locked = false;



