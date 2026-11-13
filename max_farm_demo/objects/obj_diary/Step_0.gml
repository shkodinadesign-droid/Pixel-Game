// ===== DIARY STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Клик по вкладкам (нарисованы в спрайте книги, координаты — ui_tabs из Create)
for (var i = 0; i < 7; i++) {
    if (click_press
    &&  mx >= book_x + ui_tabs[i][0] && mx <= book_x + ui_tabs[i][2]
    &&  my >= book_y + ui_tabs[i][1] && my <= book_y + ui_tabs[i][3]) {
        current_tab = i;
    }
}

// Клик по заданиям (вкладка 0) — разметка как в Draw_64.gml
if (current_tab == 0 && click_press) {
    var _q_content_x = book_x + ui_list[0];
    var _q_rows_y    = book_y + ui_list[1];
    var _q_list_w    = ui_list[2];

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
    var _slot_size = ui_inv[2];
    var _slot_gap  = ui_inv[3];
    var _grid_cols = 5;
    var _grid_rows = 4;
    var _grid_x    = book_x + ui_inv[0];
    var _grid_y    = book_y + ui_inv[1];

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

// Клики во вкладке "Рецепты" (вкладка 2): категории + сетка 4x4
if (current_tab == 2 && click_press) {
    var _categories = diary_get_recipe_categories();
    var _cat_x0 = book_x + ui_rcat[0];
    var _cat_x1 = book_x + ui_rcat[2];
    var _cat_y0 = book_y + ui_rcat[1];
    var _cat_y1 = book_y + ui_rcat[3];
    var _cat_w  = (_cat_x1 - _cat_x0) / array_length(_categories);

    var _hit_cat = false;
    for (var _ci = 0; _ci < array_length(_categories); _ci++) {
        var _cx0 = _cat_x0 + _ci * _cat_w;
        var _cx1 = _cx0 + _cat_w;
        if (mx >= _cx0 && mx <= _cx1 && my >= _cat_y0 && my <= _cat_y1) {
            recipe_category = _categories[_ci].id;
            selected_recipe = "";
            _hit_cat = true;
            break;
        }
    }

    if (!_hit_cat) {
        var _grid_cols = 4;
        var _grid_rows = 4;
        var _slot_size = ui_rgrid[2];
        var _grid_gap  = ui_rgrid[3];
        var _grid_x    = book_x + ui_rgrid[0];
        var _grid_y    = book_y + ui_rgrid[1];

        var _cat_recipes = [];
        var _all_recipes = diary_get_recipe_list();
        for (var _ri = 0; _ri < array_length(_all_recipes); _ri++) {
            if (_all_recipes[_ri].category == recipe_category && _all_recipes[_ri].unlocked) {
                array_push(_cat_recipes, _all_recipes[_ri]);
            }
        }

        for (var _row = 0; _row < _grid_rows; _row++) {
            for (var _col = 0; _col < _grid_cols; _col++) {
                var _idx = _row * _grid_cols + _col;
                if (_idx >= array_length(_cat_recipes)) continue;
                var _sx = _grid_x + _col * (_slot_size + _grid_gap);
                var _sy = _grid_y + _row * (_slot_size + _grid_gap);
                if (mx >= _sx && mx <= _sx + _slot_size && my >= _sy && my <= _sy + _slot_size) {
                    selected_recipe = _cat_recipes[_idx].id;
                }
            }
        }
    }
}

// Клик по списку персонажей (вкладка 5 "Дружба")
if (current_tab == 5 && click_press) {
    var _fr_content_x = book_x + ui_list[0];
    var _fr_content_y = book_y + ui_list[1];

    var _fr_icon_sz = 36;
    var _fr_name_h  = 24;
    var _fr_row_gap = 12;
    var _fr_row_h   = max(_fr_icon_sz, _fr_name_h + 16) + _fr_row_gap;
    var _fr_list_w  = ui_list[2];

    var _fr_list = diary_get_friend_list();
    for (var _fi = 0; _fi < array_length(_fr_list); _fi++) {
        var _row_y = _fr_content_y + _fi * _fr_row_h;
        if (mx >= _fr_content_x && mx <= _fr_content_x + _fr_list_w &&
            my >= _row_y && my <= _row_y + _fr_row_h) {
            selected_friend = _fr_list[_fi].id;
            break;
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
    var _close_cx = book_x + ui_close[0];
    var _close_cy = book_y + ui_close[1];
    var _close_r  = ui_close[2];
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
