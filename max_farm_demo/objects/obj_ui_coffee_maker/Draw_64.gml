// ===== UI COFFEE MAKER DRAW GUI =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);

// Цвета ингредиентов
var _ing_color_map = ds_map_create();
ds_map_set(_ing_color_map, "coffee_beans", make_color_rgb(100,  60,  20));
ds_map_set(_ing_color_map, "water",        make_color_rgb(150, 210, 255));
ds_map_set(_ing_color_map, "milk",         make_color_rgb(220, 235, 255));
ds_map_set(_ing_color_map, "sugar",        make_color_rgb(240, 240, 220));

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

// Панель
draw_set_color(make_color_rgb(230, 215, 185));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, false);
draw_set_color(make_color_rgb(140, 100, 55));
draw_roundrect_ext(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, 8, 8, true);

// Заголовок
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(80, 50, 20));
draw_text(panel_x + panel_w / 2, panel_y + 10, "КОФЕМАШИНА");

// Закрытие
draw_set_halign(fa_right);
draw_set_color(make_color_rgb(130, 100, 70));
draw_text(panel_x + panel_w - 12, panel_y + 12, "[E] закрыть");

// Разделитель
draw_set_color(make_color_rgb(140, 100, 55));
draw_line(panel_x + bowl_area_w + 10, panel_y + 40,
          panel_x + bowl_area_w + 10, panel_y + panel_h - 10);

// =======================================================
// ЛЕВАЯ ЧАСТЬ — МИСКА (КРУЖКА)
// =======================================================

// Тень
draw_set_alpha(0.15);
draw_set_color(c_black);
draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy + bowl_ry - 10,
             bowl_cx + bowl_rx + 8, bowl_cy + bowl_ry + 6, false);
draw_set_alpha(1);

// Анимация готовки
var _cook_pulse = 0;
if (cook_anim > 0) {
    _cook_pulse = sin(cook_anim * 0.25) * 6;
    draw_set_alpha(0.3);
    draw_set_color(make_color_rgb(150, 100, 60));
    draw_ellipse(bowl_cx - bowl_rx - 12 + _cook_pulse,
                 bowl_cy - bowl_ry - 12 + _cook_pulse,
                 bowl_cx + bowl_rx + 12 - _cook_pulse,
                 bowl_cy + bowl_ry + 12 - _cook_pulse, false);
    draw_set_alpha(1);
}

// Кружка (тело)
draw_set_color(make_color_rgb(225, 210, 180));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4,
             bowl_cx + bowl_rx, bowl_cy + bowl_ry, false);
draw_set_color(make_color_rgb(210, 195, 160));
draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy - bowl_ry * 0.4 + 8,
             bowl_cx + bowl_rx - 8, bowl_cy + bowl_ry - 6, false);
draw_set_color(make_color_rgb(140, 100, 55));
draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4,
             bowl_cx + bowl_rx, bowl_cy + bowl_ry, true);

// Ободок
draw_set_color(make_color_rgb(200, 180, 145));
draw_ellipse(bowl_cx - bowl_rx,   bowl_cy - bowl_ry * 0.4 - 8,
             bowl_cx + bowl_rx,   bowl_cy - bowl_ry * 0.4 + 8, false);
draw_set_color(make_color_rgb(140, 100, 55));
draw_ellipse(bowl_cx - bowl_rx,   bowl_cy - bowl_ry * 0.4 - 8,
             bowl_cx + bowl_rx,   bowl_cy - bowl_ry * 0.4 + 8, true);

// Ингредиенты в кружке — иконки
var _bi_count = array_length(bowl_items);
for (var i = 0; i < _bi_count; i++) {
    var _angle = (i / max(1, _bi_count)) * 2 * pi + pi * 0.3;
    var _bx    = bowl_cx + cos(_angle) * (bowl_rx * 0.45);
    var _by    = bowl_cy + sin(_angle) * (bowl_ry * 0.35) + 8;
    var _binfo = storage_get_item_info(bowl_items[i]);
    var _bhas  = (_binfo != undefined && variable_struct_exists(_binfo, "icon"));
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
        draw_set_alpha(0.2);
        draw_set_color(c_black);
        draw_circle(_bx, _by, 12, true);
        draw_set_alpha(1);
    }
}

// Анимации полёта
for (var i = 0; i < array_length(fly_anims); i++) {
    var _fa    = fly_anims[i];
    var _fx    = lerp(_fa.sx, bowl_cx, _fa.t);
    var _fy    = lerp(_fa.sy, bowl_cy + 10, _fa.t) - sin(_fa.t * pi) * 45;
    var _r2    = lerp(10, 12, _fa.t);
    var _finfo = storage_get_item_info(_fa.item_id);
    var _fhas  = (_finfo != undefined && variable_struct_exists(_finfo, "icon"));
    if (_fhas) {
        var _fspr = _finfo.icon;
        var _fisc = variable_struct_exists(_finfo, "icon_scale") ? _finfo.icon_scale : 1.0;
        var _fsc  = ((_r2 * 2) / sprite_get_width(_fspr)) * _fisc;
        draw_sprite_ext(_fspr, 0, _fx, _fy, _fsc, _fsc, 0, c_white, 1);
    } else {
        var _col = ds_map_find_value(_ing_color_map, _fa.item_id);
        if (_col == undefined) _col = make_color_rgb(180, 180, 180);
        draw_set_color(_col);
        draw_circle(_fx, _fy, _r2, false);
        draw_set_alpha(0.4);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_circle(_fx, _fy, _r2, true);
        draw_set_alpha(1);
    }
}

// Всплески
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

// "Готово!" после готовки
if (cook_done) {
    var _rname = coffee_recipes[selected_recipe].name;
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(60, 140, 60));
    draw_text(bowl_cx, bowl_cy - bowl_ry - 20, "Готово!");
    draw_set_color(make_color_rgb(80, 50, 20));
    draw_text(bowl_cx, bowl_cy - bowl_ry - 2, "+ " + _rname);
}

// =======================================================
// ПРАВАЯ ЧАСТЬ — РЕЦЕПТ + ЯЧЕЙКИ
// =======================================================

var _r = coffee_recipes[selected_recipe];
var _ing_count = array_length(_r.ingredients);

// --- Стрелки навигации рецептов ---
var _arr_w  = 26;
var _nav_y  = tab_y;
var _nav_h  = tab_h + 4;
var _arr_lx = right_x;
var _arr_rx = right_x + right_w - _arr_w;
var _hover_l = (mx >= _arr_lx && mx <= _arr_lx + _arr_w && my >= _nav_y && my <= _nav_y + _nav_h);
var _hover_r = (mx >= _arr_rx && mx <= _arr_rx + _arr_w && my >= _nav_y && my <= _nav_y + _nav_h);

draw_set_color(_hover_l ? make_color_rgb(200, 160, 100) : make_color_rgb(160, 120, 70));
draw_roundrect_ext(_arr_lx, _nav_y, _arr_lx + _arr_w, _nav_y + _nav_h, 4, 4, false);
draw_set_font(fnt_ui);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(255, 245, 220));
draw_text(_arr_lx + _arr_w / 2, _nav_y + _nav_h / 2, "<");

draw_set_color(_hover_r ? make_color_rgb(200, 160, 100) : make_color_rgb(160, 120, 70));
draw_roundrect_ext(_arr_rx, _nav_y, _arr_rx + _arr_w, _nav_y + _nav_h, 4, 4, false);
draw_set_color(make_color_rgb(255, 245, 220));
draw_text(_arr_rx + _arr_w / 2, _nav_y + _nav_h / 2, ">");

// Название рецепта между стрелками
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(80, 50, 20));
draw_text(right_x + right_w / 2, _nav_y + _nav_h / 2, _r.name);

// --- Чеклист ингредиентов ---
var _check_y = panel_y + 96;
for (var i = 0; i < _ing_count; i++) {
    var _ing     = _r.ingredients[i];
    var _item_id = _ing.item;
    var _in_bowl = false;
    for (var j = 0; j < array_length(bowl_items); j++) {
        if (bowl_items[j] == _item_id) { _in_bowl = true; break; }
    }
    var _done = _in_bowl;
    var _info = storage_get_item_info(_item_id);
    var _name = (_info != undefined) ? _info.name : _item_id;

    var _cb_mid_y = _check_y + 8;
    if (_done) {
        draw_set_color(make_color_rgb(50, 150, 50));
        draw_rectangle(right_x, _check_y, right_x + 16, _check_y + 16, false);
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(right_x + 8, _cb_mid_y, "v");
        draw_set_halign(fa_left);
    } else {
        draw_set_color(make_color_rgb(190, 55, 55));
        draw_rectangle(right_x, _check_y, right_x + 16, _check_y + 16, false);
        draw_set_color(make_color_rgb(130, 30, 30));
        draw_rectangle(right_x, _check_y, right_x + 16, _check_y + 16, true);
    }
    draw_set_halign(fa_left);
    draw_set_valign(fa_middle);
    draw_set_color(_done ? make_color_rgb(60, 130, 60) : make_color_rgb(80, 55, 25));
    draw_text(right_x + 30, _cb_mid_y, _name + " x" + string(_ing.amount));
    draw_set_valign(fa_top);
    _check_y += 26;
}

// --- Ячейки ингредиентов ---
for (var i = 0; i < _ing_count; i++) {
    var _col = i mod cells_cols;
    var _row = i div cells_cols;
    var _cx  = right_x + _col * (cell_size + cell_gap);
    var _cy  = cell_area_y + _row * (cell_size + cell_gap);

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

    var _is_hover  = (hover_cell == i);
    var _can_add   = (!_in_bowl && !_in_fly && _have >= _needed);
    var _offset_y  = (_is_hover && _can_add) ? -4 : 0;
    var _cell_alpha = (_in_bowl || _in_fly) ? 0.35 : 1.0;
    draw_set_alpha(_cell_alpha);

    var _col_bg = (_is_hover && _can_add) ? make_color_rgb(220, 200, 160) : make_color_rgb(205, 185, 148);
    draw_set_color(_col_bg);
    draw_roundrect_ext(_cx, _cy + _offset_y, _cx + cell_size, _cy + cell_size + _offset_y, 6, 6, false);

    var _col_border = (_have >= _needed) ? make_color_rgb(120, 170, 90) : make_color_rgb(180, 80, 60);
    draw_set_color(_col_border);
    draw_roundrect_ext(_cx, _cy + _offset_y, _cx + cell_size, _cy + cell_size + _offset_y, 6, 6, true);

    // Иконка по центру ячейки
    var _info_ic2  = storage_get_item_info(_item_id);
    var _has_icon2 = (_info_ic2 != undefined && variable_struct_exists(_info_ic2, "icon"));
    if (_has_icon2) {
        var _spr_ic2  = _info_ic2.icon;
        var _icon_sz2 = cell_size - 10;
        var _isc2     = variable_struct_exists(_info_ic2, "icon_scale") ? _info_ic2.icon_scale : 1.0;
        var _sw2      = sprite_get_width(_spr_ic2);
        var _sh2      = sprite_get_height(_spr_ic2);
        var _spr_sc2  = min(_icon_sz2 / _sw2, _icon_sz2 / _sh2) * _isc2;
        var _dw2      = _sw2 * _spr_sc2;
        var _dh2      = _sh2 * _spr_sc2;
        var _ccx2     = _cx + cell_size / 2;
        var _ccy2     = _cy + cell_size / 2 + _offset_y;
        draw_sprite_stretched_ext(_spr_ic2, 0,
            _ccx2 - _dw2 / 2, _ccy2 - _dh2 / 2, _dw2, _dh2,
            c_white, _cell_alpha);
    } else {
        var _ic = ds_map_find_value(_ing_color_map, _item_id);
        if (_ic == undefined) _ic = make_color_rgb(180, 180, 180);
        draw_set_color(_ic);
        draw_circle(_cx + cell_size / 2, _cy + cell_size / 2 + _offset_y, 16, false);
        draw_set_alpha(_cell_alpha * 0.2);
        draw_set_color(c_black);
        draw_circle(_cx + cell_size / 2, _cy + cell_size / 2 + _offset_y, 16, true);
        draw_set_alpha(_cell_alpha);
    }

    // Количество — внутри ячейки сверху справа
    draw_set_font(fnt_ui);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_set_color(_have >= _needed ? make_color_rgb(50, 120, 50) : make_color_rgb(180, 50, 50));
    draw_text(_cx + cell_size - 4, _cy + 4 + _offset_y, string(_have));

    // Название — под ячейкой (перенос по ширине ячейки)
    var _info2 = storage_get_item_info(_item_id);
    var _iname = (_info2 != undefined) ? _info2.name : _item_id;
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(60, 35, 10));
    draw_text_ext(_cx + cell_size / 2, _cy + cell_size + 3 + _offset_y, _iname, 14, cell_size);

    draw_set_alpha(1);
}

// --- Кнопка Готовить ---
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
    draw_set_color(_cooking ? make_color_rgb(180, 130, 50)
                 : (_btn_hover ? make_color_rgb(100, 60, 15)
                 : make_color_rgb(139, 90, 43)));
    draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 6, 6, false);
    draw_set_color(make_color_rgb(200, 170, 130));
    draw_roundrect_ext(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, 6, 6, true);
    draw_set_font(fnt_ui);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(255, 245, 220));
    draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2,
              _cooking ? "Готовится..." : "Готовить");
}

ds_map_destroy(_ing_color_map);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
