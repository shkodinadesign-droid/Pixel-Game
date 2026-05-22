// плавное появление
if (image_alpha < target_alpha) image_alpha += fade_speed;

// если игрок близко — собираем
var pl = instance_nearest(x, y, obj_max);
if (pl != noone && point_distance(x, y, pl.x, pl.y) < pickup_range) {
    with (pl) {
        // добавим морковку в "инвентарь" (пока просто счётчик)
        carrots += 1;
    }
    instance_destroy();
}
