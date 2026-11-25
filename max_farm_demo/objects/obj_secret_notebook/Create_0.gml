// ===== ТАЙНАЯ КОМНАТА: СТОЛ С ЗЕЛЁНОЙ ТЕТРАДЬЮ (CREATE) =====
// Экземпляр — круглый стол из мебели автора (spr_secret_round_table, начало — низ по центру). На нём зелёная тетрадь.
// При первом входе в комнату Макс оглядывается (описание комнаты), потом [E] у стола — тетрадь.
forest_episode_init();
if (!variable_global_exists("secret_room_entered")) global.secret_room_entered = false;
depth = -bbox_bottom;
near_player = false;
look_wait = 30;            // пауза после входа, прежде чем Макс заговорит
book_x = x - 8; book_y = y - 30;   // тетрадь на столешнице
