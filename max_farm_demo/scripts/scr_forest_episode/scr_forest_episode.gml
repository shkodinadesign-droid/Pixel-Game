// ===== ЛЕСНОЙ ЭПИЗОД: карта -> деревня -> лесная опушка -> лягушонок у большого камня =====
// Вся логика продолжения после получения карты живёт здесь и в объектах obj_forest_* / obj_village_forest_gate.
// Состояние хранится в global.* — переживает смену комнат и дней.
// ВАЖНО: сохранений на диск в проекте нет, поэтому после перезапуска игры прогресс не сохраняется.

#macro FOREST_SPAWN_X        96     // точка появления в лесу (вход из деревни)
#macro FOREST_SPAWN_Y        800
#macro VILLAGE_FOREST_SPAWN_X 1440  // точка появления в деревне (возврат из леса), левее выхода в лес
#macro VILLAGE_FOREST_SPAWN_Y 360

/// @func forest_episode_init()
/// @desc Флаги эпизода. Вызывается из obj_day_controller (Create) и из всех функций ниже — на случай,
///       если карта была получена до этого обновления (флаги появятся сами, повторять пуддинг не нужно).
function forest_episode_init() {
    if (!variable_global_exists("magic_map_taken"))       global.magic_map_taken       = false;
    if (!variable_global_exists("forest_found"))          global.forest_found          = false; // Макс дошла до леса
    if (!variable_global_exists("forest_glade_found"))    global.forest_glade_found    = false; // дошла до поляны с камнем
    if (!variable_global_exists("frog_talk_done"))        global.frog_talk_done        = false; // поговорила с лягушонком
    if (!variable_global_exists("map_hotkey_hint_shown")) global.map_hotkey_hint_shown = false; // подсказка про клавишу M
    if (!variable_global_exists("control_locked"))        global.control_locked        = false;
}

/// @func forest_area()
/// @desc Текущая область для отметки "Вы здесь" на карте: "farm" / "village" / "forest"
function forest_area() {
    if (room == rm_forest_entrance) return "forest";
    if (room == rm_village || room == rm_joshua_shop) return "village";
    return "farm";
}

/// @func forest_current_goal()
/// @desc Строка "Сейчас нужно: ..." для карты — зависит от этапа и текущей области
function forest_current_goal() {
    forest_episode_init();
    var _a = forest_area();
    if (global.frog_talk_done) {
        if (_a == "forest") return "вернуться по тропе налево, в деревню, и рассказать Джастину о лягушонке и знаке.";
        return "рассказать Джастину о лягушонке и знаке в лесу.";
    }
    if (global.forest_glade_found) return "поговорить с лягушонком у большого камня.";
    switch (_a) {
        case "farm":    return "дойти до деревни: по дороге направо, к правому краю фермы.";
        case "village": return "пройти деревню направо, до указателя \"Лесная тропа\" у правого края.";
        case "forest":  return "идти по тропе до развилки и свернуть направо, к большому камню.";
    }
    return "";
}

/// @func map_can_open()
/// @desc Карту можно открыть клавишей M: только после получения и когда управление ничем не занято
function map_can_open() {
    forest_episode_init();
    if (!global.magic_map_taken) return false;
    if (global.control_locked)   return false;
    if (instance_exists(obj_ui_fullscreen_map)) return false;
    if (instance_exists(obj_ui_dialog_seq))     return false;
    if (instance_exists(obj_diary))             return false;
    if (instance_exists(obj_day_controller) && obj_day_controller.is_sleeping) return false;
    return true;
}

/// @func map_open(_owns_lock)
/// @desc Открыть окно карты (одна копия). _owns_lock = true, если блокировку управления карте передал
///       предыдущий диалог (например, диалог подбора карты) — тогда карта снимет её при закрытии.
function map_open(_owns_lock) {
    if (instance_exists(obj_ui_fullscreen_map)) return noone;
    var _m = instance_create_depth(0, 0, -10000, obj_ui_fullscreen_map);
    if (_owns_lock) _m.owns_lock = true;
    return _m;
}

/// @func forest_page(_who, _lines)
/// @desc Страница диалога для dialog_seq_start: _who = "max" / "frog"
function forest_page(_who, _lines) {
    var _name = (_who == "frog") ? "Лягушонок:" : "Макс:";
    return { who: _who, speaker: _name, lines: _lines };
}

/// @func dialog_seq_start(_pages, _on_finish, _owns_lock)
/// @desc Диалог из нескольких страниц (obj_ui_dialog_seq). _on_finish — событие для forest_on_dialog_finished.
function dialog_seq_start(_pages, _on_finish, _owns_lock = false) {
    var _d = instance_create_depth(0, 0, -9999, obj_ui_dialog_seq);
    _d.pages     = _pages;
    _d.on_finish = _on_finish;
    if (_owns_lock) _d.owns_lock = true;
    return _d;
}

/// @func forest_on_dialog_finished(_event)
function forest_on_dialog_finished(_event) {
    forest_episode_init();
    switch (_event) {
        case "frog_talk":
            global.forest_glade_found = true;
            global.frog_talk_done     = true;  // знак на камне теперь виден, следующая цель — Джастин
            global.diary_has_new      = true;
            global.diary_was_read     = false;
            break;
    }
}

/// @func forest_mark_progress(_flag)
/// @desc Отметить этап (forest_found / forest_glade_found) один раз и подсветить дневник
function forest_mark_progress(_flag) {
    forest_episode_init();
    if (!global.magic_map_taken) return;
    if (variable_global_get(_flag)) return;
    variable_global_set(_flag, true);
    global.diary_has_new  = true;
    global.diary_was_read = false;
}
