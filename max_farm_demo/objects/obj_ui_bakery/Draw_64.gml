// ===== UI BAKERY DRAW GUI =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// --- Вспомогательная функция цвета ингредиента ---
var _ing_color_map = ds_map_create();
ds_map_set(_ing_color_map, "potato", make_color_rgb(220,170,50));
ds_map_set(_ing_color_map, "milk",   make_color_rgb(220,235,255));
ds_map_set(_ing_color_map, "egg",    make_color_rgb(255,220,80));
ds_map_set(_ing_color_map, "flour",  make_color_rgb(235,225,205));
ds_map_set(_ing_color_map, "yeast",  make_color_rgb(160,110,55));
ds_map_set(_ing_color_map, "carrot", make_color_rgb(255,130,30));
ds_map_set(_ing_color_map, "sugar",  make_color_rgb(240,240,220));
ds_map_set(_ing_color_map, "apple",  make_color_rgb(180,220,80));

// Во время анимации питья — панель не рисуем
if (drink_phase) {
    ds_map_destroy(_ing_color_map);
    exit;
}

// Затемнение фона
draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// --- Книга (как дневник): слева рецепт, справа миска ---
draw_sprite(spr_storage_bg, 0, panel_x, panel_y);

// Крестик
var _cl_hover = (mx >= close_x && mx < close_x + 30 && my >= close_y && my < close_y + 30);
draw_sprite(_cl_hover ? spr_ui_close_hover : spr_ui_close_normal, 0, close_x, close_y);

// Заголовки в табличках: название рецепта слева, "Миска" справа
var _r_title = visible_recipes[selected_recipe];
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(70, 40, 15));
draw_text(left_cx,  title_y, _r_title.name);
draw_text(right_cx, title_y, "Миска");

// Подсказки внизу страниц
draw_set_font(fnt_ui);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(left_cx,  hint_y, "Клик по ингредиенту - в миску");
draw_text(right_cx, hint_y, "[E] закрыть");

// =======================================================
// ПРАВАЯ СТРАНИЦА — МИСКА
// =======================================================

// Тень миски
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy + bowl_ry - 10,
             bowl_cx + bowl_rx + 8, bowl_cy + bowl_ry + 6, false);
draw_set_alpha(1);

// Анимация готовки — пульсация
var _cook_pulse = 0;
if (cook_anim > 0) {
    _cook_pulse = sin(cook_anim * 0.25) * 6;
    // Свечение вокруг миски
    draw_set_alpha(0.3);
    draw_set_color(make_color_rgb(255, 200, 80));
    draw_ellipse(bowl_cx - bowl_rx - 12 + _cook_pulse,
                 bowl_cy - bowl_ry - 12 + _cook_pulse,
                 bowl_cx + bowl_rx + 12 - _cook_pulse,
                 bowl_cy + bowl_ry + 12 - _cook_pulse, false);
    draw_set_alpha(1);
}

// Тело миски
draw_set_color(make_color_rgb(225, 210, 180));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4,
             bowl_cx + bowl_rx, bowl_cy + bowl_ry, false);

// Внутренность миски (чуть темнее)
draw_set_color(make_color_rgb(210, 195, 160));
draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy - bowl_ry * 0.4 + 8,
             bowl_cx + bowl_rx - 8, bowl_cy + bowl_ry - 6, false);

// Обводка миски
draw_set_color(make_color_rgb(140, 100, 55));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4,
             bowl_cx + bowl_rx, bowl_cy + bowl_ry, true);

// Ободок (горизонтальный эллипс сверху)
draw_set_color(make_color_rgb(200, 180, 145));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4 - 8,
             bowl_cx + bowl_rx, bowl_cy - bowl_ry * 0.4 + 8, false);
draw_set_color(make_color_rgb(140, 100, 55));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4 - 8,
             bowl_cx + bowl_rx, bowl_cy - bowl_ry * 0.4 + 8, true);

// Ингредиенты в миске — иконки
var _bi_count = array_length(bowl_items);
for (var i = 0; i < _bi_count; i++) {
    var _angle  = (i / max(1, _bi_count)) * 2 * pi + pi * 0.3;
    var _bx     = bowl_cx + cos(_angle) * (bowl_rx * 0.45);
    var _by     = bowl_cy + sin(_angle) * (bowl_ry * 0.35) + 8;
    var _binfo  = storage_get_item_info(bowl_items[i]);
    var _bhas   = (_binfo != undefined && variable_struct_exists(_binfo, "icon") && sprite_exists(_binfo.icon));
    if (_bhas) {
        var _bspr = _binfo.icon;
        var _bisc = variable_struct_exists(_binfo, "icon_scale") ? _binfo.icon_scale : 1.0;
        var _bsc  = (22 / sprite_get_width(_bspr)) * _bisc;
        draw_sprite_ext(_bspr, 0, _bx, _by, _bsc, _bsc, 0, c_white, 1);
    } else {
        var _col = ds_map_find_value(_ing_color_map, bowl_items[i]);
        if (_col == undefined) _col = make_color_rgb(180, 180, 180);
        draw_set_color(_col);
        draw_circle(_bx, _by, 12, false);
        draw_set_color(make_color_rgb(0,0,0));
        draw_set_alpha(0.2);
        draw_circle(_bx, _by, 12, true);
        draw_set_alpha(1);
    }
}

// Анимации полёта ингредиентов
for (var i = 0; i < array_length(fly_anims); i++) {
    var _fa    = fly_anims[i];
    var _fx    = lerp(_fa.sx, bowl_cx, _fa.t);
    var _fy    = lerp(_fa.sy, bowl_cy + 10, _fa.t) - sin(_fa.t * pi) * 45;
    var _r2    = lerp(10, 12, _fa.t);
    var _finfo = storage_get_item_info(_fa.item_id);
    var _fhas  = (_finfo != undefined && variable_struct_exists(_finfo, "icon") && sprite_exists(_finfo.icon));
    if (_fhas) {
        var _fspr = _finfo.icon;
        var _fisc = variable_struct_exists(_finfo, "icon_scale") ? _finfo.icon_scale : 1.0;
        var _fsc  = ((_r2 * 2) / sprite_get_width(_fspr)) * _fisc;
        draw_sprite_ext(_fspr, 0, _fx, _fy, _fsc, _fsc, 0, c_white, 1);
    } else {
        var _col = ds_map_find_value(_ing_color_map, _fa.item_id);
        if (_col == undefined) _col = make_color_rgb(180,180,180);
        draw_set_color(_col);
        draw_circle(_fx, _fy, _r2, false);
        draw_set_color(make_color_rgb(80,50,20));
        draw_set_alpha(0.4);
        draw_circle(_fx, _fy, _r2, true);
        draw_set_alpha(1);
    }
}

// Анимации всплеска при попадании в миску
for (var i = 0; i < array_length(splash_anims); i++) {
    var _sa  = splash_anims[i];
    var _sr  = lerp(4, 32, _sa.t);
    var _sal = (1 - _sa.t) * 0.6;
    var _sc  = ds_map_find_value(_ing_color_map, _sa.item_id);
    if (_sc == undefined) _sc = c_white;
    draw_set_alpha(_sal);
    draw_set_color(_sc);
    draw_circle(_sa.x, _sa.y, _sr, true);
    draw_set_alpha(1);
}

// Текст "Готово!" после готовки
if (cook_done) {
    var _r = visible_recipes[selected_recipe];
    var _res_info = storage_get_item_info(_r.result.item);
    var _res_name = (_res_info != undefined) ? _res_info.name : _r.result.item;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(60,140,60));
    draw_text(bowl_cx, bowl_cy - bowl_ry - 20, "Готово!");
    draw_set_font(fnt_ui);
    draw_set_color(make_color_rgb(80,50,20));
    draw_text(bowl_cx, bowl_cy - bowl_ry - 2, "+ " + _res_name);
}

// =======================================================
// ЛЕВАЯ СТРАНИЦА — НОМЕР РЕЦЕПТА + ЯЧЕЙКИ
// =======================================================

var _r = visible_recipes[selected_recipe];
var _ing_count = array_length(_r.ingredients);

// --- Стрелки листания рецептов и номер между ними ---
var _rc_count = array_length(visible_recipes);
var _can_nav  = (_rc_count > 1) && cook_anim == 0 && !cook_done;
draw_sprite(_can_nav ? spr_ui_arrow_left_normal  : spr_ui_arrow_left_disabled,  0, arr_l_x, arr_y);
draw_sprite(_can_nav ? spr_ui_arrow_right_normal : spr_ui_arrow_right_disabled, 0, arr_r_x, arr_y);
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(120, 85, 50));
draw_text(left_cx, arr_y + 10, "Рецепт " + string(selected_recipe + 1) + " из " + string(_rc_count));

// --- Ячейки ингредиентов ---
for (var i = 0; i < _ing_count; i++) {
    var _col = i mod cells_cols;
    var _row = i div cells_cols;
    var _cx  = cells_x + _col * cell_step_x;
    var _cy  = cell_area_y + _row * cell_step_y;

    var _item_id = _r.ingredients[i].item;
    var _needed  = _r.ingredients[i].amount;
    var _have    = inventory_get_amount(_item_id);

    var _in_bowl = false;
    for (var j = 0; j < array_length(bowl_items); j++) {
        if (bowl_items[j] == _item_id) { _in_bowl = true; break; }
    }
    var _in_fly = false;
    for (var j = 0; j < array_length(fly_anims); j++) {
        if (fly_anims[j].item_id == _item_id) { _in_fly = true; break; }
    }

    var _is_hover = (hover_cell == i);
    var _can_add  = (!_in_bowl && !_in_fly && _have >= _needed);

    // Hover — ячейка чуть приподнимается
    var _offset_y = (_is_hover && _can_add) ? -4 : 0;

    // Фон ячейки
    var _cell_alpha = (_in_bowl || _in_fly) ? 0.35 : 1.0;
    draw_set_alpha(_cell_alpha);

    // Ячейка: при наведении (если можно добавить) — подсвеченная; уже в миске — бледная
    draw_sprite_ext((_is_hover && _can_add) ? spr_ui_inventory_slot_hover : ((_have >= _needed) ? spr_ui_inventory_slot_item : spr_ui_inventory_slot_empty),
                    0, _cx, _cy + _offset_y, 1, 1, 0, c_white, _cell_alpha);

    // Иконка по центру ячейки
    var _info_ic  = storage_get_item_info(_item_id);
    var _has_icon = (_info_ic != undefined && variable_struct_exists(_info_ic, "icon") && sprite_exists(_info_ic.icon));
    if (_has_icon) {
        var _spr_ic  = _info_ic.icon;
        var _sw      = sprite_get_width(_spr_ic);
        var _sh      = sprite_get_height(_spr_ic);
        var _spr_sc  = (max(_sw, _sh) <= 40) ? 1 : 36 / max(_sw, _sh);   // иконки 32x32 — 1:1
        if (variable_struct_exists(_info_ic, "icon_scale")) _spr_sc *= _info_ic.icon_scale;
        draw_sprite_ext(_spr_ic, 0,
            _cx + (cell_size - _sw * _spr_sc) / 2 + sprite_get_xoffset(_spr_ic) * _spr_sc,
            _cy + (cell_size - _sh * _spr_sc) / 2 + sprite_get_yoffset(_spr_ic) * _spr_sc + _offset_y,
            _spr_sc, _spr_sc, 0, c_white, _cell_alpha);
    } else {
        var _ic = ds_map_find_value(_ing_color_map, _item_id);
        if (_ic == undefined) _ic = make_color_rgb(180, 180, 180);
        draw_set_color(_ic);
        draw_circle(_cx + cell_size / 2, _cy + cell_size / 2 + _offset_y, 16, false);
        draw_set_color(make_color_rgb(0,0,0));
        draw_set_alpha(_cell_alpha * 0.2);
        draw_circle(_cx + cell_size / 2, _cy + cell_size / 2 + _offset_y, 16, true);
        draw_set_alpha(_cell_alpha);
    }

    // Сколько есть — бейдж в углу (красная цифра, если не хватает); галочка — уже в миске
    if (_in_bowl) {
        draw_sprite(spr_ui_quest_status_done, 0, _cx + cell_size - 12, _cy + cell_size - 12 + _offset_y);
    } else {
        draw_sprite(spr_ui_count_badge, 0, _cx + cell_size - 12, _cy + cell_size - 12 + _offset_y);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(_have >= _needed ? c_white : make_color_rgb(255, 120, 110));
        draw_text(_cx + cell_size - 4, _cy + cell_size - 4 + _offset_y, string(_have));
    }

    // Название — под ячейкой (перенос по ширине ячейки)
    var _info = storage_get_item_info(_item_id);
    var _iname = (_info != undefined) ? _info.name : _item_id;
    if (_needed > 1) _iname += " x" + string(_needed);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(60, 35, 10));
    draw_text_ext(_cx + cell_size / 2, _cy + cell_size + 6 + _offset_y, _iname, 14, cell_step_x - 4);

    draw_set_alpha(1);
}

// --- Кнопка ГОТОВИТЬ ---
// Видна только когда все ингредиенты в миске
var _all_added = (_ing_count > 0);
for (var i = 0; i < _ing_count; i++) {
    var _id    = _r.ingredients[i].item;
    var _found = false;
    for (var j = 0; j < array_length(bowl_items); j++) {
        if (bowl_items[j] == _id) { _found = true; break; }
    }
    if (!_found) { _all_added = false; break; }
}

if (_all_added && !cook_done) {
    var _btn_hover = (mx >= btn_x && mx <= btn_x + btn_w &&
                      my >= btn_y && my <= btn_y + btn_h);
    var _cooking   = (cook_anim > 0);

    draw_sprite(spr_ui_quantity_label_200x28, 0, btn_x, btn_y);
    if (_btn_hover || _cooking) {
        draw_set_alpha(0.3);
        draw_set_color(c_white);
        draw_roundrect_ext(btn_x + 3, btn_y + 3, btn_x + btn_w - 3, btn_y + btn_h - 3, 4, 4, false);
        draw_set_alpha(1);
    }

    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_color(make_color_rgb(70, 40, 15));
    draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2,
              _cooking ? "Готовится..." : "Готовить");
}

// После готовки — кнопку убираем (авто-закрытие)

// Очищаем ds_map
ds_map_destroy(_ing_color_map);

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
