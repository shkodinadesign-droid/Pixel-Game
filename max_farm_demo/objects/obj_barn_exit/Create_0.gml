// гарантируем наличие глобалок (если стартовали из сарая)
if (!variable_global_exists("return_room")) {
    global.return_room = rm_farm;
}
// return_spawn устанавливает obj_door_barn перед переходом;
// задаём запасное значение только если не было установлено
if (!variable_global_exists("return_spawn_x")) {
    global.return_spawn_x = 832; // позиция у двери сарая на ферме
    global.return_spawn_y = 200;
}
back_room = global.return_room;

// изнутри выходим «вниз» к улице
door_dir = 1; // 0=Up,1=Down,2=Left,3=Right
half_w = 16;
half_h = 10;
