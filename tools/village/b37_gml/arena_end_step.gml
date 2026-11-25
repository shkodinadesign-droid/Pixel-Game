// ===== ПЕРВОЕ ИСПЫТАНИЕ (END STEP): тряска камеры =====
if (shake > 0) {
    var _cam = view_camera[0];
    camera_set_view_pos(_cam, camera_get_view_x(_cam) + random_range(-shake, shake), camera_get_view_y(_cam) + random_range(-shake, shake));
    shake *= 0.85; if (shake < 0.5) shake = 0;
}
