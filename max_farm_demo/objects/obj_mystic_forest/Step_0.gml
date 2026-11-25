// ===== ТАЙНЫЙ ЛЕС (STEP) =====
// сова ухает время от времени
owl_timer -= 1;
if (owl_timer <= 0) {
    owl_timer = irandom_range(700, 1500);
    var _s = audio_play_sound(snd_owl, 0, false);
    audio_sound_gain(_s, random_range(0.18, 0.32), 0);
    audio_sound_pitch(_s, random_range(0.92, 1.06));
}
// светлячки
for (var i = 0; i < array_length(fireflies); i++) {
    var f = fireflies[i];
    f.ph += 1;
    f.dir += sin(f.ph / 40) * 3;
    f.x += lengthdir_x(f.sp, f.dir); f.y += lengthdir_y(f.sp, f.dir);
    if (f.x < 0) f.x += room_width; if (f.x > room_width) f.x -= room_width;
    if (f.y < 0) f.y += room_height; if (f.y > room_height) f.y -= room_height;
}
