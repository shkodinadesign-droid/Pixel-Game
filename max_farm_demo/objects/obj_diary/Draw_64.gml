// ===== DIARY DRAW GUI (дневник v2: подложка spr_diary_bg + элементы spr_ui_* 1:1, текст рисует код) =====

var bs = book_scale; // короткий псевдоним
var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);
var _txt_dark  = make_color_rgb(70, 40, 15);
var _txt_mid   = make_color_rgb(120, 85, 50);
var _txt_hint  = make_color_rgb(160, 130, 100);

draw_set_alpha(1);

// Затемнение фона
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Книга
draw_sprite(spr_diary_bg, 0, book_x, book_y);

// Вкладки: неактивные, затем активная поверх (её низ сливается со страницей)
for (var i = 0; i < 7; i++) {
    if (i != current_tab) draw_sprite(tab_spr_inactive[i], 0, book_x + ui_tabs[i][0], book_y + ui_tabs[i][1]);
}
draw_sprite(tab_spr_active[current_tab], 0, book_x + ui_tabs[current_tab][0], book_y + ui_tabs[current_tab][1]);

// Кнопка закрытия
var _cl_x = book_x + ui_close[0], _cl_y = book_y + ui_close[1];
var _cl_hover = (_mx >= _cl_x && _mx < _cl_x + 30 && _my >= _cl_y && _my < _cl_y + 30);
draw_sprite(_cl_hover ? spr_ui_close_hover : spr_ui_close_normal, 0, _cl_x, _cl_y);

// Название раздела — по центру таблички
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(_txt_dark);
draw_text(book_x + ui_title[0], book_y + ui_title[1], tab_names[current_tab]);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Области подложки в GUI координатах
var content_x = book_x + ui_list[0];
var content_y = book_y + ui_list[1];
var _sh_x0 = book_x + ui_sheet[0], _sh_y0 = book_y + ui_sheet[1];
var _sh_x1 = book_x + ui_sheet[2], _sh_y1 = book_y + ui_sheet[3];
var _sh_cx = (_sh_x0 + _sh_x1) / 2, _sh_cy = (_sh_y0 + _sh_y1) / 2;
var _sh_tx = _sh_x0 + 14;          // текст на белом листе: отступ слева
var _sh_ty = _sh_y0 + 28;          // и сверху — ниже закладки
var _sh_tw = _sh_x1 - _sh_x0 - 28;
var _lo_x0 = book_x + ui_low[0], _lo_y0 = book_y + ui_low[1];
var _lo_x1 = book_x + ui_low[2], _lo_y1 = book_y + ui_low[3];

switch (current_tab) {
    case 1: // Инвентарь

        // [спрайт (-1 = нет), цвет-заглушка, количество, название, описание]
        var inv_items = [
            [spr_carrot_icon, make_color_rgb(255,130,30),
             inventory_get_amount(ITEM_CARROT), "Морковь",
             "Сочная морковка с грядки.\n\nВремя роста: 3 дня.\nХранение в ящике для овощей.\n\nИспользуется в рецептах:\nМорковный пирог."],
            [spr_seed_carrot_icon, make_color_rgb(160,200,80),
             inventory_get_amount(ITEM_SEED), "Семена моркови",
             "Семена моркови.\n\nВремя роста: 3 дня.\nПосадить на вспаханную грядку."],
            [spr_potato_seed_icon, make_color_rgb(220,170,50),
             inventory_get_amount(ITEM_POTATO_SEED), "Семена картофеля",
             "Семена картофеля.\n\nВремя роста: 4 дня.\nПосадить на вскопанную грядку."],
            [spr_strawberry_seed_icon, make_color_rgb(255,100,120),
             inventory_get_amount(ITEM_STRAWBERRY_SEED), "Семена клубники",
             "Семена клубники.\n\nВремя роста: 3 дня.\nПосадить на вскопанную грядку."],
            [spr_potato_icon, make_color_rgb(220,170,50),
             inventory_get_amount("potato"), "Картофель",
             "Картошка из сарая.\n\nВремя роста: 4 дня.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_milk_icon, make_color_rgb(220,235,255),
             inventory_get_amount("milk"), "Молоко",
             "Свежее молоко.\n\nИсточник: корова.\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_egg_icon, make_color_rgb(255,220,80),
             inventory_get_amount("egg"), "Яйцо",
             "Куриное яйцо.\n\nИсточник: курица.\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_flour_icon, make_color_rgb(235,225,205),
             inventory_get_amount("flour"), "Мука",
             "Пшеничная мука.\n\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_yeast_icon, make_color_rgb(160,110,55),
             inventory_get_amount("yeast"), "Дрожжи",
             "Дрожжи для выпечки.\n\nХранить в холодильнике.\n\nИспользуется в рецептах:\nКартофельный пирог."],
            [spr_potatoes_pie, make_color_rgb(190,120,55),
             inventory_get_amount("potato_pie"), "Картоф. пирог",
             "Любимый пирог Джастина.\n\nПриготовить в пекарне:\nКартофель + Молоко + Яйцо\nМука + Дрожжи.\n\nМожно продать или\nотдать Джастину."],
        ];

        // Добавляем товары из player_inventory, которых нет в базовом списке
        var _base_ids = ["carrot","carrot_seed","potato_seed","strawberry_seed",
                         "potato","milk","egg","flour","yeast","potato_pie"];
        if (variable_global_exists("player_inventory") && variable_global_exists("item_database")) {
            var _pk = ds_map_find_first(global.player_inventory);
            repeat(ds_map_size(global.player_inventory)) {
                var _in_base = false;
                for (var _bi = 0; _bi < array_length(_base_ids); _bi++) {
                    if (_pk == _base_ids[_bi]) { _in_base = true; break; }
                }
                if (!_in_base) {
                    var _pq = ds_map_find_value(global.player_inventory, _pk);
                    if (_pq > 0) {
                        var _pd = ds_map_find_value(global.item_database, _pk);
                        if (_pd != undefined) {
                            var _pspr = variable_struct_exists(_pd, "icon")  ? _pd.icon  : -1;
                            var _pcol = variable_struct_exists(_pd, "col")   ? _pd.col   : make_color_rgb(180,160,120);
                            var _pnm  = variable_struct_exists(_pd, "name")  ? _pd.name  : string(_pk);
                            array_push(inv_items, [_pspr, _pcol, _pq, _pnm, ""]);
                        }
                    }
                }
                _pk = ds_map_find_next(global.player_inventory, _pk);
            }
        }

        var inv_count = array_length(inv_items);

        // --- Сетка 5x4 ---
        var slot_size = ui_inv[2];
        var slot_step = ui_inv[2] + ui_inv[3];
        var grid_x    = book_x + ui_inv[0];
        var grid_y    = book_y + ui_inv[1];
        for (var _row = 0; _row < 4; _row++) {
            for (var _col = 0; _col < 5; _col++) {
                var _idx = _row * 5 + _col;
                var _sx  = grid_x + _col * slot_step;
                var _sy  = grid_y + _row * slot_step;
                var _has = (_idx < inv_count) && (inv_items[_idx][2] > 0);
                var _hov = (_mx >= _sx && _mx < _sx + slot_size && _my >= _sy && _my < _sy + slot_size);
                var _spr = spr_ui_inventory_slot_empty;
                if (_has) _spr = spr_ui_inventory_slot_item;
                if (_has && _hov) _spr = spr_ui_inventory_slot_hover;
                if (_idx == selected_item && _has) _spr = spr_ui_inventory_slot_selected;
                draw_sprite(_spr, 0, _sx, _sy);

                if (_has) {
                    var _ispr = inv_items[_idx][0];
                    if (sprite_exists(_ispr)) {
                        var _imax = max(sprite_get_width(_ispr), sprite_get_height(_ispr));
                        var _sc = (_imax <= 40) ? 1 : 36 / _imax;   // иконки 32x32 — 1:1
                        draw_sprite_ext(_ispr, 0, _sx + (slot_size - sprite_get_width(_ispr) * _sc) / 2 + sprite_get_xoffset(_ispr) * _sc,
                                        _sy + (slot_size - sprite_get_height(_ispr) * _sc) / 2 + sprite_get_yoffset(_ispr) * _sc,
                                        _sc, _sc, 0, c_white, 1);
                    } else {
                        draw_set_color(inv_items[_idx][1]);
                        draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, 14, false);
                    }
                    // бейдж количества
                    draw_sprite(spr_ui_count_badge, 0, _sx + slot_size - 12, _sy + slot_size - 12);
                    draw_set_font(fnt_ui);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_middle);
                    draw_set_color(c_white);
                    draw_text(_sx + slot_size - 4, _sy + slot_size - 4, string(inv_items[_idx][2]));
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
            }
        }

        // --- Правая страница: большая иконка, название, описание; количество под листом ---
        if (selected_item >= 0 && selected_item < inv_count && inv_items[selected_item][2] > 0) {
            var _pv_x = _sh_x0 + 12, _pv_y = _sh_y0 + 30;
            draw_sprite(spr_ui_inventory_item_preview_96x96, 0, _pv_x, _pv_y);
            var _bspr = inv_items[selected_item][0];
            if (sprite_exists(_bspr)) {
                var _bsc = max(1, floor(72 / max(sprite_get_width(_bspr), sprite_get_height(_bspr))));
                draw_sprite_ext(_bspr, 0, _pv_x + (96 - sprite_get_width(_bspr) * _bsc) / 2 + sprite_get_xoffset(_bspr) * _bsc,
                                _pv_y + (96 - sprite_get_height(_bspr) * _bsc) / 2 + sprite_get_yoffset(_bspr) * _bsc,
                                _bsc, _bsc, 0, c_white, 1);
            } else {
                draw_set_color(inv_items[selected_item][1]);
                draw_circle(_pv_x + 48, _pv_y + 48, 30, false);
            }
            var _ix = _pv_x + 108, _iw = _sh_x1 - 12 - _ix;
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_color(_txt_dark);
            draw_text_ext(_ix, _pv_y, inv_items[selected_item][3], -1, _iw);
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(_ix, _pv_y + 26, inv_items[selected_item][4], 16, _iw);

            var _ql_x = round((_lo_x0 + _lo_x1) / 2 - 100), _ql_y = _lo_y0 + 4;
            draw_sprite(spr_ui_quantity_label_200x28, 0, _ql_x, _ql_y);
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_dark);
            draw_text(_ql_x + 100, _ql_y + 14, "Количество: " + string(inv_items[selected_item][2]));
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_hint);
            draw_text(_sh_cx, _sh_cy + 10, "Выбери предмет\nиз инвентаря");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;

    case 0: // Задания
        var _pages = diary_quest_build_pages(content_x, content_y, ui_list[3]);
        quest_page = clamp(quest_page, 0, array_length(_pages) - 1);
        var _rows  = _pages[quest_page];
        for (var _qi = 0; _qi < array_length(_rows); _qi++) {
            var _row = _rows[_qi];
            if (_row.type == "header") {
                draw_sprite(spr_ui_quest_group_heading, 0, _row.x, _row.y);
                draw_set_font(fnt_ui);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(_txt_mid);
                draw_text(_row.x + 160, _row.y + 10, _row.text);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
                continue;
            }
            var _q      = _row.q;
            var _is_sel = (_q.id == selected_quest);
            var _hov    = (_mx >= _row.x && _mx < _row.x + 320 && _my >= _row.y && _my < _row.y + _row.h);
            draw_sprite(_is_sel ? spr_ui_quest_card_selected : (_hov ? spr_ui_quest_card_hover : spr_ui_quest_card_normal), 0, _row.x, _row.y);
            // тип: основное — звезда, дополнительное — листик, выполненное — галочка
            var _type_spr = _q.done ? spr_ui_quest_type_check : ((_q.category == "main") ? spr_ui_quest_type_star : spr_ui_quest_type_leaf);
            draw_sprite(_type_spr, 0, _row.x + 12, _row.y + 12);
            // статус справа: выполнено / прочитано / новое
            var _st_spr = _q.done ? spr_ui_quest_status_done : (diary_quest_is_read(_q.id) ? spr_ui_quest_status_read : spr_ui_quest_status_new);
            draw_sprite(_st_spr, 0, _row.x + 292, _row.y + 20);
            // название (зачёркнуто, если выполнено), до 2 строк
            draw_set_font(fnt_ui);
            draw_set_valign(fa_middle);
            draw_set_color(_q.done ? make_color_rgb(140, 115, 90) : make_color_rgb(55, 35, 15));
            var _tw = 222;
            draw_text_ext(_row.x + 58, _row.y + 28, _q.text, 16, _tw);
            if (_q.done && string_width(_q.text) <= _tw) {
                draw_line(_row.x + 58, _row.y + 28, _row.x + 58 + string_width(_q.text), _row.y + 28);
            }
            draw_set_valign(fa_top);
        }
        // стрелки листания — только если страниц больше одной
        if (array_length(_pages) > 1) {
            draw_sprite((quest_page > 0) ? spr_ui_arrow_left_normal : spr_ui_arrow_left_disabled, 0, book_x + ui_arrows[0], book_y + ui_arrows[2]);
            draw_sprite((quest_page < array_length(_pages) - 1) ? spr_ui_arrow_right_normal : spr_ui_arrow_right_disabled, 0, book_x + ui_arrows[1], book_y + ui_arrows[2]);
        }

        // --- Правая страница: описание выбранного задания на белом листе ---
        var _sel_q = undefined;
        if (selected_quest != "") {
            var _full_list = diary_get_quest_list();
            for (var _li = 0; _li < array_length(_full_list); _li++) {
                if (_full_list[_li].id == selected_quest) { _sel_q = _full_list[_li]; break; }
            }
        }
        if (_sel_q != undefined) {
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_color(_txt_dark);
            draw_text_ext(_sh_tx, _sh_ty, _sel_q.text, -1, _sh_tw);
            var _ty2 = _sh_ty + string_height_ext(_sel_q.text, -1, _sh_tw) + 4;
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_sh_tx, _ty2, _sh_tx + _sh_tw, _ty2);
            draw_set_font(fnt_ui);
            draw_set_color(c_black);
            draw_text_ext(_sh_tx, _ty2 + 8, _sel_q.desc, 16, _sh_tw);
        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_hint);
            draw_text(_sh_cx, _sh_cy + 10, "Выбери задание\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;

    case 3: // Растения
        var _plants = diary_get_plant_list();
        for (var _pi = 0; _pi < array_length(_plants); _pi++) {
            var _pl = _plants[_pi];
            var _px = content_x, _py = content_y + _pi * 62;
            draw_sprite((_pi == selected_plant) ? spr_ui_plant_card_selected : spr_ui_plant_card_normal, 0, _px, _py);
            if (sprite_exists(_pl.icon)) {
                draw_sprite_ext(_pl.icon, 0, _px + 12 + sprite_get_xoffset(_pl.icon), _py + 12 + sprite_get_yoffset(_pl.icon), 1, 1, 0, c_white, 1);
            }
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_color(_txt_dark);
            draw_text(_px + 58, _py + 8, _pl.name);
            draw_sprite(spr_ui_plant_icon_clock, 0, _px + 58, _py + 32);
            draw_set_font(fnt_ui);
            draw_set_color(_txt_mid);
            draw_text(_px + 78, _py + 32, _pl.grow_text);
        }
        if (selected_plant >= 0 && selected_plant < array_length(_plants)) {
            var _sp = _plants[selected_plant];
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_center);
            draw_set_color(_txt_dark);
            draw_text(_sh_cx, _sh_ty, _sp.name + ": стадии роста");
            draw_set_halign(fa_left);
            // полоска стадий: 4 клетки 44x44 (левый верх клеток внутри спрайта 260x64)
            var _gs_x = round(_sh_cx - 130), _gs_y = _sh_ty + 34;
            draw_sprite(spr_ui_growth_stages_empty_260x64, 0, _gs_x, _gs_y);
            var _cell_x = [2, 73, 144, 215];
            for (var _si = 0; _si < min(4, array_length(_sp.stages)); _si++) {
                var _ss = _sp.stages[_si];
                if (!sprite_exists(_ss)) continue;
                var _ssc = min(1, 36 / max(sprite_get_width(_ss), sprite_get_height(_ss)));
                draw_sprite_ext(_ss, 0, _gs_x + _cell_x[_si] + (44 - sprite_get_width(_ss) * _ssc) / 2 + sprite_get_xoffset(_ss) * _ssc,
                                _gs_y + 10 + (44 - sprite_get_height(_ss) * _ssc) / 2 + sprite_get_yoffset(_ss) * _ssc,
                                _ssc, _ssc, 0, c_white, 1);
            }
            // под листом: полив и срок
            draw_sprite(spr_ui_plant_icon_drop, 0, _lo_x0 + 10, _lo_y0 + 10);
            draw_sprite(spr_ui_plant_icon_clock, 0, _lo_x0 + 10, _lo_y0 + 40);
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text(_lo_x0 + 34, _lo_y0 + 10, "Поливать каждый день");
            draw_text(_lo_x0 + 34, _lo_y0 + 40, _sp.grow_text);
        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_hint);
            draw_text(_sh_cx, _sh_cy + 10, "Выбери растение\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;

    case 2: // Рецепты
        var _all_recipes = diary_get_recipe_list();
        var _categories  = diary_get_recipe_categories();
        var _cat_icons   = [spr_ui_recipe_icon_bread, spr_ui_recipe_icon_plate, spr_ui_recipe_icon_cup];

        // --- Кнопки-категории ---
        for (var _ci = 0; _ci < array_length(_categories); _ci++) {
            var _bx = book_x + ui_rcat[0] + _ci * (ui_rcat[2] + ui_rcat[3]);
            var _by = book_y + ui_rcat[1];
            var _act = (_categories[_ci].id == recipe_category);
            draw_sprite(_act ? spr_ui_recipe_category_active : spr_ui_recipe_category_inactive, 0, _bx, _by);
            if (_ci < 3) draw_sprite(_cat_icons[_ci], 0, _bx + 8, _by + 5);
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_act ? make_color_rgb(60, 35, 10) : _txt_mid);
            draw_text(_bx + 56, _by + 13, _categories[_ci].name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Сетка 4x4: открытые рецепты, затем закрытые (замок), остальное пусто ---
        var _cat_recipes = diary_recipes_in_category(_all_recipes, recipe_category);
        var _step = ui_rgrid[2] + ui_rgrid[3];
        for (var _gi = 0; _gi < 16; _gi++) {
            var _sx = book_x + ui_rgrid[0] + (_gi mod 4) * _step;
            var _sy = book_y + ui_rgrid[1] + (_gi div 4) * _step;
            if (_gi >= array_length(_cat_recipes)) { draw_sprite(spr_ui_recipe_slot_empty, 0, _sx, _sy); continue; }
            var _rc = _cat_recipes[_gi];
            if (!_rc.unlocked) { draw_sprite(spr_ui_recipe_slot_locked, 0, _sx, _sy); continue; }
            draw_sprite((_rc.id == selected_recipe) ? spr_ui_recipe_slot_selected : spr_ui_recipe_slot_normal, 0, _sx, _sy);
            if (sprite_exists(_rc.icon)) {
                var _isc = min(1, 36 / max(sprite_get_width(_rc.icon), sprite_get_height(_rc.icon)));
                draw_sprite_ext(_rc.icon, 0, _sx + (46 - sprite_get_width(_rc.icon) * _isc) / 2 + sprite_get_xoffset(_rc.icon) * _isc,
                                _sy + (46 - sprite_get_height(_rc.icon) * _isc) / 2 + sprite_get_yoffset(_rc.icon) * _isc,
                                _isc, _isc, 0, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(200, 170, 120));
                draw_circle(_sx + 23, _sy + 23, 13, false);
            }
        }

        // --- Правая страница: картинка блюда в рамке + ингредиенты под листом ---
        var _sel_r = undefined;
        if (selected_recipe != "") {
            for (var _li = 0; _li < array_length(_all_recipes); _li++) {
                if (_all_recipes[_li].id == selected_recipe) { _sel_r = _all_recipes[_li]; break; }
            }
        }
        if (_sel_r != undefined) {
            var _df_x = round(_sh_cx - 100), _df_y = _sh_y0 + 26;
            draw_sprite(spr_ui_recipe_large_dish_200x120, 0, _df_x, _df_y);
            if (sprite_exists(_sel_r.image)) {
                var _dsc = min(1, min(184 / sprite_get_width(_sel_r.image), 104 / sprite_get_height(_sel_r.image)));
                draw_sprite_ext(_sel_r.image, 0, _df_x + (200 - sprite_get_width(_sel_r.image) * _dsc) / 2 + sprite_get_xoffset(_sel_r.image) * _dsc,
                                _df_y + (120 - sprite_get_height(_sel_r.image) * _dsc) / 2 + sprite_get_yoffset(_sel_r.image) * _dsc,
                                _dsc, _dsc, 0, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(200, 170, 120));
                draw_circle(_df_x + 100, _df_y + 60, 34, false);
            }
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_dark);
            draw_text(_sh_cx, _df_y + 120 + 18, _sel_r.name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            for (var _ii = 0; _ii < array_length(_sel_r.ingredients) && _ii < 6; _ii++) {
                var _ing = _sel_r.ingredients[_ii];
                var _amt = variable_struct_exists(_ing, "amount") ? _ing.amount : 1;
                var _have = variable_struct_exists(_ing, "item") ? (inventory_get_amount(_ing.item) >= _amt) : false;
                var _rx = _lo_x0 + (_ii div 3) * 162, _ry = _lo_y0 + 2 + (_ii mod 3) * 30;
                draw_sprite(_have ? spr_ui_recipe_ingredient_available : spr_ui_recipe_ingredient_missing, 0, _rx, _ry);
                if (sprite_exists(_ing.icon)) {
                    var _gsc = min(1, 18 / max(sprite_get_width(_ing.icon), sprite_get_height(_ing.icon)));
                    draw_sprite_ext(_ing.icon, 0, _rx + 4 + sprite_get_xoffset(_ing.icon) * _gsc, _ry + 3 + sprite_get_yoffset(_ing.icon) * _gsc, _gsc, _gsc, 0, c_white, 1);
                } else {
                    draw_set_color(_ing.color);
                    draw_circle(_rx + 13, _ry + 12, 7, false);
                }
                draw_set_font(fnt_ui);
                draw_set_valign(fa_middle);
                draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_rx + 26, _ry + 12, _ing.name);
                draw_set_halign(fa_right);
                draw_text(_rx + 126, _ry + 12, string(_amt));
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_txt_hint);
            draw_text(_sh_cx, _sh_cy + 10, "Выбери рецепт\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;

    case 5: // Дружба
        var _fr_list = diary_get_friend_list();

        // --- Список персонажей (левая страница): иконка-портрет + имя + короткое описание ---
        var _fr_icon_sz = 36;
        var _fr_gap_x   = 10;
        var _fr_name_h  = 24;
        var _fr_row_gap = 12;
        var _fr_row_h   = max(_fr_icon_sz, _fr_name_h + 16) + _fr_row_gap;
        var _fr_list_w  = ui_list[2];

        for (var _fi = 0; _fi < array_length(_fr_list); _fi++) {
            var _f     = _fr_list[_fi];
            var _row_y = content_y + _fi * _fr_row_h;
            var _is_sel = (_f.id == selected_friend);

            if (_is_sel) {
                draw_set_alpha(0.18);
                draw_set_color(c_black);
                draw_rectangle(content_x - round(3 * bs), _row_y - round(1 * bs),
                                content_x + _fr_list_w, _row_y + _fr_row_h - round(3 * bs), false);
                draw_set_alpha(1);
            }

            // Иконка-портрет
            if (sprite_exists(_f.portrait)) {
                draw_sprite_stretched_ext(_f.portrait, 0, content_x, _row_y, _fr_icon_sz, _fr_icon_sz, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(255, 80, 120));
                draw_circle(content_x + _fr_icon_sz / 2, _row_y + _fr_icon_sz / 2, _fr_icon_sz / 2, false);
            }

            // Имя (заголовок строки)
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(content_x + _fr_icon_sz + _fr_gap_x, _row_y, _f.name);

            // Короткое описание
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(120, 95, 65));
            draw_text(content_x + _fr_icon_sz + _fr_gap_x, _row_y + _fr_name_h, _f.short_desc);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Правая страница: подробная информация о выбранном персонаже (белый листочек на арте) ---
        var _fd_x  = _sh_tx;
        var _fd_y  = _sh_y0 + 12;
        var _fd_w  = _sh_tw;
        var _fd_portrait_sz = 48;

        var _sel_f = undefined;
        for (var _li = 0; _li < array_length(_fr_list); _li++) {
            if (_fr_list[_li].id == selected_friend) { _sel_f = _fr_list[_li]; break; }
        }

        if (_sel_f != undefined) {
            // Большой портрет
            if (sprite_exists(_sel_f.portrait)) {
                draw_sprite_stretched_ext(_sel_f.portrait, 0, _fd_x, _fd_y, _fd_portrait_sz, _fd_portrait_sz, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(255, 80, 120));
                draw_circle(_fd_x + _fd_portrait_sz / 2, _fd_y + _fd_portrait_sz / 2, _fd_portrait_sz / 2, false);
            }

            // Имя — заголовок справа от портрета, по центру его высоты
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_left);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(_fd_x + _fd_portrait_sz + 14, _fd_y + _fd_portrait_sz / 2, _sel_f.name);

            // Разделитель
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_fd_x, _fd_y + _fd_portrait_sz + 10, _fd_x + _fd_w, _fd_y + _fd_portrait_sz + 10);

            // Описание — абзацы с небольшим отступом; если не влезает в белый лист, текст уменьшается
            draw_set_font(fnt_ui);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(c_black);
            var _desc_y     = _fd_y + _fd_portrait_sz + 20;
            var _desc_max_h = (_sh_y1 - 8) - _desc_y; // нижний край белого листа
            var _line_sep   = 20;
            var _para_gap   = 8;
            var _paras      = string_split(_sel_f.desc, "\n\n");
            var _desc_s     = 1;
            repeat (10) {
                var _tot_h = 0;
                for (var _pi = 0; _pi < array_length(_paras); _pi++) {
                    _tot_h += string_height_ext(_paras[_pi], _line_sep, _fd_w / _desc_s) * _desc_s;
                    if (_pi > 0) _tot_h += _para_gap * _desc_s;
                }
                if (_tot_h <= _desc_max_h) break;
                _desc_s -= 0.05;
            }
            var _py = _desc_y;
            for (var _pi = 0; _pi < array_length(_paras); _pi++) {
                draw_text_ext_transformed(_fd_x, _py, _paras[_pi], _line_sep, _fd_w / _desc_s, _desc_s, _desc_s, 0);
                _py += (string_height_ext(_paras[_pi], _line_sep, _fd_w / _desc_s) + _para_gap) * _desc_s;
            }
        } else {
            var _fd_cx = _sh_cx;
            var _fd_cy = _sh_cy + 12;
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(_fd_cx, _fd_cy, "Выбери персонажа\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;
    case 4: // Приключения
        draw_set_font(fnt_ui);
        draw_text(content_x, content_y, "Приключения скоро!");
        break;
    case 6: // Деньги
        // Иконка монеты
        draw_set_color(make_color_rgb(255, 210, 50));
        draw_circle(content_x + 12, content_y + 12, 11, false);
        draw_set_color(make_color_rgb(200, 155, 20));
        draw_circle(content_x + 12, content_y + 12, 11, true);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(make_color_rgb(140, 90, 10));
        draw_text(content_x + 12, content_y + 12, "C");
        // Сумма
        draw_set_font(fnt_ui);
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 30, content_y + 4, "C - " + string(global.coins));
        break;
}

// Сброс
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_font(-1);
draw_set_color(c_white);
