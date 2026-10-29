// ===== ПЕРЕДВИЖНАЯ ЛАВКА ФЕРМЕРА ДЖЕКА (STEP) =====
// Заготовка взаимодействия по E: когда Макс у прилавка и жмёт E — вызывается User Event 0.
near_player = false;
if (!instance_exists(obj_max)) exit;
var _p = instance_find(obj_max, 0);
var _foot_x = (_p.bbox_left + _p.bbox_right) * 0.5;
var _foot_y = _p.bbox_bottom;
near_player = point_distance(x, y, _foot_x, _foot_y) < interact_radius;
if (!near_player) exit;
if (variable_global_exists("control_locked") && global.control_locked) exit;
if (keyboard_check_pressed(ord("E"))) event_user(0);
