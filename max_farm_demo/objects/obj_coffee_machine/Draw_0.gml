// Триггер невидимый — подсказку рисуем над кофемашиной на спрайте прилавка
if (!instance_exists(obj_max)) exit;

var _d = point_distance(x, y, obj_max.x, obj_max.y);
if (_d > 100) exit;

// Подсказка над прилавком (выше bbox_top витрины), а не над точкой триггера
var _hint_x = x;
var _hint_y  = y - 80; // по умолчанию — высоко над триггером
if (instance_exists(obj_order_vitrina)) {
    _hint_y = obj_order_vitrina.bbox_top - 8;
}

draw_hint("[E] Готовить", _hint_x, _hint_y, true);
