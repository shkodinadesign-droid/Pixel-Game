// ===== ЛЯГУШОНОК В ТАЙНОМ ЛЕСУ (DRAW) =====
if (state == "hidden" || state == "gone") exit;
draw_sprite_ext(sprite_index, image_index, x, y, 1, 1, 0, c_white, alpha);
// сироп: бутылочка в лапках, потом три сердечка поднимаются над Макс
if (state == "syrup" && instance_exists(obj_max)) {
    var _p = instance_find(obj_max, 0);
    var _hx = (_p.bbox_left + _p.bbox_right) * 0.5, _hy = _p.bbox_top - 20 - min(t, 40) * 0.4;
    var _a = (t < 70) ? 1 : (90 - t) / 20;
    for (var k = 0; k < 3; k++) {
        var _k = clamp((t - k * 12) / 14, 0, 1);
        if (_k > 0) heart_draw(_hx - 18 + k * 18, _hy, 1.2 * _k, true, _a);
    }
}
