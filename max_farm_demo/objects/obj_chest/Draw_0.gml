// ===== CHEST DRAW =====
draw_self();

// Подсказка над ящиком если игрок рядом
if (!global.control_locked && instance_exists(obj_max)) {
    var _dist = point_distance(x, y, obj_max.x, obj_max.y);
    if (_dist < 56) {
        draw_hint("[E] Открыть", x + sprite_width / 2, y - 6, true);
    }
}
