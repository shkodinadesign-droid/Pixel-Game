// ===== DIARY STEP =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

var click_now = mouse_check_button(mb_left);
var click_press = (click_now && !_click_prev);
_click_prev = click_now;

// Проверка клика по вкладкам (сверху)
var _recipes_unlocked = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;

for (var i = 0; i < 7; i++) {
    var tx1 = tab_start_x + i * (tab_w + tab_spacing);
    var ty1 = book_y - tab_h + round(5 * book_scale);
    var tx2 = tx1 + tab_w;
    var ty2 = ty1 + tab_h;

    if (mx >= tx1 && mx <= tx2 && my >= ty1 && my <= ty2) {
        if (click_press) {
            // Вкладка Рецепты (3) заблокирована до катсцены Джастина
            if (i == 3 && !_recipes_unlocked) break;
            current_tab = i;
        }
    }
}

// Клик по слотам инвентаря (вкладка 0)
if (current_tab == 0 && click_press) {
    var _slot_size = round(38 * book_scale);
    var _slot_gap  = round(4  * book_scale);
    var _grid_cols = 5;
    var _grid_rows = 3;
    var _grid_x    = book_x + round(40 * book_scale);
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

// Клик на кнопку "Подробнее" в рецептах (вкладка 3)
if (current_tab == 3 && click_press) {
    var _recipes_unlocked2 = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;
    if (_recipes_unlocked2) {
        var _bs = book_scale;
        var _content_x2 = book_x + round(30 * _bs);
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
    instance_destroy();
}

// Закрытие по клику на тёмный фон (вне книги)
if (click_press) {
    var in_book = (mx >= book_x && mx <= book_x + book_w && my >= book_y && my <= book_y + book_h);
    var in_tabs = (mx >= tab_start_x && mx <= tab_start_x + 7 * (tab_w + tab_spacing) && my >= book_y - tab_h + round(5 * book_scale) && my <= book_y + round(5 * book_scale));

    if (!in_book && !in_tabs) {
        global.control_locked = false;
        instance_destroy();
    }
}
