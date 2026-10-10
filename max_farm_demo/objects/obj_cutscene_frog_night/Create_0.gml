// Ночной визит лягушонка. Запускается obj_day_controller на ферме после сна,
// когда пуддинг оставлен в огороде. Макс спит — её не видно, игрок видит сцену.
global.control_locked = true;
if (instance_exists(obj_max)) obj_max.visible = false;

phase       = 2;   // сразу ночь: затемнение -> надпись -> лягушонок
phase_timer = 0;
darkness    = 1;
frog_anim   = 0;
text_alpha  = 0;

door_x = 496; door_y = 208; // дверь дома в rm_farm

// Маршрут лягушонка — обходит деревья снизу
// Стартует справа внизу, идёт вдоль нижней дорожки, потом вверх к огороду
waypoints = [
    { x: 920, y: 750 },   // старт — справа внизу (за деревьями)
    { x: 380, y: 750 },   // идёт влево вдоль нижней дорожки
    { x: global.PUDDING_SPOT_X, y: global.PUDDING_SPOT_Y },   // к пуддингу в огороде (цель)
];
wp_index = 0;  // текущая точка маршрута
frog_speed = 4.0;

// Начальная позиция
x = waypoints[0].x;
y = waypoints[0].y;
