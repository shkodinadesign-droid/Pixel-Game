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
    if (!variable_global_exists("maggie_home_greeted"))   global.maggie_home_greeted   = false; // Макс пришла к Мэгги домой спросить про знак
    if (!variable_global_exists("maggie_sign_talk_done")) global.maggie_sign_talk_done = false; // Мэгги рассказала про знак (ставит конец её разговора)
    if (!variable_global_exists("secret_cache_found"))    global.secret_cache_found    = false; // жестяная коробка найдена
    if (!variable_global_exists("has_secret_key"))        global.has_secret_key        = false; // ключ от тайной комнаты
    if (!variable_global_exists("secret_room_opened"))    global.secret_room_opened    = false; // комната открыта, зелёная тетрадь прочитана
    // Зелёная тетрадь -> Джо -> старая пещера за расколотым камнем в лесу
    if (!variable_global_exists("jack_cave_talk_done"))   global.jack_cave_talk_done   = false; // Джо рассказал про пещеру и отметил её на карте
    if (!variable_global_exists("cave_entered"))          global.cave_entered          = false; // Макс вошла в пещеру
    // Пещера (вид сбоку, scr_cave_side): фонарь -> хранитель -> испытания (первое — глиняный страж)
    if (!variable_global_exists("has_lantern"))           global.has_lantern           = false; // старинный фонарь у входа
    if (!variable_global_exists("keeper_talk_done"))      global.keeper_talk_done      = false; // хранитель рассказал про три испытания
    if (!variable_global_exists("trial1_done"))           global.trial1_done           = false; // первое испытание пройдено
    if (!variable_global_exists("side_view"))             global.side_view             = false; // сейчас комната с видом сбоку
    if (!variable_global_exists("side_spawn"))            global.side_spawn            = "";    // "left"/"right" — откуда входит в комнату пещеры
    // Тайный лес: на середине пути лягушонок даёт волшебный сироп — у Макс 3 сердечка (для испытаний)
    if (!variable_global_exists("frog_syrup_done"))       global.frog_syrup_done       = false;
    if (!variable_global_exists("hearts_max"))            global.hearts_max            = 0;
    if (!variable_global_exists("hearts"))                global.hearts                = 0;
    if (!variable_global_exists("control_locked"))        global.control_locked        = false;
}

/// @func forest_area()
/// @desc Текущая область для отметки "Вы здесь" на карте: "farm" / "village" / "forest"
function forest_area() {
    if (room == rm_mystic_forest) return "mystic";
    if (room == rm_cave || room == rm_cave_arena) return "cave";
    if (room == rm_forest_entrance) return "forest";
    if (room == rm_village || room == rm_joshua_shop || room == rm_butcher_shop || room == rm_maggie_house) return "village";
    return "farm";
}

/// @func forest_current_goal()
/// @desc Строка "Сейчас нужно: ..." для карты — зависит от этапа и текущей области
function forest_current_goal() {
    forest_episode_init();
    var _a = forest_area();
    if (global.frog_talk_done) {
        if (global.trial1_done)           return "первое испытание пройдено. Дальше по проходу - второе испытание хранителя.";
        if (global.keeper_talk_done)      return "пройти испытания хранителя. Проход открыт - вперёд, вглубь пещеры.";
        if (global.cave_entered)          return global.has_lantern ? "идти вглубь пещеры." : "взять старый фонарь на каменном выступе у входа в пещеру.";
        if (global.jack_cave_talk_done) {
            if (room == rm_mystic_forest)   return "пройти тайный лес до конца. За расколотым камнем - проход между скалами, вход в пещеру.";
            if (room == rm_forest_entrance) return "с поляны лягушонка (у большого камня) - направо, в тайный лес. Пещера - в его конце.";
            return "найти вход в старую пещеру: через лес к поляне лягушонка, оттуда - в тайный лес.";
        }
        if (global.secret_room_opened)    return "расспросить Джо о пещере и Мече героя. Он продаёт семена у вагончика в деревне.";
        if (global.has_secret_key)        return (room == rm_secret_room) ? "прочитать зелёную тетрадь на столе." : "открыть тайную комнату в пекарне ключом из тайника.";
        if (global.maggie_sign_talk_done) return "найти старый тайник у яблони на ферме: камень со звёздочкой у корней, как на фотографии.";
        return "поговорить с бабушкой Мэгги о тайном знаке. Её дом - в деревне.";
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
    var _name = "Макс:";
    switch (_who) {
        case "frog":   _name = "Лягушонок:"; break;
        case "maggie": _name = "Мэгги:";     break;
        case "jack":   _name = "Джо:";       break;   // Джо — продавец семян (в сценарии — «Джек»)
        case "keeper": _name = "Хранитель:"; break;
        case "clay":   _name = "Страж:";     break;
    }
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
            quest_item_add("old_photo");                 // фотография теперь у Макс (хотбар, клик — посмотреть)
            global.diary_has_new  = true;
            global.diary_was_read = false;
            break;
        // --- Тайник у яблони: коробка, ключ, записка Сони ---
        case "cache_key_anim":                           // Макс достаёт ключ и радуется (obj_cutscene_key_found)
            instance_create_depth(0, 0, -9000, obj_cutscene_key_found);
            break;
        case "cache_after_key":
            dialog_seq_start([
                forest_page("max", ["Ура! Нашла!", "Ключ от тайной комнаты!"]),
                forest_page("max", ["А ещё тут пара стеклянных шариков...", "и записка."]),
                forest_page("max", ["Бумага совсем свежая.", "Значит, бабушка открывала эту коробку", "совсем недавно..."])
            ], "cache_open");
            break;
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
        case "secret_room_enter":                        // из пекарни — в тайную комнату
            global.next_spawn_tag = undefined;
            global.next_spawn_x   = 288;
            global.next_spawn_y   = 430;
            global.spawn_facing   = "up";
            global.control_locked = true;               // снимет obj_spawn_controller в новой комнате
            room_goto(rm_secret_room);
            break;
        case "secret_room_open":
            var _nb = instance_create_depth(0, 0, -10000, obj_ui_green_notebook);
            _nb.then_event = global.secret_room_opened ? "" : "notebook_first_read";
            break;
        case "notebook_first_read":
            global.secret_room_opened = true;
            global.diary_has_new      = true;
            global.diary_was_read     = false;
            dialog_seq_start([
                forest_page("max", ["Джо ходил с бабушкой в приключения?..", "А мне про это никто не рассказывал."]),
                forest_page("max", ["Если он нашёл эту пещеру тогда,", "может, и сейчас помнит дорогу."])
            ], "");
            break;
        case "jack_cave_talk":
            // Разговор с Джо — продавцом семян у его вагончика (obj_joe_seller, после зелёной тетради)
            dialog_seq_start([
                forest_page("max",  ["Джо, можно тебя кое о чём спросить?"]),
                forest_page("jack", ["Конечно. Что у тебя там?"]),
                forest_page("max",  ["Бабушкина тетрадь. Она пишет,", "что вы вместе искали Меч героя."]),
                forest_page("jack", ["(рассматривает рисунок и улыбается)", "Надо же. Сохранила."]),
                forest_page("max",  ["Вы правда ходили в приключения?"]),
                forest_page("jack", ["Ещё как. Стоило ей услышать", "про необычное место - всё,", "на следующее утро мы уже куда-то шли."]),
                forest_page("max",  ["Она написала, что ты всегда", "брал с собой еду."]),
                forest_page("jack", ["Кто-то же должен был. Соня могла взять", "три пустые тетради и забыть обед."]),
                forest_page("max",  ["А меч? Вы его нашли?"]),
                forest_page("jack", ["(ненадолго задумывается)", "Я довёл её до пещеры. Внутрь она", "пошла одна, а я остался ждать."]),
                forest_page("max",  ["Почему?"]),
                forest_page("jack", ["Дальше каждый должен был идти сам.", "Так нам сказали."]),
                forest_page("max",  ["Кто сказал?"]),
                forest_page("jack", ["Один очень странный старик.", "Если он всё ещё там, ты его", "ни с кем не перепутаешь."]),
                forest_page("max",  ["Покажешь, как туда добраться?"]),
                forest_page("jack", ["Ты собираешься искать меч?"]),
                forest_page("max",  ["Да. Я хочу пройти дальше в лес.", "Лягушонок сказал, что мне нужно", "уметь защищаться."]),
                forest_page("jack", ["Значит, ты уже познакомилась и с ним."]),
                forest_page("max",  ["Такое чувство, что здесь все всё знают,", "кроме меня."]),
                forest_page("jack", ["Мы знаем старые истории. А что там", "сейчас - тебе ещё предстоит выяснить."]),
                forest_page("jack", ["Давай-ка свою карту.", "(отмечает что-то на карте)"]),
                forest_page("jack", ["От поляны с большим камнем тропа", "уходит дальше, в старый тайный лес."]),
                forest_page("jack", ["Пройдёшь его до конца - увидишь", "расколотый камень. За ним -", "проход между скалами."]),
                forest_page("jack", ["Вход низкий, с дороги его почти не видно."]),
                forest_page("max",  ["И там лежит меч?"]),
                forest_page("jack", ["Возможно. Когда мы были молодыми,", "говорили, что в этой пещере его хранитель", "испытывает тех, кто приходит за мечом."]),
                forest_page("jack", ["Обещать, что ты его получишь, я не могу."]),
                forest_page("max",  ["Бабушка рассказывала, что было внутри?"]),
                forest_page("jack", ["Немного. Сказала, что пришлось испугаться.", "А потом попросила меня никого", "заранее не пугать."]),
                forest_page("max",  ["Очень успокаивает."]),
                forest_page("jack", ["Макс, слушай. Если поймёшь, что пока", "не готова, возвращайся.", "Дорога обратно - тоже дорога."]),
                forest_page("jack", ["Доказывать мне ничего не нужно."]),
                forest_page("max",  ["Я сначала хотя бы посмотрю."]),
                forest_page("jack", ["Тогда смотри внимательно.", "И под ноги тоже."])
            ], "jack_cave_done");
            break;
        case "jack_cave_done":
            global.jack_cave_talk_done = true;   // на карте — тайный лес и «Старая пещера», заросли у поляны расступаются
            global.diary_has_new       = true;
            global.diary_was_read      = false;
            map_open(false);                     // Джо отметил путь — карта сразу открывается
            break;
        // ----- тайный лес: лягушонок и волшебный сироп (obj_mystic_frog) -----
        case "frog_syrup":
            global.hearts_max = 3;
            global.hearts     = 3;
            with (obj_mystic_frog) { state = "syrup"; t = 0; }
            break;
        case "frog_syrup_bye":
            global.frog_syrup_done = true;
            with (obj_mystic_frog) { state = "leave"; t = 0; }
            break;
        // ----- пещера (scr_cave_side, obj_cave_controller, obj_clay_arena) -----
        case "keeper_strike":           // хранитель ударяет посохом — проход открывается
            global.keeper_talk_done = true;
            global.diary_has_new    = true;
            global.diary_was_read   = false;
            with (obj_cave_controller) { keeper_state = "strike"; keeper_t = 0; }
            break;
        case "clay_transform": with (obj_clay_arena) { state = "transform"; t = 0; } break;
        case "clay_p2":        with (obj_clay_arena) start_p2(); break;
        case "clay_p3":        with (obj_clay_arena) start_p3(); break;
        case "clay_win":       with (obj_clay_arena) finish_win(); break;
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

// ===== СЮЖЕТНЫЕ ПРЕДМЕТЫ В ХОТБАРЕ (ключ, фотография) =====
// Не лежат в global.player_inventory — их нельзя продать, выставить на витрину или убрать в сарай.
// Список — global.quest_items, в хотбар Макс добавляются без счётчика.

/// @func quest_item_sprite(_id)
function quest_item_sprite(_id) {
    switch (_id) {
        case "secret_key": return spr_item_secret_key;
        case "old_photo":  return spr_item_old_photo;
    }
    return -1;
}

/// @func quest_item_add(_id)
function quest_item_add(_id) {
    if (!variable_global_exists("quest_items")) global.quest_items = [];
    if (!array_contains(global.quest_items, _id)) array_push(global.quest_items, _id);
    quest_items_sync();
}

/// @func quest_items_sync()
/// @desc Положить все сюжетные предметы в хотбар Макс (если их там ещё нет)
function quest_items_sync() {
    if (!variable_global_exists("quest_items") || !instance_exists(obj_max)) return;
    with (obj_max) {
        for (var _q = 0; _q < array_length(global.quest_items); _q++) {
            var _qid = global.quest_items[_q], _has = false;
            for (var _i = 0; _i < array_length(hotbar_items); _i++) if (hotbar_items[_i].item == _qid) { _has = true; break; }
            if (!_has) array_push(hotbar_items, { item: _qid, spr: quest_item_sprite(_qid), is_seed: false, has_count: false });
        }
    }
}

/// Мебель-«мысль»: Макс стоит у предмета снизу — над предметом табличка с текстом (как сервант в доме Макса).
function furniture_remark_near() {
    if (global.control_locked || !instance_exists(obj_max)) return false;
    var _p = instance_find(obj_max, 0);
    var _fx = (_p.bbox_left + _p.bbox_right) * 0.5, _fy = _p.bbox_bottom;
    return abs(_fx - x) < sprite_width * 0.5 + 8 && _fy > y - 30 && _fy < y + 30;
}

/// Рисует табличку над объектом (вызывать в Draw GUI)
function furniture_remark_draw(_txt) {
    draw_set_font(fnt_ui); draw_set_halign(fa_center); draw_set_valign(fa_middle);
    var _cam = view_camera[0];
    var _cx = 0, _cy = 0, _cw = room_width, _ch = room_height;
    if (_cam != -1 && camera_get_view_width(_cam) > 0) {
        _cx = camera_get_view_x(_cam); _cy = camera_get_view_y(_cam);
        _cw = camera_get_view_width(_cam); _ch = camera_get_view_height(_cam);
    }
    var _gw = display_get_gui_width(), _gh = display_get_gui_height();
    var _pad = 8, _mw = 320;
    var _tw = string_width_ext(_txt, -1, _mw) + _pad * 2;
    var _th = string_height_ext(_txt, -1, _mw) + _pad * 2;
    var _x = clamp((x - _cx) / _cw * _gw, _tw / 2 + 8, _gw - _tw / 2 - 8);
    var _y = clamp((y - sprite_height - 18 - _cy) / _ch * _gh, _th / 2 + 8, _gh - _th / 2 - 8);
    draw_set_alpha(0.8); draw_set_color(c_black);
    draw_roundrect_ext(_x - _tw / 2, _y - _th / 2, _x + _tw / 2, _y + _th / 2, 6, 6, false);
    draw_set_alpha(1); draw_set_color(c_white);
    draw_text_ext(_x, _y, _txt, -1, _mw);
    draw_set_halign(fa_left); draw_set_valign(fa_top); draw_set_color(c_white);
}
