// === КОНТРОЛЛЕР ДНЯ/НОЧИ (DRAW GUI) ===

var _gui_w = display_get_gui_width();
var _gui_h = display_get_gui_height();

// --- Затемнение экрана (вечер/ночь) ---
var _total_dark = darkness;

// Затемнение при засыпании (поверх обычного)
if (sleep_fade > 0) {
    _total_dark = sleep_fade;
}

if (_total_dark > 0) {
    draw_set_alpha(_total_dark);
    draw_set_color(c_black);
    draw_rectangle(0, 0, _gui_w, _gui_h, false);
    draw_set_alpha(1);
}

// --- Туториал огорода ---
// Нечётные шаги = диалог с кнопкой, чётные = ждём действия игрока
if (room == rm_farm && variable_global_exists("tutorial_farm_step")) {
    var _ts = global.tutorial_farm_step;
    if (_ts == 1 || _ts == 3 || _ts == 5) {
        var _line1 = "";
        var _line2 = "";
        var _btn_label = "Хорошо!";
        switch (_ts) {
            case 1:
                _line1 = "Для начала выберу лопату и нажму [E] -";
                _line2 = "так я вскопаю грядки!";
                break;
            case 3:
                _line1 = "Теперь я посажу все семена -";
                _line2 = "нажми на семена и посади [E]";
                break;
            case 5:
                _line1 = "Теперь нужно полить все семена,";
                _line2 = "чтобы они быстрее росли!";
                break;
        }
        var _tw    = 580;
        var _tpad  = 14;
        var _tlh   = 24;
        var _lines = (_line2 != "") ? 2 : 1;
        var _th    = 46 + _lines * _tlh + 44; // +44 место под кнопку
        var _tx    = (_gui_w - _tw) / 2;
        var _ty    = _gui_h - _th - 70;

        gpu_set_blendmode(bm_normal);
        scr_dialog_draw_bg(_tx, _ty, _tw, _th);

        scr_dialog_draw_speaker(_tx, _ty, _tw, _th, "Макс:");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        var _body_ty = scr_dialog_body_top(_tx, _ty, _tw, _th);
        draw_set_font(fnt_ui);
        draw_set_color(c_black);
        draw_text(_tx + 80, _body_ty, _line1);
        if (_line2 != "") draw_text(_tx + 80, _body_ty + _tlh, _line2);

        // Кнопка
        var _bw = 110; var _bh = 28;
        var _bx1 = _tx + _tw - _bw - _tpad;
        var _by1 = _ty + _th - _bh - 8;
        var _bx2 = _bx1 + _bw; var _by2 = _by1 + _bh;
        var _mhov = (device_mouse_x_to_gui(0) >= _bx1 && device_mouse_x_to_gui(0) <= _bx2
                  && device_mouse_y_to_gui(0) >= _by1 && device_mouse_y_to_gui(0) <= _by2);
        scr_dialog_draw_button(_bx1, _by1, _bx2, _by2, _btn_label, _mhov);

        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}

// --- Попап: все фрукты собраны ---
if (variable_global_exists("show_fruit_done_popup") && global.show_fruit_done_popup) {
    var _tw   = 580; var _tpad = 14; var _tlh = 24;
    var _th   = 46 + 2 * _tlh + 44;
    var _tx   = (_gui_w - _tw) / 2;
    var _ty   = _gui_h - _th - 70;

    gpu_set_blendmode(bm_normal);
    scr_dialog_draw_bg(_tx, _ty, _tw, _th);

    scr_dialog_draw_speaker(_tx, _ty, _tw, _th, "Макс:");
    draw_set_halign(fa_left); draw_set_valign(fa_top);

    var _body_ty = scr_dialog_body_top(_tx, _ty, _tw, _th);
    draw_set_font(fnt_ui);
    draw_set_color(c_black);
    draw_text(_tx + 80, _body_ty,         "Отлично! Собрала все фрукты -");
    draw_text(_tx + 80, _body_ty + _tlh,  "интересно что с них можно приготовить?");

    var _bw = 110; var _bh = 28;
    var _bx1 = _tx + _tw - _bw - _tpad;
    var _by1 = _ty + _th - _bh - 8;
    var _bx2 = _bx1 + _bw; var _by2 = _by1 + _bh;
    var _hov = (device_mouse_x_to_gui(0) >= _bx1 && device_mouse_x_to_gui(0) <= _bx2
             && device_mouse_y_to_gui(0) >= _by1 && device_mouse_y_to_gui(0) <= _by2);
    scr_dialog_draw_button(_bx1, _by1, _bx2, _by2, "Далее", _hov);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_set_alpha(1);
}

// --- Диалог Макса: нужно собрать яблоки и груши ---
if (show_fruit_quest_dlg) {
    var _ftw  = 580; var _ftpad = 14; var _ftlh = 24;
    var _fth  = 46 + 3 * _ftlh + 44;
    var _ftx  = (_gui_w - _ftw) / 2;
    var _fty  = _gui_h - _fth - 70;

    gpu_set_blendmode(bm_normal);
    scr_dialog_draw_bg(_ftx, _fty, _ftw, _fth);

    scr_dialog_draw_speaker(_ftx, _fty, _ftw, _fth, "Макс:");
    draw_set_halign(fa_left); draw_set_valign(fa_top);

    var _fbody_ty = scr_dialog_body_top(_ftx, _fty, _ftw, _fth);
    draw_set_font(fnt_ui);
    draw_set_color(c_black);
    draw_text(_ftx + 80, _fbody_ty,               "Кажется нужно ещё собрать яблоки и груши -");
    draw_text(_ftx + 80, _fbody_ty + _ftlh,       "и проверить что с них можно приготовить.");
    draw_text(_ftx + 80, _fbody_ty + _ftlh * 2,   "Кажется бабуля будет рада яблочному пирогу по её рецепту =)");

    var _fbw = 110; var _fbh = 28;
    var _fbx1 = _ftx + _ftw - _fbw - _ftpad;
    var _fby1 = _fty + _fth - _fbh - 8;
    var _fbx2 = _fbx1 + _fbw; var _fby2 = _fby1 + _fbh;
    var _fhov = (device_mouse_x_to_gui(0) >= _fbx1 && device_mouse_x_to_gui(0) <= _fbx2
              && device_mouse_y_to_gui(0) >= _fby1 && device_mouse_y_to_gui(0) <= _fby2);
    scr_dialog_draw_button(_fbx1, _fby1, _fbx2, _fby2, "Хорошо!", _fhov);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_set_alpha(1);
}

// --- Подсказка: войти в сарай ---
if (room == rm_farm && instance_exists(obj_max)
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    var _barn_wx = 96; var _barn_wy = 256;
    if (point_distance(_barn_wx, _barn_wy, obj_max.x, obj_max.y) < 96) {
        var _cam = view_camera[0];
        var _hint_gx = (_barn_wx - camera_get_view_x(_cam)) / camera_get_view_width(_cam)  * display_get_gui_width();
        var _hint_gy = (_barn_wy - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height() - 20;
        draw_hint("[E] Войти", _hint_gx, _hint_gy, true);
    }
}

// --- Уведомление: Мэгги принесла дневник ---
if (variable_instance_exists(id, "meggie_diary_msg_timer") && meggie_diary_msg_timer > 0) {
    var _fade = min(1, meggie_diary_msg_timer / 30.0);
    var _mw = 400; var _mh = 44;
    var _mx2 = (_gui_w - _mw) / 2; var _my2 = _gui_h / 2 - 60;
    draw_set_alpha(0.88 * _fade);
    draw_set_color(c_black);
    draw_roundrect_ext(_mx2, _my2, _mx2 + _mw, _my2 + _mh, 8, 8, false);
    draw_set_alpha(_fade);
    draw_set_color(make_color_rgb(120, 200, 240));
    draw_roundrect_ext(_mx2, _my2, _mx2 + _mw, _my2 + _mh, 8, 8, true);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center); draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_text(_mx2 + _mw / 2, _my2 + _mh / 2, "Мэгги принесла тебе дневник!");
    draw_set_alpha(1);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
}

// --- Подсказка: положить пуддинг на огород ---
if (room == rm_farm
&&  variable_global_exists("pudding_ready") && global.pudding_ready
&&  variable_global_exists("pudding_on_porch") && !global.pudding_on_porch
&&  !(variable_global_exists("magic_map_placed") && global.magic_map_placed)
&&  instance_exists(obj_max)
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    var _gx = 240; var _gy = 430;
    if (point_distance(_gx, _gy, obj_max.x, obj_max.y) < 48) {
        var _cam = view_camera[0];
        var _hx = (_gx - camera_get_view_x(_cam)) / camera_get_view_width(_cam)  * display_get_gui_width();
        var _hy = (_gy - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height() - 16;
        draw_hint("[E] Положить пуддинг", _hx, _hy, true);
    }
}

// --- Подсказка: взять карту лягушонка ---
if (room == rm_farm
&&  variable_global_exists("magic_map_placed") && global.magic_map_placed
&&  !variable_global_exists("magic_map_taken")
&&  instance_exists(obj_frog_map) && instance_exists(obj_max)
&&  (!variable_global_exists("control_locked") || !global.control_locked)) {
    var _map = instance_find(obj_frog_map, 0);
    if (point_distance(_map.x, _map.y, obj_max.x, obj_max.y) < 48) {
        var _cam = view_camera[0];
        var _hx = (_map.x - camera_get_view_x(_cam)) / camera_get_view_width(_cam)  * display_get_gui_width();
        var _hy = (_map.y - camera_get_view_y(_cam)) / camera_get_view_height(_cam) * display_get_gui_height() - 16;
        draw_hint("[E] Взять карту", _hx, _hy, true);
    }
}

// --- UI: Время и день ---
if (show_time_ui && sleep_fade < 0.5) {
    var _margin = 10;
    var _box_w = 100;
    var _box_h = 50;
    var _bx = _gui_w - _box_w - _margin;
    var _by = _margin;

    // Фон
    draw_set_alpha(0.7);
    draw_set_color(c_black);
    draw_roundrect_ext(_bx, _by, _bx + _box_w, _by + _box_h, 8, 8, false);
    draw_set_alpha(1);

    // Текст
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // День
    draw_set_color(c_yellow);
    draw_text(_bx + _box_w/2, _by + 15, "День " + string(day_index));

    // Время
    draw_set_color(c_white);
    draw_text(_bx + _box_w/2, _by + 35, day_get_time_string());

    // Сброс
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

// --- Утренний диалог Дня 2 ---
if (show_morning_dialog) {
    var _gui_w  = display_get_gui_width();
    var _gui_h  = display_get_gui_height();
    var _win_w  = 620;
    var _pad    = 14;
    var _line_h = 24;
    var _win_h  = 50 + 4 * _line_h + 50;
    var _win_x  = (_gui_w - _win_w) / 2;
    var _win_y  = 20;
    var _sp_col = make_color_rgb(255, 210, 100);
    var _btn_w  = 120;
    var _btn_h  = 30;
    var _btn_x1 = _win_x + _win_w - _btn_w - _pad;
    var _btn_y1 = _win_y + _win_h - _btn_h - _pad;
    var _btn_x2 = _btn_x1 + _btn_w;
    var _btn_y2 = _btn_y1 + _btn_h;

    gpu_set_blendmode(bm_normal);
    draw_set_alpha(1);

    // Фон
    scr_dialog_draw_bg(_win_x, _win_y, _win_w, _win_h);

    // Иконка: восходящее солнце
    var _cx = _win_x + 52;
    var _cy = _win_y + _win_h / 2;
    draw_set_color(make_color_rgb(180, 130, 80));
    draw_rectangle(_cx - 24, _cy + 10, _cx + 24, _cy + 12, false);
    draw_set_color(make_color_rgb(255, 195, 50));
    draw_ellipse(_cx - 18, _cy - 14, _cx + 18, _cy + 10, false);
    draw_set_color(make_color_rgb(255, 220, 100));
    draw_ellipse(_cx - 14, _cy - 10, _cx + 14, _cy + 6, false);
    draw_set_color(make_color_rgb(255, 220, 80));
    for (var _r = 0; _r < 7; _r++) {
        var _angle = -150 + _r * 25;
        draw_line_width(_cx + lengthdir_x(22, _angle), _cy - 2 + lengthdir_y(22, _angle),
                        _cx + lengthdir_x(30, _angle), _cy - 2 + lengthdir_y(30, _angle), 2);
    }

    // Имя — жирным, в бирке
    scr_dialog_draw_speaker(_win_x, _win_y, _win_w, _win_h, "Макс:");

    // Портрет Макса — справа
    var _portrait_size = 100;
    var _portrait_x1 = _win_x + 565 * (_win_w / 580) - 8 - _portrait_size;
    scr_dialog_draw_portrait(_win_x, _win_y, _win_w, _win_h, _btn_y1, spr_max_portrait, _portrait_size);

    // Текст
    var _tx = _win_x + 100;
    var _ty = scr_dialog_body_top(_win_x, _win_y, _win_w, _win_h);
    var _text_max_w = _portrait_x1 - _tx - 16;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_text_ext(_tx, _ty, "Пожалуй надо подкрепиться!", -1, _text_max_w); _ty += _line_h;
    draw_text_ext(_tx, _ty, "Я помню, бабуля варила вкуснейшее кофе -", -1, _text_max_w); _ty += _line_h;
    draw_text_ext(_tx, _ty, "попробую сварить его сама.", -1, _text_max_w); _ty += _line_h;
    draw_set_color(make_color_rgb(150, 105, 10));
    draw_text_ext(_tx, _ty, "> Зёрна в сарае", -1, _text_max_w);

    // Кнопка
    var _mx  = device_mouse_x_to_gui(0);
    var _my  = device_mouse_y_to_gui(0);
    var _hov = (_mx >= _btn_x1 && _mx <= _btn_x2 && _my >= _btn_y1 && _my <= _btn_y2);
    scr_dialog_draw_button(_btn_x1, _btn_y1, _btn_x2, _btn_y2, "Далее", _hov);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_alpha(1);
}

// --- Подсказка Макс после ухода Джастина (картофель в сарае) ---
if (room == rm_bakery && variable_global_exists("show_potato_hint") && global.show_potato_hint) {
    var _tw   = 580; var _tpad = 14; var _tlh = 24;
    var _th   = 46 + 2 * _tlh + 44;
    var _tx   = (_gui_w - _tw) / 2;
    var _ty   = _gui_h - _th - 70;
    var _scol = make_color_rgb(255, 210, 100);

    gpu_set_blendmode(bm_normal);
    scr_dialog_draw_bg(_tx, _ty, _tw, _th);

    scr_dialog_draw_speaker(_tx, _ty, _tw, _th, "Макс:");
    draw_set_halign(fa_left); draw_set_valign(fa_top);

    var _body_ty = scr_dialog_body_top(_tx, _ty, _tw, _th);
    draw_set_font(fnt_ui);
    draw_set_color(c_black);
    draw_text(_tx + 80, _body_ty,          "Чтобы приготовить картофельный пирог нужно найти картофель -");
    draw_text(_tx + 80, _body_ty + _tlh,   "кажется я помню что картофель был у бабули в сарае!");

    var _bw = 110; var _bh = 28;
    var _bx1 = _tx + _tw - _bw - _tpad;
    var _by1 = _ty + _th - _bh - 8;
    var _bx2 = _bx1 + _bw; var _by2 = _by1 + _bh;
    var _hov = (device_mouse_x_to_gui(0) >= _bx1 && device_mouse_x_to_gui(0) <= _bx2
             && device_mouse_y_to_gui(0) >= _by1 && device_mouse_y_to_gui(0) <= _by2);
    scr_dialog_draw_button(_bx1, _by1, _bx2, _by2, "Далее", _hov);
    draw_set_halign(fa_left); draw_set_valign(fa_top);
    draw_set_color(c_white); draw_set_alpha(1);
}

// --- Майли: спрайт в мире + диалог ---
if (miley_active && room == rm_bakery) {
    var _cam_x = camera_get_view_x(view_camera[0]);
    var _cam_y = camera_get_view_y(view_camera[0]);
    draw_sprite_ext(spr_Miley, 0,
        miley_x - _cam_x, miley_y - _cam_y,
        miley_xscale, 1, 0, c_white, 1);

    // --- Подсказка: Майли ждёт кофе ---
    if (miley_state == "waiting_for_coffee") {
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(miley_dlg_col);
        draw_set_alpha(0.85);
        draw_text(display_get_gui_width() / 2, 70, "Майли ждёт кофе - сварите латте!");
        draw_set_alpha(1);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
    }

    // --- Летящая кружка кофе ---
    if (miley_mug_t >= 0 && miley_mug_t <= 1.0) {
        var _cam_mx = camera_get_view_x(view_camera[0]);
        var _cam_my = camera_get_view_y(view_camera[0]);
        var _mx_s   = lerp(miley_mug_sx, miley_mug_ex, miley_mug_t) - _cam_mx;
        var _my_s   = lerp(miley_mug_sy, miley_mug_ey, miley_mug_t) - _cam_my - sin(miley_mug_t * pi) * 36;
        // Рисуем кружку
        draw_set_alpha(1);
        draw_set_color(make_color_rgb(240, 228, 208));
        draw_roundrect_ext(_mx_s - 10, _my_s - 8, _mx_s + 10, _my_s + 8, 3, 3, false);
        draw_set_color(make_color_rgb(60, 35, 10));
        draw_roundrect_ext(_mx_s - 8, _my_s - 6, _mx_s + 8, _my_s - 1, 2, 2, false);
        draw_set_color(make_color_rgb(200, 165, 105));
        draw_ellipse(_mx_s + 8, _my_s - 4, _mx_s + 14, _my_s + 4, true);
        draw_set_color(c_white);
    }

    if (miley_dlg_show) {
        var _msp_col  = miley_dlg_col;
        var _mspeaker = "";
        var _mline1   = "";
        var _mline2   = "";
        var _mbtn_lbl = "Далее";
        switch (miley_dlg_step) {
            case 1:
                _mspeaker = "Майли:";
                _mline1   = "Добрый день! А где бабушка?";
                _mline2   = "Я пришла за любимым ароматным кофе =)";
                break;
            case 2:
                _mspeaker = "Макс:";
                _msp_col  = make_color_rgb(255, 210, 100);
                _mline1   = "Конечно, сейчас сварю для вас кофе!";
                break;
            case 3:
                _mspeaker = "Майли:";
                _mline1   = "Это очень вкусно! Спасибо большое!";
                break;
            case 4:
                _mspeaker = "Майли:";
                _mline1   = "Обязательно приду завтра за кофе! =)";
                _mbtn_lbl = "Пока!";
                break;
        }
        var _mlines = (_mline2 != "") ? 2 : 1;
        var _mgw    = display_get_gui_width();
        var _mww    = 600;
        var _mpad   = 14;
        var _mlh    = 24;
        var _mwh    = 50 + _mlines * _mlh + 50;
        var _mwx    = (_mgw - _mww) / 2;
        var _mwy    = 20;
        var _mbw    = 120;
        var _mbh    = 30;
        var _mbx1   = _mwx + _mww - _mbw - _mpad;
        var _mby1   = _mwy + _mwh - _mbh - _mpad;
        var _mbx2   = _mbx1 + _mbw;
        var _mby2   = _mby1 + _mbh;

        gpu_set_blendmode(bm_normal);
        draw_set_alpha(1);
        scr_dialog_draw_bg(_mwx, _mwy, _mww, _mwh);

        // Иконка кружки кофе (слева)
        var _mcx = _mwx + 52;
        var _mcy = _mwy + _mwh / 2 + 4;
        draw_set_color(make_color_rgb(220, 200, 165));
        draw_ellipse(_mcx-24, _mcy+16, _mcx+24, _mcy+22, false);
        draw_set_color(make_color_rgb(240, 228, 208));
        draw_roundrect_ext(_mcx-18, _mcy-16, _mcx+18, _mcy+16, 4, 4, false);
        draw_set_color(make_color_rgb(200, 165, 105));
        draw_ellipse(_mcx+14, _mcy-8, _mcx+28, _mcy+8, true);
        draw_set_color(make_color_rgb(240, 228, 208));
        draw_ellipse(_mcx+16, _mcy-5, _mcx+25, _mcy+5, true);
        draw_set_color(make_color_rgb(90, 52, 18));
        draw_rectangle(_mcx-16, _mcy-13, _mcx+16, _mcy-7, false);
        draw_set_color(make_color_rgb(60, 35, 10));
        draw_ellipse(_mcx-16, _mcy-15, _mcx+16, _mcy-9, false);
        draw_set_color(make_color_rgb(200, 200, 215));
        draw_set_alpha(0.35);
        draw_circle(_mcx-5, _mcy-22, 3, false);
        draw_circle(_mcx+5, _mcy-26, 2, false);
        draw_set_alpha(1);

        // Имя — жирным, в бирке
        scr_dialog_draw_speaker(_mwx, _mwy, _mww, _mwh, _mspeaker);

        // Текст
        var _mtx = _mwx + 100;
        var _mty = scr_dialog_body_top(_mwx, _mwy, _mww, _mwh);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_black);
        if (_mline1 != "") { draw_text_ext(_mtx, _mty, _mline1, -1, _mww-120); _mty += _mlh; }
        if (_mline2 != "") draw_text_ext(_mtx, _mty, _mline2, -1, _mww-120);

        // Кнопка
        var _mhov = (device_mouse_x_to_gui(0) >= _mbx1 && device_mouse_x_to_gui(0) <= _mbx2
                  && device_mouse_y_to_gui(0) >= _mby1 && device_mouse_y_to_gui(0) <= _mby2);
        scr_dialog_draw_button(_mbx1, _mby1, _mbx2, _mby2, _mbtn_lbl, _mhov);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(c_white);
        draw_set_alpha(1);
    }
}

// --- Сообщение "Засыпаем..." ---
if (is_sleeping && sleep_fade > 0.3) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_alpha(min(1, (sleep_fade - 0.3) * 2));
    draw_text(_gui_w/2, _gui_h/2, "Zzz...");
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}

// --- ПРЕДУПРЕЖДЕНИЕ: тестовый режим активен ---
// TEST_DAY в Create_0 стоит не на 1 — билд пропускает часть сюжета.
// Баннер держит это на виду, чтобы такое не ушло в релиз незамеченным.
if (variable_instance_exists(id, "test_day_value") && test_day_value != 1) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_red);
    draw_set_alpha(1);
    draw_text(8, 8, "ТЕСТ: TEST_DAY = " + string(test_day_value) + " - не для релиза");
    draw_set_color(c_white);
}

// --- ЭКРАН ОТЛАДКИ КВЕСТОВЫХ ФЛАГОВ (F1) ---
// Показывает все ключевые глобальные флаги сюжета разом, чтобы сразу
// было видно, какой из них не выставился и где цепочка квеста остановилась.
if (variable_instance_exists(id, "show_debug_flags") && show_debug_flags) {
    var _flag_names = [
        "meggi_intro_done", "tutorial_farm_step",
        "has_diary", "diary_has_new", "diary_was_read",
        "bakery_check_started", "bakery_check_done",
        "coffee_letter_read", "coffee_made",
        "fruit_quest_started", "fruit_quest_pending", "fruit_quest_done",
        "secret_quest_started",
        "pudding_quest", "pudding_ready", "pudding_on_porch",
        "magic_map_placed", "magic_map_taken",
        "kitten_arrived", "maggie_day2_started",
        "letters_read"
    ];

    var _px = 8; var _py = 30;
    var _row_h = 16;
    var _panel_w = 300;
    var _panel_h = 20 + array_length(_flag_names) * _row_h;

    draw_set_alpha(0.85);
    draw_set_color(c_black);
    draw_rectangle(_px, _py, _px + _panel_w, _py + _panel_h, false);
    draw_set_alpha(1);

    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_yellow);
    draw_text(_px + 6, _py + 4, "F1: день " + string(day_index) + " " + day_get_time_string());

    for (var _i = 0; _i < array_length(_flag_names); _i++) {
        var _name = _flag_names[_i];
        var _val_text;
        if (!variable_global_exists(_name)) {
            _val_text = "-- (не создан)";
            draw_set_color(c_gray);
        } else {
            var _val = variable_global_get(_name);
            if (is_array(_val)) {
                _val_text = "[" + string(array_length(_val)) + "] " + string(_val);
                draw_set_color(c_white);
            } else if (is_bool(_val)) {
                _val_text = string(_val);
                draw_set_color(_val ? c_lime : c_red);
            } else {
                _val_text = string(_val);
                draw_set_color(c_white);
            }
        }
        draw_text(_px + 6, _py + 20 + _i * _row_h, _name + " = " + _val_text);
    }
    draw_set_color(c_white);
}
