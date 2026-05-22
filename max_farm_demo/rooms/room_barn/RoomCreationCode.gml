// room_barn — Creation Code

room_speed = 60;

// спавним игрока у входа (нижняя часть сарая)
if (instance_exists(obj_max)) {
    var p = instance_find(obj_max, 0);
    p.x = 130;
    p.y = 440;
    p.speed = 0;
    if (variable_instance_exists(p, "direction_facing")) p.direction_facing = "up";
}

// Скрываем грядки и растения в сарае
with (obj_soil) {
    visible = false;
}

with (obj_crop) {
    visible = false;
}
