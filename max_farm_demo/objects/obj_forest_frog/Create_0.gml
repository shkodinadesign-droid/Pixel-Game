// ===== ЛЕС: ЛЯГУШОНОК У БОЛЬШОГО КАМНЯ (CREATE) =====
forest_episode_init();
// После разговора у камня лягушонок здесь больше не сидит — дальше он встречает Макс в тайном лесу (obj_mystic_frog)
if (global.frog_talk_done) { instance_destroy(); exit; }
image_speed = 0.08;
depth       = -bbox_bottom;
near_player = false;

sprite_index = spr_frog_sit;   // сидит у камня и ждёт Макс
