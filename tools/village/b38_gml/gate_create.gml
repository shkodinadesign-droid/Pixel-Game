// ===== ЗАРОСЛИ НА ТРОПЕ В ТАЙНЫЙ ЛЕС (CREATE) =====
// Непроходимые колючие кусты у правого края поляны лягушонка. Расступаются после разговора с Джо
// (он отметил путь на карте). Сплошной — от obj_forest_blocker.
event_inherited();
visible = true;
depth = -(y + sprite_height * image_yscale);
