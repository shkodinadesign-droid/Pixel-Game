// rm_secret_room — Creation Code
// Тайная комната бабушки Сони: полулаборатория, полуоранжерея, полуварка зелий. Размер — как у сарая,
// стены — фиолетовые обои (тайлсет tl_secret_room_ts, стена 6 тайлов как у Макс), пол как везде. Мебель автор дорисует.

room_speed = 60;

// спавним игрока у входа (внизу, лицом к комнате)
if (instance_exists(obj_max)) {
    var p = instance_find(obj_max, 0);
    p.x = 288;
    p.y = 430;
    p.speed = 0;
    if (variable_instance_exists(p, "direction_facing")) p.direction_facing = "up";
}

// Скрываем грядки и растения
with (obj_soil) {
    visible = false;
}

with (obj_crop) {
    visible = false;
}
