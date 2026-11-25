// === КОНТРОЛЛЕР ДНЯ/НОЧИ (CREATE) ===

// === ТЕСТОВЫЙ РЕЖИМ ===
// Поставь TEST_DAY = 1 для обычного старта
// Поставь TEST_DAY = 2 для тестирования кофейного квеста
// Поставь TEST_DAY = 3 для тестирования дня 3: письмо с пуддингом ->
//   пуддинг на камень у забора огорода -> сон -> ночная сцена с лягушонком -> карта утром
//   (TEST_FROM_PUDDING_LETTER ниже работает и для дня 3)
// Поставь TEST_DAY = 5 для тестирования лесного эпизода (карта уже получена, старт в доме)
// Поставь TEST_DAY = 4 для тестирования утра после ночи с лягушонком: Макс просыпается дома,
//   за окном дождь; на камне у огорода пустая миска и карта (дальше — деревня и лес под дождём)
//   TEST_FROM_PUDDING_LETTER (для дня 3):
//   true  — старт ДО письма: письмо ждёт в ящике, ингредиенты в инвентаре, пуддинг готовить самой
//   false — старт ПОСЛЕ готовки: готовый пуддинг сразу в инвентаре
var TEST_DAY = 4;   // Тест дня 4 (утро -> пустая миска -> карта -> лес под дождём). Обычная игра — 1.
var TEST_FROM_PUDDING_LETTER = true;
// Только при TEST_DAY = 5: true — лягушонок уже поговорил с Макс (знак на камне), дальше — знак на двери
// пекарни -> Мэгги у её дома -> тайник у яблони -> тайная комната. Обычно false.
var TEST_FROM_FROG_TALK = false;
// Только при TEST_DAY = 5: true — ключ от тайной комнаты уже найден (Мэгги, фото, тайник пройдены).
// Старт в доме: пекарня -> тайная комната -> зелёная тетрадь -> Джо в деревне -> пещера в лесу. Обычно false.
var TEST_FROM_SECRET_KEY = false;
// Только при TEST_DAY = 5: true — тетрадь прочитана, Джо рассказал про пещеру; старт сразу у входа в пещеру
// (вид сбоку): фонарь -> хранитель -> первое испытание (глиняный страж). Обычно false.
var TEST_FROM_CAVE = false;

// Запоминаем как переменную инстанса — нужно в Draw для баннера-предупреждения
// "TEST_DAY активен", чтобы билд с TEST_DAY != 1 нельзя было случайно не заметить.
test_day_value = TEST_DAY;

// Экран отладки квестовых флагов — переключается клавишей F1 (см. Step_0).
show_debug_flags = false;

// --- Текущее время ---
day_index = TEST_DAY;

// Подготовка тестового старта выполняется ОДИН раз за запуск игры (не при каждом входе в комнату):
// письма, флаги и тестовые ингредиенты не выдаются повторно.
var _apply_test = (TEST_DAY >= 2) && !variable_global_exists("_test_start_applied");
if (_apply_test) global._test_start_applied = TEST_DAY;

if (_apply_test && TEST_DAY >= 2) {
    // День 2 — все задания дня 1 выполнены, дневник есть
    global.justin_bakery_intro_done = true;
    if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
    global.potato_pie_done          = true;
    global.has_diary                = true;
    global.diary_appear_alpha       = 1;
    // Обучение огороду (день 1) пройдено — его диалоги не всплывают в тестовых днях
    global.tutorial_farm_step       = 7;
    if (!variable_global_exists("grain_planted")) global.grain_planted = true;
    // Один раз при первом входе на ферму ставим дневник "с новым заданием"
    if (!variable_global_exists("_day2_diary_init")) {
        global._day2_diary_init = true;
        global.diary_has_new    = true;
        global.diary_was_read   = false;
    }
    // Квест яблоки/груши: в день 2 уже выдан
    if (!variable_global_exists("fruit_quest_started")) global.fruit_quest_started = true;
    global.fruit_quest_pending = false;

    // Кофейный квест: письмо уже прочитано — квест активен
    if (!variable_global_exists("coffee_letter_read"))  global.coffee_letter_read  = true;
    if (!variable_global_exists("coffee_made"))         global.coffee_made         = false;
    if (!variable_global_exists("plant_quest_started"))  global.plant_quest_started  = true;
    if (!variable_global_exists("plant_quest_done"))     global.plant_quest_done     = false;
    if (!variable_global_exists("potato_planted"))       global.potato_planted       = false;
    if (!variable_global_exists("strawberry_planted"))   global.strawberry_planted   = false;
    // День 1 уже прошёл — его Мэгги не нужна; котик дня 2 ещё не появился
    if (!variable_global_exists("meggi_intro_done"))    global.meggi_intro_done    = true;
    if (!variable_global_exists("maggie_day2_started")) global.maggie_day2_started = false;
    if (!variable_global_exists("plant_task_shown"))    global.plant_task_shown    = false;
    if (!variable_global_exists("morning_dialog_shown"))       global.morning_dialog_shown       = false;
    if (!variable_global_exists("coffee_dialog_done"))        global.coffee_dialog_done        = false;
    if (!variable_global_exists("miley_waiting_for_coffee"))  global.miley_waiting_for_coffee  = false;
    if (!variable_global_exists("miley_coffee_ready"))        global.miley_coffee_ready        = false;
    // Письма дня 1 уже прочитаны (только при первом запуске)
    if (!variable_global_exists("letters_read")) {
        global.letters_read = [];
        var _pre = [0, 1];
        for (var _i = 0; _i < array_length(_pre); _i++) array_push(global.letters_read, _pre[_i]);
    }
}
if (_apply_test && TEST_DAY >= 3) {
    // День 3 — утром в ящике письмо с рецептом пуддинга (письма про секретную комнату и «5 дел» больше нет)
    global.maggie_day2_started  = true;
    global.kitten_arrived       = true;
    global.coffee_made          = true;
    global.secret_quest_started = true;
    // Письма 0,1,2,5 прочитаны (письмо 6 удалено: тайная дверь теперь открывается через знак лягушонка)
    global.letters_read = [0, 1, 2, 5];
    // Флаг: на первом кадре перейти в дом
    _need_house_start = true;
    if (TEST_DAY == 3) {
        // Пирог Джастину отдан вчера (день 2) — днём (10:00–17:00) он придёт на ферму поговорить
        global.justin_day2_done = true;
        global.justin_pie_day   = 2;
        // Письмо 7 (пуддинг) тоже приходит в день 3 — сразу после письма 6
        if (!variable_global_exists("pudding_on_porch")) global.pudding_on_porch = false;
        if (TEST_FROM_PUDDING_LETTER) {
            global.pudding_quest = false;
            global.pudding_ready = false;
            _need_pudding_ingredients = true; // молоко, яйцо, сахар, яблоко — чтобы сразу приготовить
        } else {
            global.letters_read  = [0, 1, 2, 5, 6, 7];
            global.pudding_quest = true;
            global.pudding_ready = true;
            _need_pudding_in_inv = true;
        }
    }
}
if (_apply_test && TEST_DAY >= 4) {
    // День 4. При TEST_FROM_PUDDING_LETTER = true письмо 7 (рецепт пуддинга) ещё НЕ прочитано и ждёт в ящике
    global.maggie_day2_started  = true;
    global.kitten_arrived       = true;
    global.coffee_made          = true;
    global.secret_quest_started = true;
    // Письма до пуддинга прочитаны; письмо 7 (рецепт бабули) доставит почтовый ящик
    global.letters_read  = [0, 1, 2, 3, 5, 6];
    if (!variable_global_exists("pudding_on_porch")) global.pudding_on_porch = false;
    if (TEST_DAY == 4) {
        // Ночь с лягушонком прошла: утро дня 4, дождь, на камне пустая миска и карта (ещё не взята)
        global.letters_read        = [0, 1, 2, 3, 5, 6, 7];
        global.pudding_quest       = true;
        global.pudding_ready       = true;
        global.pudding_on_porch    = false;
        global.pudding_bowl_empty  = true;
        global.frog_night_done     = true;
        global.frog_morning_dialog = true;
        global.magic_map_placed    = true;
        global.magic_map_taken     = false;
        global.rain_day            = 4;
        global.justin_day2_done      = true;   // Джастин уже заходил на ферму в день 3
        global.justin_pie_day        = 2;
        global.justin_farm_talk_done = true;
    } else if (TEST_DAY >= 5) {
        // Эпизод с пуддингом пройден: лягушонок приходил, карта у Макс
        global.letters_read     = [0, 1, 2, 3, 5, 6, 7];
        global.pudding_quest    = true;
        global.pudding_ready    = true;
        global.frog_night_done  = true;
        global.magic_map_placed = true;
        global.magic_map_taken  = true;
        if (TEST_FROM_FROG_TALK || TEST_FROM_SECRET_KEY || TEST_FROM_CAVE) {
            forest_episode_init();
            global.forest_found       = true;
            global.forest_glade_found = true;
            global.frog_talk_done     = true;
        }
        if (TEST_FROM_SECRET_KEY || TEST_FROM_CAVE) {
            global.door_sign_found       = true;
            global.maggie_home_greeted   = true;
            global.maggie_sign_talk_done = true;
            global.secret_cache_found    = true;
            global.has_secret_key        = true;
            global.quest_items           = ["old_photo", "secret_key"];   // в хотбар — первым кадром (Step)
        }
        if (TEST_FROM_CAVE) {
            global.secret_room_entered = true;
            global.secret_room_opened  = true;
            global.jack_cave_talk_done = true;
            _need_cave_start = true;          // Step: первым кадром — в пещеру
        }
    } else if (TEST_FROM_PUDDING_LETTER) {
        // Письмо 7 (рецепт пуддинга) ещё не прочитано — "!" на почтовом ящике
        global.pudding_quest = false;
        global.pudding_ready = false;
        _need_pudding_ingredients = true; // молоко, яйцо, сахар, яблоко — чтобы сразу приготовить
    } else {
        global.pudding_quest = true;
        global.pudding_ready = true;
        _need_pudding_in_inv = true;
    }
    if (TEST_DAY == 4) _need_house_start = true;
}
if (TEST_DAY == 1) {
    // День 1 — чистый старт
    if (!variable_global_exists("justin_bakery_intro_done")) global.justin_bakery_intro_done = false;
    if (!variable_global_exists("kitten_arrived"))           global.kitten_arrived           = false;
    if (!variable_global_exists("potato_pie_done"))          global.potato_pie_done          = false;
    if (!variable_global_exists("has_diary"))                global.has_diary                = false;
    if (!variable_global_exists("diary_appear_alpha"))       global.diary_appear_alpha       = 0;
    if (!variable_global_exists("diary_has_new"))            global.diary_has_new            = false;
    if (!variable_global_exists("diary_was_read"))           global.diary_was_read           = true;
    if (!variable_global_exists("coffee_letter_read"))       global.coffee_letter_read       = false;
    if (!variable_global_exists("coffee_made"))              global.coffee_made              = false;
    if (!variable_global_exists("plant_quest_started"))  global.plant_quest_started  = false;
    if (!variable_global_exists("plant_quest_done"))     global.plant_quest_done     = false;
    if (!variable_global_exists("potato_planted"))       global.potato_planted       = false;
    if (!variable_global_exists("strawberry_planted"))   global.strawberry_planted   = false;

    // Бабуля Мэгги встречает Макс в самом начале дня 1 — здоровается и отдаёт дневник
    if (!variable_global_exists("meggi_intro_done")) global.meggi_intro_done = false;
    if (!global.meggi_intro_done && !instance_exists(obj_grandma_Maggie)) {
        var _lyr = layer_get_id("Max");
        if (_lyr == -1) _lyr = layer;
        instance_create_layer(736, -50, _lyr, obj_grandma_Maggie);
    }
    if (!variable_global_exists("letters_read"))         global.letters_read         = [];
}
// --- Лесной эпизод (после карты): флаги в scr_forest_episode ---
forest_episode_init();

// --- Эпизод "Пуддинг -> лягушонок -> карта" ---
// Точка в огороде, куда кладётся пуддинг (и где утром лежит карта)
if (!variable_global_exists("control_locked")) global.control_locked = false;
// Плоский камень у правого забора огорода (obj_pudding_stone в rm_farm на 348,424, масштаб 2) — миска стоит на нём
global.PUDDING_SPOT_X = 362;
global.PUDDING_SPOT_Y = 434;
if (!variable_global_exists("pudding_quest"))       global.pudding_quest       = false;
if (!variable_global_exists("pudding_ready"))       global.pudding_ready       = false;
if (!variable_global_exists("pudding_on_porch"))    global.pudding_on_porch    = false; // пуддинг лежит в огороде
if (!variable_global_exists("pudding_bowl_empty"))  global.pudding_bowl_empty  = false; // после ночи на камне пустая миска (до того, как Макс возьмёт карту)
if (!variable_global_exists("frog_night_pending"))  global.frog_night_pending  = false; // ночная сцена ждёт запуска на ферме
if (!variable_global_exists("frog_night_done"))     global.frog_night_done     = false;
if (!variable_global_exists("frog_morning_dialog")) global.frog_morning_dialog = false; // реплика Макс утром после сцены
if (!variable_global_exists("frog_bowl_seen"))      global.frog_bowl_seen      = false; // Макс увидела пустую миску (утро после сцены)
if (!variable_global_exists("rain_day"))            global.rain_day            = -1;    // день дождя — утро после ночи с лягушонком
if (!variable_global_exists("magic_map_placed"))    global.magic_map_placed    = false;
if (!variable_global_exists("magic_map_taken"))     global.magic_map_taken     = false;

// --- Подсказка после Джастина ---
if (!variable_global_exists("show_potato_hint"))     global.show_potato_hint     = false;
// --- Квест: сбор фруктов ---
if (!variable_global_exists("fruit_quest_started"))  global.fruit_quest_started  = false;
if (!variable_global_exists("fruit_quest_done"))     global.fruit_quest_done     = false;
if (!variable_global_exists("show_fruit_done_popup"))global.show_fruit_done_popup= false;
if (!variable_global_exists("fruit_quest_pending"))  global.fruit_quest_pending  = false;
// --- День 2: заказ пиццы почтальона Тоби (obj_toby) ---
if (!variable_global_exists("toby_order_taken")) global.toby_order_taken = false;   // заказ принят, аванс получен
if (!variable_global_exists("toby_pizza_done"))  global.toby_pizza_done  = false;   // пицца отдана Тоби
if (!variable_global_exists("justin_farm_talk_done")) global.justin_farm_talk_done = false;   // разговор с Джастином на ферме (день 3+) состоялся
if (!variable_global_exists("justin_pie_day"))        global.justin_pie_day        = 2;       // день, когда Джастин забрал пирог
if (!variable_global_exists("justin_day2_done"))      global.justin_day2_done      = false;
if (!variable_global_exists("clock_paused"))          global.clock_paused          = false;   // часы стоят (долгий разговор)
justin_visit_timer = 0;
if (!variable_global_exists("toby_order_day"))   global.toby_order_day   = 2;       // день, когда Тоби сделал заказ
toby_timer = 0;                                                                        // пауза перед его приходом

// --- Квест: проверить пекарню (после первого полива) ---
if (!variable_global_exists("bakery_check_started")) global.bakery_check_started = false;
if (!variable_global_exists("bakery_check_done"))    global.bakery_check_done    = false;

// Диалог о фруктах (показывается когда Макс выходит на улицу после пирога)
show_fruit_quest_dlg      = false;
fruit_quest_dlg_click_prev = false;

// --- Туториал огорода (день 1) ---
// 0=не начат, 1=диалог лопата, 2=диалог семена, 3=диалог лейка, 4=готово
if (!variable_global_exists("tutorial_farm_step")) global.tutorial_farm_step = 0;

hour = 6;           // часы (6:00 - начало дня)
minute = 0;         // минуты

// --- Скорость времени ---
// ~12 минут реального времени = 18 игровых часов (6:00-24:00)
// 18 часов = 1080 минут игровых
// 12 минут реальных = 720 секунд = 720 * room_speed кадров
// 1 игровая минута = (720 * room_speed) / 1080 кадров = 0.67 * room_speed
minute_length = room_speed * 0.67;
minute_timer = 0;

// --- Фаза дня ---
// "morning" (6-12), "day" (12-18), "evening" (18-21), "night" (21-24)
phase = "morning";

// --- Затемнение экрана ---
darkness = 0;           // текущее (0 = светло, 0.7 = ночь)
target_darkness = 0;    // целевое значение
darkness_speed = 0.01;  // скорость перехода

// --- Состояние ---
is_sleeping = false;    // идёт ли переход ко сну
sleep_fade = 0;         // затемнение при засыпании (0-1)

// --- UI настройки ---
show_time_ui = true;

seed_reminder_shown       = false;
day2_morning_shown        = false;
show_morning_dialog       = false;
morning_dlg_click_prev    = false;
morning_dlg_cup_anim      = 0;

// Майли (встроенная)
miley_active         = false;
miley_state          = "";
miley_x              = 0;
miley_y              = 0;
miley_dir            = 0;      // направление шага (градусы): вверх/вниз — spr_miley_walk_up/down
miley_xscale         = -1;
miley_target_x       = 0;
miley_target_y       = 0;
miley_dlg_show       = false;
miley_dlg_step       = 1;
miley_dlg_click_prev = false;
miley_move_speed     = 2;
miley_dlg_col        = make_color_rgb(120, 200, 240);
miley_brew_timer     = 0;
miley_mug_t          = -1.0;
miley_mug_sx         = 0;
miley_mug_sy         = 0;
miley_mug_ex         = 0;
miley_mug_ey         = 0;
miley_enter_wp       = 0;   // 0=идём к wp1, 1=идём к obj_max

// Таймер Мэгги (дневник после туториала)
meggie_diary_timer     = -1; // -1=не активен, >0=отсчёт
meggie_diary_msg_timer = 0;  // время показа уведомления

// Атмосфера: дождь в день после ночи с лягушонком (обычно 4-й), звуки и светлячки в лесу (постоянный объект)
if (!instance_exists(obj_ambience)) instance_create_depth(0, 0, -100, obj_ambience);

// Сюжетные предметы (ключ, фото) — в хотбар, когда Макс появится (нужно для тестового старта)
quest_sync_done = false;
