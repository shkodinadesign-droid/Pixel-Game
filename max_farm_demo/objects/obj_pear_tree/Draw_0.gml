draw_self();

if (!has_fruit) exit;

var _positions = [
    { dx: -20, dy: -80 },
    { dx:   8, dy: -100 },
    { dx:  32, dy: -78 },
];
for (var _i = 0; _i < 3; _i++) {
    draw_sprite_ext(spr_pear_icon, 0, x + _positions[_i].dx, y + _positions[_i].dy, 1.5, 1.5, 0, c_white, 1);
}

// Подсказка [E] когда Макс рядом
if (instance_exists(obj_max)) {
    var _p = instance_find(obj_max, 0);
    if (point_distance(x, y, _p.x, _p.y) < 96) {
        draw_hint("[E] Собрать грушу", x, y - 110, true);
    }
}
