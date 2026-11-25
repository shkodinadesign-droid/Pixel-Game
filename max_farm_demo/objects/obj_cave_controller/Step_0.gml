// ===== СТАРАЯ ПЕЩЕРА — ПРОХОД (STEP) =====
flick += 1;
if (unlock_wait > 0) { unlock_wait -= 1; if (unlock_wait == 0) global.control_locked = false; }
cave_fx_step();
if (flash > 0) flash -= 0.04;
if (dark_warn_cd > 0) dark_warn_cd -= 1;
var _m = max_side;
if (!instance_exists(_m) || leaving) exit;
var _mx = _m.x + SIDE_BW * 0.5, _feet = _m.y + SIDE_BH;

// первый вход — Макс замечает фонарь
if (first_enter && unlock_wait == 0 && !global.control_locked) {
    if (enter_wait > 0) enter_wait -= 1;
    else {
        first_enter = false;
        global.cave_entered   = true;
        global.diary_has_new  = true;
        global.diary_was_read = false;
        dialog_seq_start([forest_page("max", ["Ну и темнотища...", "Ой, а что это там светится на выступе?"])], "");
    }
}

// фонарь на выступе
lantern_near = !global.has_lantern && !global.control_locked && abs(_mx - LANTERN_X) < 46 && _feet > 380;
if (lantern_near && keyboard_check_pressed(ord("E"))) {
    global.has_lantern = true;
    lantern_near = false;
    dialog_seq_start([forest_page("max", ["Старый какой... О, работает!", "Хорошо. Без него я бы сюда не пошла."])], "");
}
if (global.has_lantern) lantern_glow = min(1, lantern_glow + 0.02);

// без света дальше не идёт
if (!global.has_lantern && _m.x > 430) {
    _m.x = 430;
    if (dark_warn_cd <= 0 && !global.control_locked) {
        dark_warn_cd = 300;
        dialog_seq_start([forest_page("max", ["Дальше совсем темно.", "Без света я туда не пойду."])], "");
    }
}

// хранитель: проявляется в свете фонаря
if (keeper_state == "wait") {
    var _d = abs(_mx - KEEPER_X);
    keeper_alpha = global.has_lantern ? clamp(1 - (_d - 380) / 160, 0, 1) : clamp(1 - (_d - 200) / 120, 0, 0.5);
    if (global.has_lantern && _mx > KEEPER_X - 150 && !global.control_locked) {
        keeper_state = "talk";
        keeper_alpha = 1;
        _m.facing = 1;
        dialog_seq_start([
            forest_page("keeper", ["Так-так. С фонарём. Уже неплохо."]),
            forest_page("max",    ["Ты хранитель меча?"]),
            forest_page("keeper", ["А ты та, которая собирается его забрать?"]),
            forest_page("max",    ["Я хочу попробовать."]),
            forest_page("keeper", ["Тогда иди вперёд.", "На пути будут три испытания."]),
            forest_page("max",    ["Какие?"]),
            forest_page("keeper", ["Если расскажу - ты начнёшь готовить", "правильные ответы. А мне интересно,", "что ты сделаешь сама."]),
            forest_page("max",    ["А меч точно там?"]),
            forest_page("keeper", ["В конце пути. Если захочешь вернуться -", "дорогу назад найдёшь."])
        ], "keeper_strike");
    }
}
// удар посохом: вспышка, перегородка уходит в землю, хранитель отступает в тень
if (keeper_state == "strike") {
    keeper_t += 1;
    _m.frozen = true;
    if (keeper_t == 24) {
        flash = 1; shake = 6;
        audio_play_sound(snd_stone_slide, 0, false);
    }
    if (keeper_t > 24 && instance_exists(barrier)) {
        barrier_sink = min(1, barrier_sink + 1 / 70);
        barrier.y1 = lerp(70, FLOOR_Y, barrier_sink);
        if (barrier_sink >= 1) { instance_destroy(barrier); barrier = noone; }
    }
    if (keeper_t > 70) { keeper_alpha = max(0, keeper_alpha - 0.025); keeper_dx += 0.4; }
    if (keeper_t > 130) { keeper_state = "gone"; _m.frozen = false; }
}

// переходы: налево — в тайный лес (к скалам со входом), направо — на арену
if (_m.x <= 0 && !global.control_locked && (keyboard_check(vk_left) || keyboard_check(ord("A")))) {
    leaving = true;
    global.next_spawn_tag = undefined;
    global.next_spawn_x   = 1504;
    global.next_spawn_y   = 196;
    global.spawn_facing   = "down";
    global.control_locked = true;
    room_goto(rm_mystic_forest);
} else if (_m.x >= room_width - SIDE_BW - 1 && keeper_state == "gone") {
    leaving = true;
    global.side_spawn     = "left";
    global.control_locked = true;
    room_goto(rm_cave_arena);
}
