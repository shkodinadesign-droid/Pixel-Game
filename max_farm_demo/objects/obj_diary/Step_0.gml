// ===== DIARY STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Проверка клика по вкладкам (нарисованы внутри спрайта книги, координаты в исходных 824x453 px)
var _recipes_unlocked = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;

var _tab_local = [
    [63, 0, 96, 27],    // 0 - Задания
    [111, 0, 144, 27],  // 1 - Инвентарь
    [160, 0, 192, 27],  // 2 - Рецепты
    [207, 0, 240, 27],  // 3 - Растения
    [254, 0, 288, 27],  // 4 - Приключения
    [302, 0, 336, 27],  // 5 - Дружба
    [351, 0, 384, 27],  // 6 - Деньги
];
var _tab_sx = book_w / 824;
var _tab_sy = book_h / 453;

for (var i = 0; i < 7; i++) {
    var tx1 = book_x + _tab_local[i][0] * _tab_sx;
    var ty1 = book_y + _tab_local[i][1] * _tab_sy;
    var tx2 = book_x + _tab_local[i][2] * _tab_sx;
    var ty2 = book_y + _tab_local[i][3] * _tab_sy;

    if (mx >= tx1 && mx <= tx2 && my >= ty1 && my <= ty2) {
        if (click_press) {
            // Вкладка Рецепты (2) заблокирована до катсцены Джастина
            if (i == 2 && !_recipes_unlocked) break;
            current_tab = i;
        }
    }
}

// Клик по заданиям (вкладка 0)
if (current_tab == 0 && click_press) {
    var _q_content_x = book_x + round(60 * book_scale);
    var _q_content_y = book_y + round(60 * book_scale);
    var _q_rows_y     = _q_content_y + round(26 * book_scale);
    var _q_list_w     = round(205 * book_scale);

    var _q_rows = diary_quest_build_rows(_q_content_x, _q_rows_y, book_scale);
    for (var _qi = 0; _qi < array_length(_q_rows); _qi++) {
        var _qrow = _q_rows[_qi];
        if (_qrow.type != "quest") continue;
        if (mx >= _q_content_x && mx <= _q_content_x + _q_list_w &&
            my >= _qrow.y && my <= _qrow.y + _qrow.h) {
            selected_quest = _qrow.q.id;
            diary_quest_mark_read(_qrow.q.id);
            break;
        }
    }
}

// Клик по слотам инвентаря (вкладка 1)
if (current_tab == 1 && click_press) {
    var _slot_size = round(38 * book_scale);
    var _slot_gap  = round(4  * book_scale);
    var _grid_cols = 5;
    var _grid_rows = 3;
    var _grid_x    = book_x + round(60 * book_scale);
    var _grid_y    = book_y + round(48 * book_scale);

    var _hit = false;
    for (var _r = 0; _r < _grid_rows; _r++) {
        for (var _c = 0; _c < _grid_cols; _c++) {
            var _sx = _grid_x + _c * (_slot_size + _slot_gap);
            var _sy = _grid_y + _r * (_slot_size + _slot_gap);
            if (mx >= _sx && mx <= _sx + _slot_size &&
                my >= _sy && my <= _sy + _slot_size) {
                var _idx = _r * _grid_cols + _c;
                selected_item = (_idx == selected_item) ? -1 : _idx; // повторный клик = снять выбор
                _hit = true;
            }
        }
    }
    // Клик вне сетки на левой странице — снимаем выбор
    if (!_hit && mx < book_x + book_w / 2) selected_item = -1;
}

// Клик на кнопку "Подробнее" в рецептах (вкладка 2)
if (current_tab == 2 && click_press) {
    var _recipes_unlocked2 = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;
    if (_recipes_unlocked2) {
        var _bs = book_scale;
        var _content_x2 = book_x + round(60 * _bs);
        var _content_y2 = book_y + round(60 * _bs);
        var _pbtn_x2 = _content_x2;
        var _pbtn_y2 = _content_y2 + round(56 * _bs);
        var _pbtn_w2 = round(90 * _bs);
        var _pbtn_h2 = round(22 * _bs);
        if (mx >= _pbtn_x2 && mx <= _pbtn_x2 + _pbtn_w2 &&
            my >= _pbtn_y2 && my <= _pbtn_y2 + _pbtn_h2) {
            recipe_detail_open = !recipe_detail_open;
        }
    }
}

// Закрытие по ESC или повторному нажатию
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("I"))) {
    global.control_locked = false;
    audio_play_sound(snd_book_close, 1, false, 0.6);
    instance_destroy();
}

// Закрытие по клику на кнопку-крестик (верхний правый угол книги)
if (click_press) {
    var _close_cx = book_x + 798 * _tab_sx;
    var _close_cy = book_y + 16  * _tab_sy;
    var _close_r  = round(10 * book_scale);
    if (point_distance(mx, my, _close_cx, _close_cy) <= _close_r) {
        global.control_locked = false;
        audio_play_sound(snd_book_close, 1, false, 0.6);
        instance_destroy();
        exit;
    }
}

// Закрытие по клику на тёмный фон (вне книги; вкладки нарисованы внутри книги, отдельно не выступают)
if (click_press) {
    var in_book = (mx >= book_x && mx <= book_x + book_w && my >= book_y && my <= book_y + book_h);

    if (!in_book) {
        global.control_locked = false;
        audio_play_sound(snd_book_close, 1, false, 0.6);
        instance_destroy();
    }
}
