// ===== КАРТА ЛЯГУШОНКА (CREATE) =====
// Открывается: из диалога подбора карты и клавишей M (map_can_open / map_open в scr_forest_episode).
// Пока открыта — Макс не двигается. Блокировку снимаем только если сами её поставили (owns_lock).

forest_episode_init();

owns_lock = !global.control_locked;   // map_open(true) переопределяет, если блокировку передал диалог
global.control_locked = true;

open_delay = 2;      // клавиша, открывшая карту, не закрывает её в том же кадре
closing    = false;  // закрытие на следующем кадре — чтобы E не сработала по объекту в мире
anim_t     = 0;
