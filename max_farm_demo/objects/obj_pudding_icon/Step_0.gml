// Обновляем видимость
visible = global.pudding_on_porch;

if (global.pudding_on_porch) exit;
if (!variable_global_exists("pudding_ready") || !global.pudding_ready) exit;
if (!instance_exists(obj_max)) exit;
if (point_distance(x, y, obj_max.x, obj_max.y) >= 36) exit;
if (!keyboard_check_pressed(ord("E"))) exit;

inventory_remove("pudding", 1);
global.pudding_on_porch = true;
visible = true;
