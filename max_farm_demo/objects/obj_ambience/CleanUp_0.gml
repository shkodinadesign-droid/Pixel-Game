// ===== АТМОСФЕРА (CLEAN UP) =====
for (var s = 0; s < array_length(amb); s++) if (amb[s].id >= 0) audio_stop_sound(amb[s].id);
