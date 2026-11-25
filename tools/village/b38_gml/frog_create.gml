// ===== ЛЯГУШОНОК В ТАЙНОМ ЛЕСУ (CREATE) =====
// На середине пути выпрыгивает из кустов к Макс: как успехи? Макс коротко рассказывает, он желает удачи
// и даёт попробовать волшебный сироп — у Макс появляются 3 сердечка. Потом убегает обратно в кусты.
forest_episode_init();
state = global.frog_syrup_done ? "gone" : "hidden";   // hidden -> run -> talk -> syrup -> talk2 -> leave -> gone
home_x = x; home_y = y;
TRIGGER_X = 640;           // Макс прошла поворот тропы
t = 0;
sprite_index = spr_frog_idle_down;
image_speed = 0.12;
alpha = 0;
visible = (state != "gone");
depth = -bbox_bottom;
