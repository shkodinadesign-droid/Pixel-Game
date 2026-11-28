// ===== ЛИСИЧКА (STEP) =====
if (!active) {
    if (!instance_exists(obj_max)) exit;
    if (--timer > 0) exit;
    var _cam = view_camera[0];
    var _vx = camera_get_view_x(_cam), _vw = camera_get_view_width(_cam);
    run_dir = choose(1, -1);
    x = (run_dir > 0) ? _vx - 40 : _vx + _vw + 40;
    y = clamp(obj_max.y + 47 + choose(-90, -70, 70, 90), 40, room_height - 8);   // мимо, не под ногами
    active = true;
    exit;
}
x += run_dir * 5;
depth = -y;
var _cam2 = view_camera[0];
var _vx2 = camera_get_view_x(_cam2), _vw2 = camera_get_view_width(_cam2);
if ((run_dir > 0 && x > _vx2 + _vw2 + 60) || (run_dir < 0 && x < _vx2 - 60)) {
    active = false;
    timer  = irandom_range(1500, 3000);                             // следующий раз через 25-50 с
}
