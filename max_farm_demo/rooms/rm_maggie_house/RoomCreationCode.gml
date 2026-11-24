// rm_maggie_house — Creation Code

// Дом Мэгги (собран на основе дома Макс, мебель расставлена иначе — потом дорисуем)
// Телепортируем игрока к двери
if (instance_exists(obj_max) && variable_global_exists("spawn_x")) {
    obj_max.x = global.spawn_x;
    obj_max.y = global.spawn_y;
}

// Скрываем грядки и растения в доме (но не уничтожаем — они нужны для роста!)
with (obj_soil) {
    visible = false;
}

with (obj_crop) {
    visible = false;
}
