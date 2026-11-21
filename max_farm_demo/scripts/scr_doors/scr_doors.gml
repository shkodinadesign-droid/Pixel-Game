// ===== ДВЕРИ: ВХОД И ВЫХОД ШАГОМ ВПЕРЁД =====
// У объекта-двери в Create: door_init(...). В Step: door_step().
// Зона — прямоугольник в координатах комнаты, в который должны попасть ноги Макс (середина низа маски);
// направление — куда игрок жмёт стрелку; spawn — левый верх Макс в новой комнате (перед парной дверью).

/// @func door_init(_x1, _y1, _x2, _y2, _dir, _room, _spawn_x, _spawn_y, _check)
/// @param _dir    "up" | "down" | "left" | "right"
/// @param _check  функция-условие (true — можно пройти) или undefined
function door_init(_x1, _y1, _x2, _y2, _dir, _room, _spawn_x, _spawn_y, _check = undefined) {
    door_x1 = _x1; door_y1 = _y1; door_x2 = _x2; door_y2 = _y2;
    door_dir = _dir; door_room = _room;
    door_spawn_x = _spawn_x; door_spawn_y = _spawn_y;
    door_check = _check;
    door_armed = false;          // сработает только после того, как Макс зашла в зону (не при появлении в ней)
    visible = false;
}

/// @func door_step()
/// @desc Проверка перехода; true — переход начат
function door_step() {
    if (!variable_instance_exists(id, "door_x1")) return false;   // door_init не вызван (нет события Create) — дверь молчит
    if (!instance_exists(obj_max)) return false;
    if (variable_global_exists("control_locked") && global.control_locked) return false;
    var _p  = instance_find(obj_max, 0);
    var _fx = (_p.bbox_left + _p.bbox_right) * 0.5;
    var _fy = _p.bbox_bottom;
    var _in = (_fx >= door_x1 && _fx <= door_x2 && _fy >= door_y1 && _fy <= door_y2);
    if (!_in) { door_armed = true; return false; }
    if (!door_armed) return false;
    var _held = false;
    switch (door_dir) {
        case "up":    _held = keyboard_check(vk_up);    break;
        case "down":  _held = keyboard_check(vk_down);  break;
        case "left":  _held = keyboard_check(vk_left);  break;
        case "right": _held = keyboard_check(vk_right); break;
    }
    if (!_held) return false;
    door_armed = false;                                  // повторно — только после выхода из зоны
    if (!is_undefined(door_check) && !door_check()) return false;
    global.next_spawn_tag = undefined;
    global.next_spawn_x   = door_spawn_x;
    global.next_spawn_y   = door_spawn_y;
    global.spawn_facing   = door_dir;                    // Макс смотрит туда, куда шла
    global.control_locked = true;                        // снимет obj_spawn_controller в новой комнате
    room_goto(door_room);
    return true;
}
