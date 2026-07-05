visible = global.pudding_on_porch;

if (global.pudding_on_porch) exit;
if (!variable_global_exists("pudding_ready") || !global.pudding_ready) exit;
if (variable_global_exists("control_locked") && global.control_locked) exit;
if (!instance_exists(obj_max)) exit;
if (point_distance(x, y, obj_max.x, obj_max.y) >= 28) exit;
if (!keyboard_check_pressed(ord("E"))) exit;

inventory_remove("pudding", 1);
global.pudding_on_porch = true;
visible = true;

// Диалог Макс после того как положила пуддинг
instance_create_depth(0, 0, -9999, obj_ui_dialog_max_pudding_porch);
