// === КОНТРОЛЛЕР ДНЯ/НОЧИ (STEP) ===

// Добавить пуддинг в инвентарь для тестирования (после инициализации)
if (variable_instance_exists(id, "_need_pudding_in_inv") && _need_pudding_in_inv) {
    if (variable_global_exists("player_inventory")) {
        _need_pudding_in_inv = false;
        inventory_add("pudding", 1);
    }
}

// --- Подсказка положить пуддинг на огород ---
if (room == rm_farm
&&  variable_global_exists("pudding_ready") && global.pudding_ready
&&  variable_global_exists("pudding_on_porch") && !global.pudding_on_porch
&&  instance_exists(obj_max)) {
    var _gx = 240; var _gy = 430; // центр огорода
    if (point_distance(_gx, _gy, obj_max.x, obj_max.y) < 48) {
        if (keyboard_check_pressed(ord("E"))) {
            inventory_remove("pudding", 1);
            global.pudding_on_porch = true;
            if (instance_exists(obj_pudding_icon)) {
                obj_pudding_icon.x       = _gx;
                obj_pudding_icon.y       = _gy;
                obj_pudding_icon.visible = true;
            }
            instance_create_depth(0, 0, -9999, obj_ui_dialog_max_pudding_porch);
        }
    }
}

// Тест-старт день 3: перенести Макса в дом на первом кадре
if (variable_instance_exists(id, "_need_house_start") && _need_house_start) {
    _need_house_start = false;
    global.next_spawn_x = 96;
    global.next_spawn_y = 320;
    room_goto(rm_house_inside);
    exit;
}

// --- Обработка сна ---
if (is_sleeping) {
    sleep_fade += 0.02;
    if (sleep_fade >= 1) {
        // Полное затемнение — переход на новый день
        day_start_new();
        sleep_fade = 1;
        is_sleeping = false;
    }
    exit;
}

// Плавное осветление после сна
if (sleep_fade > 0) {
    sleep_fade -= 0.02;
    sleep_fade = max(0, sleep_fade);
}

// --- Тик времени ---
minute_timer += 1;
if (minute_timer >= minute_length) {
    minute_timer = 0;
    minute += 1;

    if (minute >= 60) {
        minute = 0;
        hour += 1;

        // Полночь — принудительный сон
        if (hour >= 24) {
            day_force_sleep();
        }
    }
}

// --- Обновление фазы дня ---
if (hour >= 6 && hour < 12) {
    phase = "morning";
    target_darkness = 0;
} else if (hour >= 12 && hour < 18) {
    phase = "day";
    target_darkness = 0;
} else if (hour >= 18 && hour < 21) {
    phase = "evening";
    // Постепенное затемнение: 18:00=0, 21:00=0.4
    target_darkness = (hour - 18 + minute/60) / 3 * 0.4;
} else {
    phase = "night";
    // Ночь: 21:00=0.4, 24:00=0.7
    target_darkness = 0.4 + (hour - 21 + minute/60) / 3 * 0.3;
}

// --- Ночная сцена с лягушонком: пуддинг на крыльце + наступил вечер ---
if (variable_global_exists("pudding_on_porch") && global.pudding_on_porch
&&  phase == "evening" && hour >= 20
&& !variable_global_exists("frog_night_done")) {
    if (!variable_global_exists("frog_night_done")) global.frog_night_done = false;
    global.frog_night_done = true;
    // Запускаем ночную катсцену
    if (!instance_exists(obj_cutscene_frog_night)) {
        var _lyr = layer_get_id("GUI");
        if (_lyr == -1) _lyr = layer_get_id("Instances");
        if (_lyr == -1) _lyr = layer;
        instance_create_layer(0, 0, _lyr, obj_cutscene_frog_night);
    }
}

// --- Утреннее приветствие Дня 2 (встроенный диалог в obj_day_controller) ---
if (day_index == 2 && hour >= 6 && !day2_morning_shown && room == rm_farm) {
    day2_morning_shown  = true;
    show_morning_dialog = true;
    morning_dlg_click_prev = mouse_check_button(mb_left);
    global.control_locked  = true;
}

// Обработка кнопки встроенного утреннего диалога
if (show_morning_dialog) {
    morning_dlg_cup_anim++;
    var _gui_w  = display_get_gui_width();
    var _gui_h  = display_get_gui_height();
    var _win_w  = 620;
    var _pad    = 14;
    var _line_h = 24;
    var _win_h  = 50 + 4 * _line_h + 50;
    var _win_x  = (_gui_w - _win_w) / 2;
    var _win_y  = 20;
    var _btn_w  = 120;
    var _btn_h  = 30;
    var _btn_x1 = _win_x + _win_w - _btn_w - _pad;
    var _btn_y1 = _win_y + _win_h - _btn_h - _pad;
    var _btn_x2 = _btn_x1 + _btn_w;
    var _btn_y2 = _btn_y1 + _btn_h;

    var _mx  = device_mouse_x_to_gui(0);
    var _my  = device_mouse_y_to_gui(0);
    var _clk = mouse_check_button(mb_left);
    var _adv = (!morning_dlg_click_prev && _clk &&
                _mx >= _btn_x1 && _mx <= _btn_x2 &&
                _my >= _btn_y1 && _my <= _btn_y2)
             || keyboard_check_pressed(vk_return)
             || keyboard_check_pressed(vk_space);
    morning_dlg_click_prev = _clk;

    if (_adv) {
        show_morning_dialog   = false;
        global.control_locked = false;
    }
}

// --- Майли: приходит сразу после того как Макс выпила кофе (День 2) ---
if (!variable_global_exists("miley_visited")) global.miley_visited = false;
if (day_index == 2 && !global.miley_visited && !miley_active && room == rm_bakery) {
    var _dlg_done = variable_global_exists("coffee_dialog_done") && global.coffee_dialog_done;
    if (_dlg_done) {
        miley_active     = true;
        miley_state      = "entering";
        miley_x          = 220;   // вход пекарни (как у Джастина)
        miley_y          = 740;
        miley_xscale     = 1;
        miley_enter_wp   = 0;
        miley_dlg_step   = 1;
        miley_dlg_show   = false;
        miley_brew_timer = 0;
        miley_mug_t      = -1.0;
    }
}

// --- Напоминание посадить семена (День 1, полдень) ---
if (day_index == 1 && hour >= 12 && !seed_reminder_shown) {
    seed_reminder_shown = true;
    var _any_seeded = false;
    with (obj_soil) {
        if (has_seed) { _any_seeded = true; break; }
    }
    if (!_any_seeded && !instance_exists(obj_ui_dialog_seed_reminder)) {
        global.control_locked = true;
        var _lyr = layer_get_id("GUI");
        if (_lyr == -1) _lyr = layer_get_id("Instances_2");
        if (_lyr == -1) _lyr = layer_get_id("Instances");
        instance_create_layer(0, 0, _lyr, obj_ui_dialog_seed_reminder);
    }
}

// --- Плавное изменение затемнения ---
if (darkness < target_darkness) {
    darkness = min(darkness + darkness_speed, target_darkness);
} else if (darkness > target_darkness) {
    darkness = max(darkness - darkness_speed, target_darkness);
}


// --- Майли (встроенная state machine) ---
if (miley_active && room == rm_bakery) {
    switch (miley_state) {

        // --- Майли входит со входа как Джастин: (220,740)→(220,570)→(160,356 прилавок) ---
        case "entering":
            var _entry_tx, _entry_ty;
            if (miley_enter_wp == 0) {
                _entry_tx = 220; _entry_ty = 570; // wp1
            } else {
                _entry_tx = 160; _entry_ty = 356; // прилавок (та же точка что у Джастина)
            }
            var _mdist = point_distance(miley_x, miley_y, _entry_tx, _entry_ty);
            if (_mdist > 8) {
                var _mdir = point_direction(miley_x, miley_y, _entry_tx, _entry_ty);
                miley_x      = round(miley_x + lengthdir_x(miley_move_speed, _mdir));
                miley_y      = round(miley_y + lengthdir_y(miley_move_speed, _mdir));
                miley_xscale = (cos(degtorad(_mdir)) < 0) ? -1 : 1;
            } else {
                if (miley_enter_wp == 0) {
                    miley_enter_wp = 1; // идём к прилавку
                } else {
                    // Дошла до прилавка — запускаем диалог
                    if (instance_exists(obj_max)) {
                        obj_max.sprite_index     = spr_max_idle_up;
                        obj_max.direction_facing = "up";
                        obj_max.image_speed      = 0;
                        obj_max.image_index      = 0;
                    }
                    miley_xscale         = -1;
                    miley_dlg_show       = true;
                    miley_dlg_step       = 1;
                    miley_dlg_click_prev = mouse_check_button(mb_left);
                    global.control_locked = true;
                    miley_state          = "talking";
                }
            }
            break;

        // --- Диалог шаги 1–2: Майли просит кофе, Макс соглашается ---
        case "talking":
            if (miley_dlg_show) {
                var _mlines  = (miley_dlg_step == 2) ? 1 : 2;
                var _mwin_h  = 50 + _mlines * 24 + 50;
                var _mwin_x  = (display_get_gui_width() - 600) / 2;
                var _mbtn_x1 = _mwin_x + 600 - 120 - 14;
                var _mbtn_y1 = 20 + _mwin_h - 30 - 14;
                var _mbtn_x2 = _mbtn_x1 + 120;
                var _mbtn_y2 = _mbtn_y1 + 30;
                var _mmx  = device_mouse_x_to_gui(0);
                var _mmy  = device_mouse_y_to_gui(0);
                var _mclk = mouse_check_button(mb_left);
                var _madv = (!miley_dlg_click_prev && _mclk &&
                             _mmx >= _mbtn_x1 && _mmx <= _mbtn_x2 &&
                             _mmy >= _mbtn_y1 && _mmy <= _mbtn_y2)
                          || keyboard_check_pressed(vk_return)
                          || keyboard_check_pressed(vk_space);
                miley_dlg_click_prev = _mclk;
                if (_madv) {
                    if (miley_dlg_step < 2) {
                        miley_dlg_step++;
                        miley_dlg_click_prev = mouse_check_button(mb_left);
                    } else {
                        // После шага 2 — Майли ждёт, Макс идёт варить
                        miley_dlg_show = false;
                        if (!variable_global_exists("miley_waiting_for_coffee")) global.miley_waiting_for_coffee = false;
                        if (!variable_global_exists("miley_coffee_ready"))       global.miley_coffee_ready       = false;
                        global.miley_waiting_for_coffee = true;
                        global.miley_coffee_ready       = false;
                        global.control_locked           = false; // Макс свободна — идёт варить
                        miley_state = "waiting_for_coffee";
                    }
                }
            }
            break;

        // --- Майли стоит, ждёт пока Макс сварит кофе ---
        case "waiting_for_coffee":
            if (variable_global_exists("miley_coffee_ready") && global.miley_coffee_ready) {
                global.miley_coffee_ready = false;
                // Запускаем анимацию летящей кружки
                if (instance_exists(obj_max)) {
                    miley_mug_sx = obj_max.x;
                    miley_mug_sy = obj_max.y - 16;
                } else {
                    miley_mug_sx = miley_x + 80;
                    miley_mug_sy = miley_y;
                }
                miley_mug_ex = miley_x;
                miley_mug_ey = miley_y - 20;
                miley_mug_t  = 0.0;
                global.control_locked = true;
                miley_state = "give_mug";
            }
            break;

        // --- Кружка летит от Макса к Майли ---
        case "give_mug":
            if (miley_mug_t < 1.0) {
                miley_mug_t += 0.025;
            } else {
                miley_mug_t = -1.0;
                // +10 монет
                if (!variable_global_exists("coins")) global.coins = 0;
                global.coins += 10;
                if (!variable_global_exists("coins_anim_target"))  global.coins_anim_target  = 0;
                if (!variable_global_exists("coins_anim_current")) global.coins_anim_current = 0;
                global.coins_anim_target  = global.coins;
                global.coins_anim_current = max(0, global.coins - 10);
                // Запуск диалога благодарности
                miley_dlg_show       = true;
                miley_dlg_step       = 3;
                miley_dlg_click_prev = mouse_check_button(mb_left);
                if (instance_exists(obj_max)) {
                    obj_max.sprite_index     = spr_max_idle_left;
                    obj_max.direction_facing = "left";
                    obj_max.image_speed      = 0;
                    obj_max.image_index      = 0;
                }
                miley_state = "thanks";
            }
            break;

        // --- Диалог шаги 3–4: спасибо и прощание ---
        case "thanks":
            if (miley_dlg_show) {
                var _tlines  = 1;
                var _twin_h  = 50 + _tlines * 24 + 50;
                var _twin_x  = (display_get_gui_width() - 600) / 2;
                var _tbtn_x1 = _twin_x + 600 - 120 - 14;
                var _tbtn_y1 = 20 + _twin_h - 30 - 14;
                var _tbtn_x2 = _tbtn_x1 + 120;
                var _tbtn_y2 = _tbtn_y1 + 30;
                var _tmx  = device_mouse_x_to_gui(0);
                var _tmy  = device_mouse_y_to_gui(0);
                var _tclk = mouse_check_button(mb_left);
                var _tadv = (!miley_dlg_click_prev && _tclk &&
                             _tmx >= _tbtn_x1 && _tmx <= _tbtn_x2 &&
                             _tmy >= _tbtn_y1 && _tmy <= _tbtn_y2)
                          || keyboard_check_pressed(vk_return)
                          || keyboard_check_pressed(vk_space);
                miley_dlg_click_prev = _tclk;
                if (_tadv) {
                    if (miley_dlg_step < 4) {
                        miley_dlg_step++;
                        miley_dlg_click_prev = mouse_check_button(mb_left);
                    } else {
                        miley_dlg_show        = false;
                        global.control_locked = false;
                        global.miley_visited  = true;
                        miley_state           = "leaving";
                    }
                }
            }
            break;

        // --- Майли уходит тем же путём: прилавок→(220,570)→(220,740) ---
        case "leaving":
            var _leave_tx, _leave_ty;
            if (miley_enter_wp == 1) {
                _leave_tx = 220; _leave_ty = 570; // сначала к wp1
            } else {
                _leave_tx = 220; _leave_ty = 740; // потом к выходу
            }
            var _ldist = point_distance(miley_x, miley_y, _leave_tx, _leave_ty);
            if (_ldist > 8) {
                var _ldir = point_direction(miley_x, miley_y, _leave_tx, _leave_ty);
                miley_x      = round(miley_x + lengthdir_x(miley_move_speed, _ldir));
                miley_y      = round(miley_y + lengthdir_y(miley_move_speed, _ldir));
                miley_xscale = (cos(degtorad(_ldir)) < 0) ? -1 : 1;
            } else {
                if (miley_enter_wp == 1) {
                    miley_enter_wp = 0; // дошли до wp1, теперь к выходу
                } else {
                    miley_active = false; // ушла
                }
            }
            break;
    }
}

// === ФУНКЦИИ ===

/// @func day_start_new()
/// @desc Начать новый день (вызывается после сна)
function day_start_new() {
    day_index += 1;
    hour = 6;
    minute = 0;
    phase = "morning";
    darkness = 0;
    target_darkness = 0;

    show_debug_message("=== Новый день: " + string(day_index) + " ===");

    // День 2: Макс просыпается в своём доме у кровати
    if (day_index == 2) {
        global.next_spawn_x = 96;
        global.next_spawn_y = 320;
        room_goto(rm_house_inside);
    }

    // Витрина: продать всё, что выставлено
    vitrina_sell_all();

    // Заказы: сгенерировать новые на день
    orders_generate_daily();

    // Рост растений
    show_debug_message("[GROWTH] Всего растений: " + string(instance_number(obj_crop)));
    with (obj_crop) {
        var _sid_ok  = (soil_id != noone && instance_exists(soil_id));
        var _watered = _sid_ok ? soil_id.watered : false;
        show_debug_message("[GROWTH] crop=" + crop_type + " stage=" + string(stage) + " days=" + string(days) + " dps=" + string(days_per_stage) + " soil_ok=" + string(_sid_ok) + " watered=" + string(_watered));
        if (_sid_ok && _watered) {
            self.days += 1;
            if (self.days >= self.days_per_stage) {
                self.days = 0;
                var _max_stage = array_length(self.spr_stages) - 1;
                self.stage = min(self.stage + 1, _max_stage);
                self.sprite_index = self.spr_stages[self.stage];
                self.image_speed  = 0;
                self.image_index  = 0;
                show_debug_message("[GROWTH] GREW! " + crop_type + " -> stage " + string(self.stage) + "/" + string(_max_stage));
            }
        }
    }

    // Высыхание грядок
    with (obj_soil) {
        watered = false;
        soil_update_sprite();
    }

    // Рост фруктовых деревьев
    with (obj_fruit_tree) {
        if (stage < 2) {
            days_grown++;
            if (days_grown >= days_per_stage) {
                days_grown = 0;
                stage++;
            }
        } else {
            fruit_count = 3;
        }
        tree_update_sprite();
    }
}

/// @func day_force_sleep()
/// @desc Принудительный сон в полночь
function day_force_sleep() {
    if (!is_sleeping) {
        is_sleeping = true;
        sleep_fade = 0;
        show_debug_message("Полночь! Засыпаем...");
    }
}

/// @func day_go_to_sleep()
/// @desc Добровольный сон (вызывается от кровати)
function day_go_to_sleep() {
    if (!is_sleeping && hour >= 18) {
        is_sleeping = true;
        sleep_fade = 0;
        show_debug_message("Ложимся спать...");
        return true;
    }
    return false;
}

/// @func day_get_time_string()
/// @desc Возвращает время в формате "HH:MM"
function day_get_time_string() {
    var _h = string(hour);
    var _m = string(minute);
    if (hour < 10) _h = "0" + _h;
    if (minute < 10) _m = "0" + _m;
    return _h + ":" + _m;
}
