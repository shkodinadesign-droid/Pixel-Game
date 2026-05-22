// При заходе в пекарню снимаем блокировку и ставим игрока у входа
global.control_locked = false;

if (instance_exists(obj_max)) {
    obj_max.x = 480;
    obj_max.y = 420;
    if (variable_instance_exists(obj_max, "hsp")) obj_max.hsp = 0;
    if (variable_instance_exists(obj_max, "vsp")) obj_max.vsp = 0;
    obj_max.speed = 0;
}
