// === КОНТРОЛЛЕР ДНЯ/НОЧИ (CREATE) ===

// === ТЕСТОВЫЙ РЕЖИМ ===
// Поставь TEST_DAY = 1 для обычного старта
// Поставь TEST_DAY = 2 для тестирования кофейного квеста
// Поставь TEST_DAY = 3 для тестирования дня 3 / секретной двери
// Поставь TEST_DAY = 4 для тестирования письма с пуддингом
var TEST_DAY = 4;

// --- Текущее время ---
day_index = TEST_DAY;

if (TEST_DAY >= 2) {
    // День 2 — все задания дня 1 выполнены, дневник есть
    global.justin_bakery_intro_done = true;
    if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
    global.potato_pie_done          = true;
    global.has_diary                = true;
    global.diary_appear_alpha       = 1;
    // Один раз при первом входе на ферму ставим дневник "с новым заданием"
    if (!variable_global_exists("_day2_diary_init")) {
        global._day2_diary_init = true;
        global.diary_has_new    = true;
        global.diary_was_read   = false;
    }
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
if (TEST_DAY >= 3) {
    // День 3 — письмо про секретную комнату ещё не прочитано (появится "!" на ящике)
    global.maggie_day2_started  = true;
    global.kitten_arrived       = true;
    global.coffee_made          = true;
    global.secret_quest_started = true;
    // Письма 0,1,2,5 прочитаны; письмо 6 (секретная дверь) — НЕТ, ждёт в ящике
    global.letters_read = [0, 1, 2, 5];
    // Флаг: на первом кадре перейти в дом
    _need_house_start = true;
}
if (TEST_DAY >= 4) {
    // День 4 — письмо с пуддингом прочитано, рецепт разблокирован
    global.maggie_day2_started  = true;
    global.kitten_arrived       = true;
    global.coffee_made          = true;
    global.secret_quest_started = true;
    // Все письма включая 7 (пуддинг) прочитаны
    global.letters_read = [0, 1, 2, 3, 5, 6, 7];
    global.pudding_quest = true;
    if (!variable_global_exists("pudding_on_porch")) global.pudding_on_porch = false;
    if (!variable_global_exists("pudding_ready"))    global.pudding_ready    = false;
    _need_house_start = true;
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
    if (!variable_global_exists("letters_read"))         global.letters_read         = [];
}
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
