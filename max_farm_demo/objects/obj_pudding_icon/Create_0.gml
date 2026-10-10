// Пуддинг на земле в огороде — только визуал.
// Положить пуддинг: obj_day_controller (Step + подсказка в Draw_64)
if (!variable_global_exists("pudding_on_porch")) global.pudding_on_porch = false;

x = variable_global_exists("PUDDING_SPOT_X") ? global.PUDDING_SPOT_X : 240;
y = variable_global_exists("PUDDING_SPOT_Y") ? global.PUDDING_SPOT_Y : 430;
visible = global.pudding_on_porch;
