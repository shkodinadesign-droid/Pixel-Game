global.control_locked = true;
if (instance_exists(obj_max)) obj_max.visible = false;

// Позиция лягушонка — стартует за левым краем камеры
var _cx = camera_get_view_x(view_camera[0]);
var _cy = camera_get_view_y(view_camera[0]);
x = _cx - 40;
y = instance_exists(obj_pudding_icon) ? obj_pudding_icon.y : _cy + 200;

// Цель — крыльцо с пуддингом
target_x = instance_exists(obj_pudding_icon) ? obj_pudding_icon.x : _cx + 300;
target_y = y;

// Скорость и фазы
frog_speed  = 1.2;
phase       = 0;   // 0=темнеет, 1=идёт к пуддингу, 2=ест, 3=уходит, 4=финал
phase_timer = 0;
darkness    = 0;

// Направление (1=вправо, -1=влево)
frog_dir    = 1;
frog_anim   = 0;   // счётчик анимации покачивания
