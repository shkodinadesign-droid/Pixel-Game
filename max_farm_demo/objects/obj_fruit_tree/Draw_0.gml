draw_self();

if (fruit_count > 0 && sprite_exists(spr_apple_icon)) {
    // 3 яблока в кроне дерева
    var _positions = [
        { dx: -20, dy: -48 },
        { dx:   4, dy: -62 },
        { dx:  22, dy: -44 },
    ];
    for (var _i = 0; _i < 3; _i++) {
        draw_sprite(spr_apple_icon, 0, x + _positions[_i].dx, y + _positions[_i].dy);
    }
}
