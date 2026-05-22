// ===== CHEST STEP =====
depth = -bbox_bottom;

// Открыть по E если игрок рядом
if (!global.control_locked && instance_exists(obj_max)) {
    var _dist = point_distance(x, y, obj_max.x, obj_max.y);
    if (_dist < 56 && keyboard_check_pressed(ord("E"))) {
        global.control_locked = true;
        instance_create_depth(0, 0, 0, obj_ui_chest);
    }
}
