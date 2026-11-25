// rm_mystic_forest — Creation Code
// Тайный лес: вход слева (с поляны лягушонка) -> тропа -> развилка (лягушонок с сиропом) -> поляна -> скалы со входом в пещеру.
room_speed = 60;
instance_activate_all();

if (variable_global_exists("paused"))     global.paused     = false;
if (variable_global_exists("cutscene"))   global.cutscene   = false;
if (variable_global_exists("input_lock")) global.input_lock = false;
