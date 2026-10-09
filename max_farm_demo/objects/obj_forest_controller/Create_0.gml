// ===== ЛЕС: ЛОКАЛЬНАЯ ЛОГИКА ЭПИЗОДА (CREATE) =====
// Стоит в rm_forest_entrance на месте крестика (у большого камня) и рисует крестик на земле.
// Этапы: forest_found (вошла в лес) -> forest_glade_found (дошла до камня) -> frog_talk_done (разговор).
forest_episode_init();
forest_mark_progress("forest_found");
