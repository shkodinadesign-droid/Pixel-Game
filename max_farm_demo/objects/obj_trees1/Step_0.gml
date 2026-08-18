depth = -bbox_bottom;

// Прозрачность только когда Макс за деревом (сзади = выше ствола на экране)
if (instance_exists(obj_max)) {
    var _trunk_y = bbox_bottom; // низ ствола
    var _in_x    = obj_max.x > bbox_left - 8 && obj_max.x < bbox_right + 8;
    if (obj_max.y < _trunk_y && _in_x) {
        image_alpha = 0.4;
    } else {
        image_alpha = 1;
    }
} else {
    image_alpha = 1;
}
