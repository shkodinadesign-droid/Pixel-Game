// ===== UI BAKERY DRAW GUI (подложка spr_cook_bg по макету: слева блюдо, справа рецепт) =====

var mx = device_mouse_x_to_gui(0);
var my = device_mouse_y_to_gui(0);
var _txt_dark = make_color_rgb(70, 40, 15);
var _txt_mid  = make_color_rgb(140, 105, 70);

// --- Цвет-заглушка ингредиента (если нет иконки) ---
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

/// иконка предмета 1:1 (32x32), по центру точки; бледная при _a < 1
var _draw_item = function(_item_id, _cx, _cy, _a, _cmap) {
    var _s = ingredient_icon(_item_id);                       // spr_ingr_* (до 40 px) или обычная иконка
    if (_s != -1) {
        var _sw = sprite_get_width(_s), _sh = sprite_get_height(_s);
        var _sc = (max(_sw, _sh) <= 40) ? 1 : 36 / max(_sw, _sh);
        draw_sprite_ext(_s, 0, round(_cx - _sw * _sc / 2) + sprite_get_xoffset(_s) * _sc, round(_cy - _sh * _sc / 2) + sprite_get_yoffset(_s) * _sc,
                        _sc, _sc, 0, c_white, _a);
    } else {
        var _col = ds_map_find_value(_cmap, _item_id);
        if (_col == undefined) _col = make_color_rgb(180, 180, 180);
        draw_set_alpha(_a);
        draw_set_color(_col);
        draw_circle(_cx, _cy, 12, false);
        draw_set_alpha(1);
    }
};

// Затемнение фона
draw_set_alpha(0.55);
draw_set_color(c_black);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Подложка
draw_sprite(spr_cook_bg, 0, panel_x, panel_y);

// Табличка и подсказка закрытия
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_txt_dark);
draw_text(title_x, title_y, "Пекарня");
draw_set_halign(fa_right);
draw_set_color(_txt_mid);
draw_text(close_rx, close_cy, "[E] закрыть");

var _r = visible_recipes[selected_recipe];
var _ing_count = array_length(_r.ingredients);

// =======================================================
// ЛЕВАЯ РАМКА — БЛЮДО (или миска, если картинки нет)
// =======================================================

var _dish = recipe_dish_image(_r.id);

// Свечение при готовке
if (cook_anim > 0) {
    var _pulse = sin(cook_anim * 0.25) * 6;
    draw_set_alpha(0.3);
    draw_set_color(make_color_rgb(255, 200, 80));
    draw_ellipse(frame_cx - 80 + _pulse, frame_cy - 62 + _pulse, frame_cx + 80 - _pulse, frame_cy + 62 - _pulse, false);
    draw_set_alpha(1);
}

if (sprite_exists(_dish)) {
    var _dw = sprite_get_width(_dish), _dh = sprite_get_height(_dish);
    var _dsc = min(1, min(170 / _dw, 150 / _dh));
    draw_sprite_ext(_dish, 0, frame_cx - _dw * _dsc / 2 + sprite_get_xoffset(_dish) * _dsc,
                    frame_cy - _dh * _dsc / 2 + sprite_get_yoffset(_dish) * _dsc, _dsc, _dsc, 0, c_white, 1);
} else {
    // Миска
    draw_set_alpha(0.15);
    draw_set_color(c_black);
    draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy + bowl_ry - 10, bowl_cx + bowl_rx + 8, bowl_cy + bowl_ry + 6, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(225, 210, 180));
    draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4, bowl_cx + bowl_rx, bowl_cy + bowl_ry, false);
    draw_set_color(make_color_rgb(210, 195, 160));
    draw_ellipse(bowl_cx - bowl_rx + 8, bowl_cy - bowl_ry * 0.4 + 8, bowl_cx + bowl_rx - 8, bowl_cy + bowl_ry - 6, false);
    draw_set_color(make_color_rgb(140, 100, 55));
    draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4, bowl_cx + bowl_rx, bowl_cy + bowl_ry, true);
    draw_set_color(make_color_rgb(200, 180, 145));
    draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4 - 8, bowl_cx + bowl_rx, bowl_cy - bowl_ry * 0.4 + 8, false);
    draw_set_color(make_color_rgb(140, 100, 55));
    draw_ellipse(bowl_cx - bowl_rx, bowl_cy - bowl_ry * 0.4 - 8, bowl_cx + bowl_rx, bowl_cy - bowl_ry * 0.4 + 8, true);
}

// Уже добавленные ингредиенты — рядок иконок под блюдом
var _bi_count = array_length(bowl_items);
for (var i = 0; i < _bi_count; i++) {
    var _bx = frame_cx + (i - (_bi_count - 1) / 2) * 36;
    _draw_item(bowl_items[i], _bx, frame_cy + 88, 1, _ing_color_map);
}

// Полёт ингредиентов в рамку
for (var i = 0; i < array_length(fly_anims); i++) {
    var _fa = fly_anims[i];
    var _fx = lerp(_fa.sx, bowl_cx, _fa.t);
    var _fy = lerp(_fa.sy, bowl_cy + 10, _fa.t) - sin(_fa.t * pi) * 45;
    _draw_item(_fa.item_id, _fx, _fy, 1, _ing_color_map);
}

// Всплески
for (var i = 0; i < array_length(splash_anims); i++) {
    var _sa = splash_anims[i];
    var _sc = ds_map_find_value(_ing_color_map, _sa.item_id);
    if (_sc == undefined) _sc = c_white;
    draw_set_alpha((1 - _sa.t) * 0.6);
    draw_set_color(_sc);
    draw_circle(_sa.x, _sa.y, lerp(4, 32, _sa.t), true);
    draw_set_alpha(1);
}

// "Готово!" — вверху рамки
if (cook_done) {
    var _res_info = storage_get_item_info(_r.result.item);
    var _res_name = (_res_info != undefined) ? _res_info.name : _r.result.item;
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(60, 140, 60));
    draw_text(frame_cx, frame_y0 + 18, "Готово!");
    draw_set_font(fnt_ui);
    draw_set_color(_txt_dark);
    draw_text(frame_cx, frame_y0 + 38, "+ " + _res_name);
}

// =======================================================
// ПРАВАЯ КОЛОНКА — РЕЦЕПТ
// =======================================================

// Стрелки и название
var _can_nav = (array_length(visible_recipes) > 1) && cook_anim == 0 && !cook_done;
draw_sprite_ext(spr_cook_btn_left,  0, nav_l_x, nav_y, 1, 1, 0, c_white, _can_nav ? 1 : 0.5);
draw_sprite_ext(spr_cook_btn_right, 0, nav_r_x, nav_y, 1, 1, 0, c_white, _can_nav ? 1 : 0.5);
draw_sprite(spr_cook_name_plaque, 0, name_x, nav_y);
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_txt_dark);
draw_text(name_x + sprite_get_width(spr_cook_name_plaque) / 2, nav_y + nav_h / 2, _r.name);

// Чек-лист: красный квадратик — ещё не в миске, зелёный — добавлен
for (var i = 0; i < _ing_count; i++) {
    var _ing = _r.ingredients[i];
    var _in_bowl = false;
    for (var j = 0; j < array_length(bowl_items); j++) if (bowl_items[j] == _ing.item) { _in_bowl = true; break; }
    var _cy2 = check_y + i * check_dy;
    draw_sprite(_in_bowl ? spr_cook_check_green : spr_cook_check_red, 0, check_x, _cy2);
    var _info = storage_get_item_info(_ing.item);
    var _nm   = (_info != undefined) ? _info.name : _ing.item;
    draw_set_halign(fa_left);
    draw_set_color(_in_bowl ? make_color_rgb(60, 130, 60) : _txt_dark);
    draw_text(check_tx, _cy2 + 9, _nm + " x" + string(_ing.amount));
}

// Ячейки ингредиентов
for (var i = 0; i < _ing_count; i++) {
    var _cx = cells_x + (i mod cells_cols) * cell_step_x;
    var _cy = cell_area_y + (i div cells_cols) * cell_step_y;
    var _item_id = _r.ingredients[i].item;
    var _needed  = _r.ingredients[i].amount;
    var _have    = inventory_get_amount(_item_id);
    var _in_bowl = false, _in_fly = false;
    for (var j = 0; j < array_length(bowl_items); j++) if (bowl_items[j] == _item_id) { _in_bowl = true; break; }
    for (var j = 0; j < array_length(fly_anims); j++) if (fly_anims[j].item_id == _item_id) { _in_fly = true; break; }
    var _can_add = (!_in_bowl && !_in_fly && _have >= _needed);
    var _oy = (hover_cell == i && _can_add) ? -3 : 0;       // при наведении ячейка чуть приподнимается
    var _a  = (_in_bowl || _in_fly) ? 0.4 : 1;

    draw_sprite_ext(spr_cook_cell, 0, _cx, _cy + _oy, 1, 1, 0, c_white, _a);
    _draw_item(_item_id, _cx + cell_w / 2, _cy + cell_h / 2 + 2 + _oy, _a, _ing_color_map);

    // Сколько есть — справа вверху (красное, если не хватает)
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_halign(fa_right);
    draw_set_valign(fa_top);
    draw_set_color(_have >= _needed ? make_color_rgb(60, 130, 60) : make_color_rgb(190, 50, 40));
    draw_text(_cx + cell_w - 6, _cy + 3 + _oy, string(_have));
    if (_in_bowl) draw_sprite(spr_cook_check_green, 0, _cx + 4, _cy + 4 + _oy);

    // Название под ячейкой
    var _info2 = storage_get_item_info(_item_id);
    draw_set_halign(fa_center);
    draw_set_color(_txt_dark);
    draw_text(_cx + cell_w / 2, _cy + cell_h + 2, (_info2 != undefined) ? _info2.name : _item_id);
}

// --- Кнопка "Готовить" — когда всё в миске ---
var _all_added = (_ing_count > 0);
for (var i = 0; i < _ing_count; i++) {
    var _found = false;
    for (var j = 0; j < array_length(bowl_items); j++) if (bowl_items[j] == _r.ingredients[i].item) { _found = true; break; }
    if (!_found) { _all_added = false; break; }
}
if (_all_added && !cook_done) {
    var _btn_hover = (mx >= btn_x && mx < btn_x + btn_w && my >= btn_y && my < btn_y + btn_h);
    var _cooking   = (cook_anim > 0);
    draw_sprite(spr_cook_btn, 0, btn_x, btn_y);
    if (_btn_hover || _cooking) {
        draw_set_alpha(0.3);
        draw_set_color(c_white);
        draw_roundrect_ext(btn_x + 4, btn_y + 4, btn_x + btn_w - 4, btn_y + btn_h - 4, 4, 4, false);
        draw_set_alpha(1);
    }
    draw_set_font(fnt_dialog_ru_bold);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_txt_dark);
    draw_text(btn_x + btn_w / 2, btn_y + btn_h / 2, _cooking ? "Готовится..." : "Готовить");
}

ds_map_destroy(_ing_color_map);

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
draw_set_alpha(1);
