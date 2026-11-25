// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (CLEAN UP) =====
if (surface_exists(light_surf)) surface_free(light_surf);
audio_stop_sound(snd_amb);
side_room_end();
