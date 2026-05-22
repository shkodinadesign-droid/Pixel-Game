
var cam = view_get_camera(0);
if (!instance_exists(follow_obj)) exit;

var target_x = clamp(follow_obj.x - view_w / 2, 0, max(0, room_width  - view_w));
var target_y = clamp(follow_obj.y - view_h / 2, 0, max(0, room_height - view_h));

var cur_x = camera_get_view_x(cam);
var cur_y = camera_get_view_y(cam);

camera_set_view_pos(cam, round(lerp(cur_x, target_x, 0.15)), round(lerp(cur_y, target_y, 0.15)));
