// rm_forest_entrance — Creation Code
// Опушка Таинственного леса: вход из деревни слева -> тропа -> развилка (тупик вверх, к камню направо) -> поляна.
room_speed = 60;
instance_activate_all();

if (variable_global_exists("paused"))     global.paused     = false;
if (variable_global_exists("cutscene"))   global.cutscene   = false;
if (variable_global_exists("input_lock")) global.input_lock = false;
