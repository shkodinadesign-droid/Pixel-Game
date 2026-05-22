// Все культуры рисуются через спрайт — как морковь
draw_self();

// Подсказка сбора урожая когда созрело
if (stage >= ready_index()) {
    if (instance_exists(obj_max)) {
        var _dist = point_distance(x, y, obj_max.x, obj_max.y);
        if (_dist < 48) {
            var _spr_h = sprite_exists(sprite_index) ? sprite_get_height(sprite_index) : 16;
            draw_hint("[E] собрать", x, y - _spr_h / 2 - 4, true);
        }
    }
}
