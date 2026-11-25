// ===== СЕКРЕТНАЯ ДВЕРЬ В ПЕКАРНЕ (STEP) =====

if (!instance_exists(obj_max)) exit;
if (!variable_global_exists("control_locked")) global.control_locked = false;

var _d = point_distance(x, y, obj_max.x, obj_max.y);

if (_d < 120 && !global.control_locked
    && keyboard_check_pressed(ord("E"))
    && !instance_exists(obj_ui_dialog_secret_door)) {
    forest_episode_init();
    // Ключ из тайника у яблони: дверь открывается — маленькая рабочая комната Сони и зелёная тетрадь
    if (room == rm_bakery && global.has_secret_key) {
        // Вход в тайную комнату (rm_secret_room). Первый раз — «Ключ подошёл!»
        if (!variable_global_exists("secret_room_entered") || !global.secret_room_entered) {
            dialog_seq_start([forest_page("max", ["Ключ подошёл!"])], "secret_room_enter");
        } else {
            forest_on_dialog_finished("secret_room_enter");
        }
        exit;
    }
    global.control_locked = true;
    // Макс узнаёт знак с камня (после разговора с лягушонком) — следующая цель: спросить Мэгги
    var _recognize = (room == rm_bakery && global.frog_talk_done && !global.door_sign_found);
    if (_recognize) {
        global.door_sign_found = true;
        global.diary_has_new   = true;
        global.diary_was_read  = false;
    }
    var _lyr = layer_get_id("GUI");
    if (_lyr == -1) _lyr = layer_get_id("Instances");
    if (_lyr == -1) _lyr = layer;
    var _dlg = instance_create_layer(0, 0, _lyr, obj_ui_dialog_secret_door);
    _dlg.recognized_now = _recognize;
}

