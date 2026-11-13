// ===== DIARY STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Клик по вкладкам (спрайты spr_ui_tab_*, координаты — ui_tabs из Create)
for (var i = 0; i < 7; i++) {
    if (click_press
    &&  mx >= book_x + ui_tabs[i][0] && mx < book_x + ui_tabs[i][2]
    &&  my >= book_y + ui_tabs[i][1] && my < book_y + ui_tabs[i][3]) {
        current_tab = i;
    }
}

// Задания (вкладка 0): карточки текущей страницы + стрелки листания — разметка как в Draw_64.gml
if (current_tab == 0 && click_press) {
    var _pages = diary_quest_build_pages(book_x + ui_list[0], book_y + ui_list[1], ui_list[3]);
    quest_page = clamp(quest_page, 0, array_length(_pages) - 1);
    if (array_length(_pages) > 1) {
        var _ay = book_y + ui_arrows[2];
        if (my >= _ay && my < _ay + 20) {
            if (mx >= book_x + ui_arrows[0] && mx < book_x + ui_arrows[0] + 20 && quest_page > 0) quest_page--;
            if (mx >= book_x + ui_arrows[1] && mx < book_x + ui_arrows[1] + 20 && quest_page < array_length(_pages) - 1) quest_page++;
        }
    }
    var _rows = _pages[quest_page];
    for (var _qi = 0; _qi < array_length(_rows); _qi++) {
        var _qrow = _rows[_qi];
        if (_qrow.type != "quest") continue;
        if (mx >= _qrow.x && mx < _qrow.x + 320 && my >= _qrow.y && my < _qrow.y + _qrow.h) {
            selected_quest = _qrow.q.id;
            diary_quest_mark_read(_qrow.q.id);
            break;
        }
    }
}

// Клик по слотам инвентаря (вкладка 1)
if (current_tab == 1 && click_press) {
    var _slot_size = ui_inv[2];
    var _step      = ui_inv[2] + ui_inv[3];
    var _grid_x    = book_x + ui_inv[0];
    var _grid_y    = book_y + ui_inv[1];

    var _hit = false;
    for (var _r = 0; _r < 4; _r++) {
        for (var _c = 0; _c < 5; _c++) {
            var _sx = _grid_x + _c * _step;
            var _sy = _grid_y + _r * _step;
            if (mx >= _sx && mx < _sx + _slot_size && my >= _sy && my < _sy + _slot_size) {
                var _idx = _r * 5 + _c;
                selected_item = (_idx == selected_item) ? -1 : _idx; // повторный клик = снять выбор
                _hit = true;
            }
        }
    }
    // Клик вне сетки на левой странице — снимаем выбор
    if (!_hit && mx < book_x + book_w / 2 && my > book_y + ui_list[1]) selected_item = -1;
}

// Рецепты (вкладка 2): категории + сетка 4x4 (закрытые рецепты не выбираются)
if (current_tab == 2 && click_press) {
    var _categories = diary_get_recipe_categories();
    for (var _ci = 0; _ci < array_length(_categories); _ci++) {
        var _bx = book_x + ui_rcat[0] + _ci * (ui_rcat[2] + ui_rcat[3]);
        var _by = book_y + ui_rcat[1];
        if (mx >= _bx && mx < _bx + ui_rcat[2] && my >= _by && my < _by + 26) {
            recipe_category = _categories[_ci].id;
            selected_recipe = "";
        }
    }
    var _cat_recipes = diary_recipes_in_category(diary_get_recipe_list(), recipe_category);
    var _rstep = ui_rgrid[2] + ui_rgrid[3];
    for (var _gi = 0; _gi < min(16, array_length(_cat_recipes)); _gi++) {
        var _sx = book_x + ui_rgrid[0] + (_gi mod 4) * _rstep;
        var _sy = book_y + ui_rgrid[1] + (_gi div 4) * _rstep;
        if (_cat_recipes[_gi].unlocked && mx >= _sx && mx < _sx + ui_rgrid[2] && my >= _sy && my < _sy + ui_rgrid[2]) {
            selected_recipe = _cat_recipes[_gi].id;
        }
    }
}

// Растения (вкладка 3): карточки 320x56 с шагом 62
if (current_tab == 3 && click_press) {
    var _plants = diary_get_plant_list();
    for (var _pi = 0; _pi < array_length(_plants); _pi++) {
        var _px = book_x + ui_list[0], _py = book_y + ui_list[1] + _pi * 62;
        if (mx >= _px && mx < _px + 320 && my >= _py && my < _py + 56) selected_plant = _pi;
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
    var _cl_x = book_x + ui_close[0], _cl_y = book_y + ui_close[1];
    if (mx >= _cl_x && mx < _cl_x + 30 && my >= _cl_y && my < _cl_y + 30) {
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
