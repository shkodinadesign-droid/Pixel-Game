// ===== ПЕРВОЕ ИСПЫТАНИЕ (STEP) =====
flick += 1;
if (unlock_wait > 0) { unlock_wait -= 1; if (unlock_wait == 0) global.control_locked = false; }
cave_fx_step();
if (exit_warn_cd > 0) exit_warn_cd -= 1;
if (retry_t > 0) retry_t -= 1;
if (banner_t > 0) banner_t -= 1;
if (inv_t > 0) inv_t -= 1;
// частицы
for (var i = array_length(parts) - 1; i >= 0; i--) {
    var p = parts[i]; p.vy += 0.3; p.x += p.vx; p.y += p.vy; p.life -= 1;
    if (p.life <= 0 || p.y > F + 2) array_delete(parts, i, 1);
}
var _m = max_side;
if (!instance_exists(_m) || leaving) exit;
var _mx = _m.x + SIDE_BW * 0.5;

// --- попадание: затемнение, сброс текущей фазы, снова в бой ---
if (hit_t > 0) {
    hit_t += 1;
    if (hit_t == 30) {
        switch (state) {
            case "p1": place_max(160); start_p1(); break;
            case "p2":
                place_max(480);
                for (var i = 0; i < array_length(stay_rocks); i++) instance_destroy(stay_rocks[i]);
                stay_rocks = []; wave_i = 0; start_wave(); break;
            case "p3": place_max(233); clay_y = F; clay_delay = 60; break;
        }
        parts = [];
        global.hearts = global.hearts_max;                // сердечки снова полные
        inv_t = 0;
    }
    if (hit_t >= 60) { hit_t = 0; _m.frozen = false; retry_t = 80; }
    exit;
}

switch (state) {
    // ---------- вход: перегородка за спиной ----------
    case "enter":
        if (_m.x <= 0 && !global.control_locked && (keyboard_check(vk_left) || keyboard_check(ord("A")))) {   // передумала — назад
            leaving = true; global.side_spawn = "right"; global.control_locked = true; room_goto(rm_cave); exit;
        }
        if (_m.x > 70) {
            state = "closing"; t = 0;
            slab = side_solid(0, 400, WALL_L, 401, "barrier");
            audio_play_sound(snd_stone_slide, 0, false);
        }
        break;
    case "closing":
        t += 1; slab_k = min(1, t / 50);
        if (instance_exists(slab)) slab.y2 = lerp(401, F, slab_k);
        if (t == 50) shake = 4;
        if (t >= 50) state = "lump";
        break;
    // ---------- глыба глины в центре; Макс подходит — просыпается ----------
    case "lump":
        if (_mx > 290 && !global.control_locked) { state = "wake"; t = 0; _m.frozen = true; _m.facing = 1; }
        break;
    case "wake":
        t += 1;
        g_eye = clamp((t - 10) / 30, 0, 1);
        g_arm = clamp((t - 35) / 25, 0, 1);
        g_shake = (t < 60) ? 1.5 : 0;
        if (t == 20) add_parts(gx, F - gr * 2, 10, make_color_rgb(120, 86, 60), 2);
        if (t >= 75) {
            _m.frozen = false;
            state = "talk1";
            dialog_seq_start([
                forest_page("clay", ["И это за мечом пришла ты?"]),
                forest_page("max",  ["Да. Пропусти меня."]),
                forest_page("clay", ["Маленькая. Слабая.", "Ты его хоть поднимешь?"]),
                forest_page("max",  ["Сначала найду. Потом проверю."]),
                forest_page("clay", ["Разворачивайся.", "Здесь тебе никто помогать не будет."]),
                forest_page("max",  ["(на мгновение опускает взгляд)", "Я тебя не боюсь. Я пойду дальше."]),
                forest_page("clay", ["Тогда посмотрим, удержишься ли ты", "на ногах."])
            ], "clay_transform");
        }
        break;
    case "talk1": break;
    // ---------- втягивает руки и становится шаром, откатывается к правому краю ----------
    case "transform":
        t += 1;
        g_arm = max(0, 1 - t / 25);
        g_eye = max(0, 1 - t / 30);
        gr = lerp(44, 28, min(1, t / 40));
        if (t >= 45) { state = "to_edge"; t = 0; }
        break;
    case "to_edge":
        _m.frozen = true;
        gx = min(WALL_R - 28, gx + 3); g_ang -= 3 / 28 * 57;
        if (gx >= WALL_R - 28) { _m.frozen = false; start_p1(); }
        break;

    // ---------- ФАЗА 1: катящийся шар ----------
    case "p1":
        t += 1;
        var _hit_r = gr - 4;
        if (sub == "spin") {
            g_ang += min(30, t * 0.4) * -dir;
            g_shake = 1 + t / SPIN_TIME[roll_i] * 2;
            if (t mod 4 == 0) add_parts(gx, F - gr * 2 + 4, 2, make_color_rgb(120, 86, 60), 2.5);   // осыпается земля
            if (t >= SPIN_TIME[roll_i]) { sub = "roll"; t = 0; g_shake = 0; }
        } else if (sub == "roll") {
            gx += dir * ROLL_SPD[roll_i];
            g_ang -= dir * ROLL_SPD[roll_i] / gr * 57;
            if (t mod 6 == 0) add_parts(gx - dir * gr, F - 4, 1, make_color_rgb(110, 80, 58), 1.5);
            if (gx <= WALL_L + gr || gx >= WALL_R - gr) {
                gx = clamp(gx, WALL_L + gr, WALL_R - gr);
                sub = "stun"; t = 0; shake = 7;
                audio_play_sound(snd_rock_land, 0, false);
                add_parts(gx + dir * gr, F - gr, 12, make_color_rgb(120, 86, 60), 3);
            }
        } else if (sub == "stun") {
            _hit_r = 0;                                   // оглушён — не опасен
            if (t >= 130) {
                roll_i += 1; t = 0;
                if (roll_i >= 3) {
                    state = "p1_end"; t = 0;
                } else {
                    sub = "spin"; dir = -dir;
                    audio_play_sound(snd_clay_rumble, 0, false);
                }
            }
        }
        // шар против коробки Макс
        if (_hit_r > 0) {
            var _cx = clamp(gx, _m.x, _m.x + SIDE_BW), _cy = clamp(F - gr, _m.y, _m.y + SIDE_BH);
            if (point_distance(gx, F - gr, _cx, _cy) < _hit_r) hurt();
        }
        break;
    case "p1_end":                                        // разворачивается обратно в стража
        t += 1;
        gr = lerp(28, 40, min(1, t / 30)); gx = WALL_L + gr;
        g_eye = min(1, t / 25); g_arm = min(1, t / 30); g_mood = "angry";
        if (t == 40) {
            state = "talk2";
            dialog_seq_start([forest_page("clay", ["Ноги быстрые.", "Посмотрим, куда побежишь теперь."])], "clay_p2");
        }
        break;
    case "talk2": break;

    // ---------- ФАЗА 2: каменный дождь ----------
    case "p2":
        wave_t += 1;
        // удар по земле в начале волны
        if (wave_t < 0) {
            g_arm_up = (wave_t < -25) ? clamp((wave_t + 50) / 15, 0, 1) : max(0, g_arm_up - 0.2);
            if (wave_t == -25) {
                shake = 8; audio_play_sound(snd_rock_land, 0, false);
                for (var k = 0; k < 14; k++) add_parts(random_range(60, 900), 26, 1, make_color_rgb(140, 120, 110), 0.6);   // пыль с потолка
            }
        }
        // запуск запланированных камней
        for (var i = 0; i < array_length(wave_sched); i++) {
            var s = wave_sched[i];
            if (s.at == wave_t) {
                var _x = (s.x < 0) ? clamp(_mx, 130, 890) : s.x;
                array_push(rocks, { x: _x, y: 0, vy: 0, st: "warn", t: 0, warn: s.warn, stay: s.stay, gy: side_ground_below(_x - ROCK_W / 2, _x + ROCK_W / 2, 30, true) });
            }
        }
        // камни
        var _alive = false;
        for (var i = 0; i < array_length(rocks); i++) {
            var r = rocks[i];
            if (r.st == "gone") continue;
            _alive = true;
            r.t += 1;
            if (r.st == "warn") {
                if (r.t >= r.warn) { r.st = "fall"; r.y = 24 - ROCK_H; r.vy = 2; }
            } else if (r.st == "fall") {
                r.vy = min(r.vy + 0.7, 15); r.y += r.vy;
                var _g = side_ground_below(r.x - ROCK_W / 2, r.x + ROCK_W / 2, 30, true);
                // по Макс
                if (r.x - ROCK_W / 2 + 4 < _m.x + SIDE_BW && r.x + ROCK_W / 2 - 4 > _m.x && r.y + 4 < _m.y + SIDE_BH && r.y + ROCK_H > _m.y + 6) hurt();
                if (r.y + ROCK_H >= _g) {
                    r.y = _g - ROCK_H; shake = max(shake, 4);
                    audio_play_sound(snd_rock_land, 0, false);
                    add_parts(r.x, _g - 4, 8, make_color_rgb(120, 110, 120), 2.5);
                    if (r.stay) {
                        array_push(stay_rocks, side_solid(r.x - ROCK_W / 2, r.y, r.x + ROCK_W / 2, r.y + ROCK_H, "rock"));
                        r.st = "gone";
                        // глыба легла на Макс — вытолкнуть наверх
                        if (side_box_hit(_m.x, _m.y)) _m.y = r.y - SIDE_BH;
                    } else { r.st = "crumble"; r.t = 0; }
                }
            } else if (r.st == "crumble") {
                if (r.t >= 18) r.st = "gone";
            }
        }
        // волна закончилась
        if (wave_t > 0 && !_alive && wave_t > wave_sched[array_length(wave_sched) - 1].at + 5) {
            wave_wait += 1;
            if (wave_wait >= 60) {
                wave_i += 1;
                if (wave_i >= 3) {
                    state = "p3_talk"; t = 0;
                } else start_wave();
            }
        }
        break;

    // ---------- ФАЗА 3: поднимающаяся глина ----------
    case "p3_talk":
        t += 1;
        g_arm_up = 0; g_arm = 1;
        if (t == 30) { shake = 5; audio_play_sound(snd_clay_rumble, 0, false); }
        if (t == 60) {
            state = "talk3";
            dialog_seq_start([forest_page("max", ["Наверх. Быстрее!"])], "clay_p3");
        }
        break;
    case "talk3": break;
    case "p3":
        if (clay_delay > 0) {
            clay_delay -= 1;
            if (clay_delay mod 6 == 0) add_parts(random_range(80, 900), F - 2, 1, make_color_rgb(150, 100, 70), 1.2);   // глина сочится из трещин
        } else {
            clay_y = max(CLAY_TOP, clay_y - CLAY_SPD);
        }
        if (_m.y + SIDE_BH > clay_y + 6) hurt(true);       // глина накрыла — подъём заново
        // наверху у выхода — победа
        if (_m.on_ground && _m.y + SIDE_BH <= 145 && _m.x >= 806) {
            state = "win_still"; t = 0; _m.frozen = true;
        }
        break;

    // ---------- победа ----------
    case "win_still":                                     // глина остановилась, тишина
        t += 1;
        if (t >= 60) { state = "win_drain"; t = 0; }
        break;
    case "win_drain":                                     // глина стекает и собирается в стража — меньше, спокойнее
        t += 1;
        var _k = min(1, t / 110);
        clay_y = lerp(CLAY_TOP, F + 2, _k);
        gx = lerp(WALL_L + 40, 480, _k); gr = lerp(40, 30, _k);
        g_arm = 1; g_arm_up = 0; g_mood = "calm"; g_eye = 1;
        if (t >= 120) {
            state = "talk_win"; _m.frozen = false;
            dialog_seq_start([
                forest_page("clay", ["Добралась."]),
                forest_page("max",  ["Ты пытался меня раздавить!"]),
                forest_page("clay", ["Я проверял, сможешь ли ты действовать,", "когда страшно."]),
                forest_page("max",  ["А говорить, что я слабая,", "тоже обязательно было?"]),
                forest_page("clay", ["(смущённо отводит глаза)", "С этим переборщил.", "Ты не обязана была мне верить."]),
                forest_page("max",  ["Я и не поверила. Почти."]),
                forest_page("clay", ["...", "Ты заслужила пройти дальше."]),
                forest_page("max",  ["И больше катиться на меня не будешь?"]),
                forest_page("clay", ["Сегодня - точно нет."])
            ], "clay_win");
        }
        break;
    case "talk_win":
        g_mood = "shy";
        break;
    case "done":
        gx = 480; gr = 30; g_eye = 1; g_arm = 1; g_mood = "calm";
        // выход наверху справа — дальше второе испытание (ещё не придумано)
        if (_m.x >= WALL_R - SIDE_BW - 2 && _m.y + SIDE_BH <= 145 && exit_warn_cd <= 0 && !global.control_locked) {
            exit_warn_cd = 240;
            _m.x = WALL_R - SIDE_BW - 30;
            dialog_seq_start([forest_page("max", ["Проход уходит дальше, вглубь...", "Наверное, там второе испытание.", "Сначала переведу дух."])], "");
        }
        // назад, в проход с хранителем
        if (_m.x <= 0 && !global.control_locked && (keyboard_check(vk_left) || keyboard_check(ord("A")))) {
            leaving = true; global.side_spawn = "right"; global.control_locked = true; room_goto(rm_cave); exit;
        }
        break;
}
