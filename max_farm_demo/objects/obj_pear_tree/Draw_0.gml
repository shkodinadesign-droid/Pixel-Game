draw_self();

if (!has_fruit) exit;

// Плоды рисуют сами obj_*_on_tree на кроне дерева (исчезают по одному при сборе).
// Якорь отвечает только за сбор и подсказку.

// Подсказка [E] когда Макс рядом
if (instance_exists(obj_max)) {
    var _p = instance_find(obj_max, 0);
    if (point_distance(x, y, _p.x, _p.y) < 96) {
        draw_hint("[E] Собрать грушу", x, y - 110, true);
    }
}
