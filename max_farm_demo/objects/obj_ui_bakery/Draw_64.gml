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

// Стадия: 1 — добавляем ингредиенты, 2 — всё в миске (замес), 3 — в духовке (идёт готовка), 4 — готово
var _all_in = (_ing_count > 0);
for (var i = 0; i < _ing_count; i++) {
    var _f = false;
    for (var j = 0; j < array_length(bowl_items); j++) if (bowl_items[j] == _r.ingredients[i].item) { _f = true; break; }
    if (!_f) { _all_in = false; break; }
}
var _stage = cook_done ? 4 : ((cook_anim > 0) ? 3 : (_all_in ? 2 : 1));
var _spr   = [spr_cook_stage1, spr_cook_stage2, spr_cook_stage3, spr_cook_stage4][_stage - 1];
if (_stage == 4 && string_pos("pie", _r.id) == 0) {            // готовое блюдо: пирог с блёстками — только для пирогов
    var _dish = recipe_dish_image(_r.id);
    _spr = sprite_exists(_dish) ? _dish : spr_cook_stage4;
}
// Лёгкая анимация стадий (целые пиксели)
var _tick = current_time div 16;
var _ax = 0, _ay = 0;
switch (_stage) {
    case 1: _ay = ((_tick div 20) mod 2 == 0) ? 0 : -1; break;            // покачивание
    case 2: _ax = [0, 1, 0, -1][(_tick div 6) mod 4]; break;             // замешивание
    case 3: _ay = ((_tick div 10) mod 2 == 0) ? 0 : -1;                  // духовка «дышит», тёплое свечение
            draw_set_alpha(0.18 + 0.1 * sin(current_time / 150));
            draw_set_color(make_color_rgb(255, 190, 80));
            draw_ellipse(frame_cx - 82, frame_cy - 86, frame_cx + 82, frame_cy + 86, false);
            draw_set_alpha(1); break;
    case 4: _ay = ((_tick div 24) mod 2 == 0) ? 0 : -1; break;
}
var _sw = sprite_get_width(_spr), _sh = sprite_get_height(_spr);
draw_sprite(_spr, 0, round(frame_cx - _sw / 2) + sprite_get_xoffset(_spr) + _ax, round(frame_cy - _sh / 2) + sprite_get_yoffset(_spr) + _ay);

// Точки-индикатор стадий внизу рамки
for (var i = 1; i <= 4; i++) {
    var _dx = frame_cx + (i - 2.5) * 16, _dy = frame_y1 - 14;
    draw_set_color(make_color_rgb(150, 100, 55));
    draw_circle(_dx, _dy, 5, false);
    draw_set_color((i == _stage) ? make_color_rgb(235, 160, 60) : make_color_rgb(250, 238, 215));
    draw_circle(_dx, _dy, 4, false);
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
