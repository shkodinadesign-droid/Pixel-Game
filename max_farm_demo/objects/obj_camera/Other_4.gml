var cam = view_get_camera(0);
camera_set_view_size(cam, view_w, view_h);
view_set_camera(0, cam);
view_set_visible(0, true);
display_set_gui_size(view_w, view_h);
gpu_set_texfilter(false);

// Снэп камеры сразу на игрока — без lerp-сдвига при входе в комнату
if (instance_exists(follow_obj)) {
    var _snap_x = clamp(follow_obj.x - view_w / 2, 0, max(0, room_width  - view_w));
    var _snap_y = clamp(follow_obj.y - view_h / 2, 0, max(0, room_height - view_h));
    camera_set_view_pos(cam, _snap_x, _snap_y);
}
