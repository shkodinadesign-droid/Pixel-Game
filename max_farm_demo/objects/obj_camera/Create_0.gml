view_w = 960;
view_h = 540;
follow_obj = obj_max;

gpu_set_texfilter(false);

// Стартовая позиция — сразу на игроке, не в (0,0)
var _start_x = 0;
var _start_y = 0;
if (instance_exists(follow_obj)) {
    _start_x = clamp(follow_obj.x - view_w / 2, 0, max(0, room_width  - view_w));
    _start_y = clamp(follow_obj.y - view_h / 2, 0, max(0, room_height - view_h));
}

var cam = camera_create_view(_start_x, _start_y, view_w, view_h, 0, noone, -1, -1, 0, 0);
view_enabled = true;
view_set_visible(0, true);
view_set_camera(0, cam);
view_set_wport(0, view_w);
view_set_hport(0, view_h);
view_set_xport(0, 0);
view_set_yport(0, 0);

display_set_gui_size(view_w, view_h);
window_set_size(view_w, view_h);
