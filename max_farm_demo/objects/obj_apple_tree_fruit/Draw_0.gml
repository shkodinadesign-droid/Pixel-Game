draw_self();

if (!has_fruit) exit;

// Три иконки яблок в кроне дерева
var _positions = [
    { dx: 18, dy: 22 },
    { dx: 48, dy: 10 },
    { dx: 76, dy: 26 },
];
for (var _i = 0; _i < 3; _i++) {
    draw_sprite(spr_apple_icon, 0, bbox_left + _positions[_i].dx, bbox_top + _positions[_i].dy);
}

// Подсказка [E] когда Макс рядом
if (instance_exists(obj_max)) {
    var _p = instance_find(obj_max, 0);
    var _cx = (bbox_left + bbox_right) * 0.5;
    var _cy = (bbox_top + bbox_bottom) * 0.5;
    var _foot_cx = (_p.bbox_left + _p.bbox_right) * 0.5;
    var _foot_y  = _p.bbox_bottom;
    if (point_distance(_cx, _cy, _foot_cx, _foot_y) < 96) {
        draw_hint("[E] Собрать", _cx, bbox_top - 8, true);
    }
}
