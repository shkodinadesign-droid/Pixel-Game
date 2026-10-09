// ===== ЛЕС: ВЫХОД ОБРАТНО В ДЕРЕВНЮ (STEP) =====
near_player = false;
if (!instance_exists(obj_max)) exit;

var p = instance_find(obj_max, 0);
var _foot_x = (p.bbox_left + p.bbox_right) * 0.5;
var _foot_y = p.bbox_bottom;
near_player = point_distance(x, y, _foot_x, _foot_y) < 72;

if (!near_player || global.control_locked) exit;
if (!keyboard_check_pressed(ord("E"))) exit;

global.control_locked = true;   // снимет obj_spawn_controller при входе в комнату
global.next_spawn_x   = VILLAGE_FOREST_SPAWN_X;
global.next_spawn_y   = VILLAGE_FOREST_SPAWN_Y;
room_goto(rm_village);
