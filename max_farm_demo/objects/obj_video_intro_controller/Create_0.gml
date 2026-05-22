/// CREATE: Video Intro Controller

next_room = rm_farm;

video_ok = false;
video_time = 0;
video_duration = 8 * room_speed; // поставь длительность своего видео

// твой файл лежит в datafiles/video/
p0 = working_directory + "video/intro_01.mp4";
p1 = working_directory + "datafiles/video/intro_01.mp4";

show_debug_message("working_directory = " + working_directory);
show_debug_message("p0 exists = " + string(file_exists(p0)) + " | " + p0);
show_debug_message("p1 exists = " + string(file_exists(p1)) + " | " + p1);

// выбираем существующий путь
video_path = "";
if (file_exists(p0)) video_path = p0;
else if (file_exists(p1)) video_path = p1;

if (video_path == "") {
    show_debug_message("❌ Video not found (wrong folder/path)");
    room_goto(next_room);
    instance_destroy();
    exit;
}

if (video_open(video_path)) {
    video_play();
    video_ok = true;
    show_debug_message("✅ VIDEO OK: " + video_path);
} else {
    show_debug_message("❌ VIDEO FAILED (codec/format): " + video_path);
    room_goto(next_room);
    instance_destroy();
    exit;
}
