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
    if (!variable_global_exists("door_sign_found"))       global.door_sign_found       = false; // Макс узнала знак на двери пекарни
    // Ключ от тайной комнаты: Мэгги -> фотография -> тайник под камнем у яблони -> записка Сони -> комната -> зелёная тетрадь
    if (!variable_global_exists("maggie_sign_talk_done")) global.maggie_sign_talk_done = false; // Мэгги рассказала про тайник, фото у Макс
    if (!variable_global_exists("secret_cache_found"))    global.secret_cache_found    = false; // жестяная коробка найдена
    if (!variable_global_exists("has_secret_key"))        global.has_secret_key        = false; // ключ от тайной комнаты
    if (!variable_global_exists("secret_room_opened"))    global.secret_room_opened    = false; // комната открыта, зелёная тетрадь прочитана
    if (!variable_global_exists("control_locked"))        global.control_locked        = false;
}

/// @func forest_area()
/// @desc Текущая область для отметки "Вы здесь" на карте: "farm" / "village" / "forest"
function forest_area() {
    if (room == rm_forest_entrance) return "forest";
    if (room == rm_village || room == rm_joshua_shop || room == rm_butcher_shop) return "village";
    return "farm";
}

/// @func forest_current_goal()
/// @desc Строка "Сейчас нужно: ..." для карты — зависит от этапа и текущей области
function forest_current_goal() {
    forest_episode_init();
    var _a = forest_area();
    if (global.frog_talk_done) {
        if (global.secret_room_opened)    return "найти Меч героя. Запись в зелёной тетради бабушки обрывается...";
        if (global.has_secret_key)        return "открыть тайную комнату в пекарне ключом из тайника.";
        if (global.maggie_sign_talk_done) return "найти старый тайник у яблони на ферме: камень со звёздочкой у корней, как на фотографии.";
        if (global.door_sign_found) return "спросить Мэгги, что значит знак на двери пекарни. Её дом - в деревне.";
        return "найти такой же знак, как на большом камне. Бабушка Соня знала, что он означает.";
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
    var _name = (_who == "frog") ? "Лягушонок:" : ((_who == "maggie") ? "Мэгги:" : "Макс:");
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
        // --- Тайная комната: Мэгги показывает фотографию, потом рассказывает про тайник ---
        case "maggie_show_photo":
            var _ph = instance_create_depth(0, 0, -10000, obj_ui_photo);
            _ph.then_event = "maggie_after_photo";
            break;
        case "maggie_after_photo":
            dialog_seq_start([
                forest_page("maggie", ["Это мы посадили её. Соня тогда уверяла,", "что яблоки вырастут уже к следующему утру."]),
                forest_page("max",    ["Кажется, терпение у нас семейное."]),
                forest_page("maggie", ["Дерево теперь большое.", "А наш тайник всё ещё там.", "Посмотри, что на фотографии лежит у корней."])
            ], "maggie_sign_done");
            break;
        case "maggie_sign_done":
            global.maggie_sign_talk_done = true;
            global.diary_has_new  = true;
            global.diary_was_read = false;
            break;
        // --- Тайник у яблони: коробка, ключ, записка Сони ---
        case "cache_open":
            global.secret_cache_found = true;
            global.has_secret_key     = true;
            global.diary_has_new      = true;
            global.diary_was_read     = false;
            var _note = instance_create_depth(0, 0, -10000, obj_ui_letter);
            _note.letter_data = {
                sender: "Бабушка Соня",
                title:  "Макс,",
                lines:  [
                    "если ты нашла ключ, значит, у тебя уже появились вопросы.",
                    "В комнате есть мои старые тетради. Начни с той, у которой зелёная обложка.",
                    "Только не верь всему, что я там написала: кое-что я записывала с чужих слов, а кое в чём ошибалась сама.",
                    "И пожалуйста, не пробуй ингредиенты, названий которых не знаешь. Даже если они очень приятно пахнут.",
                    "Бабушка Соня."
                ],
                hint: "Ключ у тебя. Тайная дверь - в пекарне."
            };
            break;
        // --- Тайная комната и зелёная тетрадь ---
        case "secret_room_open":
            var _nb = instance_create_depth(0, 0, -10000, obj_ui_green_notebook);
            _nb.then_event = global.secret_room_opened ? "" : "notebook_first_read";
            break;
        case "notebook_first_read":
            global.secret_room_opened = true;
            global.diary_has_new      = true;
            global.diary_was_read     = false;
            dialog_seq_start([
                forest_page("max", ["Запись обрывается...", "Значит, где меч - придётся выяснять самой."])
            ], "");
            break;
        case "frog_talk":
            global.forest_glade_found = true;
            global.frog_talk_done     = true;  // на камне светится знак; цель — найти такой же (он на тайной двери в пекарне)
            global.diary_has_new      = true;
            global.diary_was_read     = false;
            break;
    }
}

/// @func forest_draw_sign(_cx, _cy, _alpha)
/// @desc Знак прежнего владельца Меча героя (временная графика: спираль). Один и тот же — на большом камне
///       в лесу и на тайной двери в пекарне.
function forest_draw_sign(_cx, _cy, _alpha) {
    draw_set_alpha(_alpha);
    draw_set_color(make_color_rgb(150, 235, 220));
    draw_circle(_cx, _cy, 7, true);
    draw_circle(_cx, _cy, 3, true);
    draw_line(_cx - 10, _cy, _cx - 7, _cy);
    draw_line(_cx + 7, _cy, _cx + 10, _cy);
    draw_line(_cx, _cy - 10, _cx, _cy - 7);
    draw_point(_cx, _cy);
    draw_set_alpha(1);
    draw_set_color(c_white);
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
