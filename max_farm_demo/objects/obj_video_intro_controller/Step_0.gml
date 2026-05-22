/// STEP: Video Intro

if (!video_ok) exit;

video_time += 1;

var skip =
    keyboard_check_pressed(vk_space) ||
    keyboard_check_pressed(vk_enter) ||
    keyboard_check_pressed(vk_escape) ||
    mouse_check_button_pressed(mb_left);

if (skip || video_time >= video_duration) {
    room_goto(next_room);
    instance_destroy();
    exit;
}
