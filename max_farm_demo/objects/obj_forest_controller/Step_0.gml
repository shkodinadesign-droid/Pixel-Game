// ===== ЛЕС: ЛОКАЛЬНАЯ ЛОГИКА ЭПИЗОДА (STEP) =====
// Поляна найдена, когда Макс подошла к месту с крестиком
if (!global.forest_glade_found && instance_exists(obj_max)) {
    var p = instance_find(obj_max, 0);
    var _fx = (p.bbox_left + p.bbox_right) * 0.5;
    if (point_distance(x, y, _fx, p.bbox_bottom) < 190) forest_mark_progress("forest_glade_found");
}
