// ===== DIARY DRAW GUI =====

var bs = book_scale; // короткий псевдоним

draw_set_alpha(1);

// Затемнение фона
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Фон книги — подложка 1:1 (вкладки, табличка заголовка и белый лист нарисованы в спрайте)
draw_sprite(spr_diary_bg, 0, book_x, book_y);

// Подсветка активной вкладки поверх арта
for (var i = 0; i < 7; i++) {
    if (i != current_tab) continue;
    draw_set_alpha(0.35);
    draw_set_color(make_color_rgb(255, 250, 230));
    draw_roundrect_ext(book_x + ui_tabs[i][0] + 3, book_y + ui_tabs[i][1] + 3,
                       book_x + ui_tabs[i][2] - 3, book_y + ui_tabs[i][3] - 3, 6, 6, false);
    draw_set_alpha(1);
}

// Кнопка закрытия (зелёный крестик) — верхний правый угол книги
var _close_cx = book_x + ui_close[0];
var _close_cy = book_y + ui_close[1];
var _close_r  = ui_close[2];
draw_set_color(make_color_rgb(70, 160, 90));
draw_circle(_close_cx, _close_cy, _close_r, false);
draw_set_color(make_color_rgb(40, 110, 60));
draw_circle(_close_cx, _close_cy, _close_r, true);
draw_set_color(c_white);
var _cross_r = _close_r * 0.45;
draw_line_width(_close_cx - _cross_r, _close_cy - _cross_r, _close_cx + _cross_r, _close_cy + _cross_r, round(2 * bs));
draw_line_width(_close_cx - _cross_r, _close_cy + _cross_r, _close_cx + _cross_r, _close_cy - _cross_r, round(2 * bs));

// Название раздела — по центру таблички на левой странице
draw_set_font(fnt_dialog_ru_bold);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(70, 40, 15));
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
var _sh_ty = _sh_y0 + 30;          // и сверху — ниже закладки
var _sh_tw = _sh_x1 - _sh_x0 - 28;

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

        // --- Константы сетки (масштабированные) ---
        var slot_size = ui_inv[2];
        var slot_gap  = ui_inv[3];
        var grid_cols = 5;
        var grid_rows = 4;
        var grid_x    = book_x + ui_inv[0];
        var grid_y    = book_y + ui_inv[1];
        var _slot_corner = round(4 * bs);

        // --- Сетка слотов ---
        for (var _row = 0; _row < grid_rows; _row++) {
            for (var _col = 0; _col < grid_cols; _col++) {
                var _idx = _row * grid_cols + _col;
                var _sx  = grid_x + _col * (slot_size + slot_gap);
                var _sy  = grid_y + _row * (slot_size + slot_gap);

                var _is_sel = (_idx == selected_item);
                // цвета ячеек — как у карточек в арте книги; выбранная — светлая, как белый лист
                draw_set_color(_is_sel ? make_color_rgb(250, 241, 226) : make_color_rgb(234, 198, 152));
                draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, _slot_corner, _slot_corner, false);
                draw_set_color(_is_sel ? make_color_rgb(172, 104, 55) : make_color_rgb(203, 159, 108));
                draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, _slot_corner, _slot_corner, true);

                if (_idx < inv_count) {
                    var _ispr = inv_items[_idx][0];
                    var _icol = inv_items[_idx][1];
                    var _iqty = inv_items[_idx][2];

                    if (_iqty > 0) {
                        if (sprite_exists(_ispr)) {
                            var _iw  = sprite_get_width(_ispr);
                            var _ih  = sprite_get_height(_ispr);
                            var _pad = round(6 * bs);
                            var _sc  = min((slot_size - _pad) / _iw,
                                           (slot_size - _pad) / _ih);
                            var _dw  = _iw * _sc;
                            var _dh  = _ih * _sc;
                            var _ccx = _sx + slot_size / 2;
                            var _ccy = _sy + slot_size / 2;
                            draw_sprite_stretched_ext(_ispr, 0,
                                _ccx - _dw / 2, _ccy - _dh / 2, _dw, _dh,
                                c_white, 1);
                        } else {
                            // Цветной круг-заглушка
                            draw_set_color(_icol);
                            draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, round(13 * bs), false);
                            draw_set_color(make_color_rgb(0,0,0));
                            draw_set_alpha(0.15);
                            draw_circle(_sx + slot_size / 2, _sy + slot_size / 2, round(13 * bs), true);
                            draw_set_alpha(1);
                        }

                        // Кружок с цифрой — на правом нижнем углу
                        var _br = round(6 * bs);
                        var _bx = _sx + slot_size;
                        var _by = _sy + slot_size;
                        draw_set_color(make_color_rgb(70, 40, 10));
                        draw_circle(_bx, _by, _br, false);
                        draw_set_font(fnt_ui);
                        draw_set_halign(fa_center);
                        draw_set_valign(fa_middle);
                        draw_set_color(c_white);
                        draw_text(_bx, _by, string(_iqty));
                        draw_set_halign(fa_left);
                        draw_set_valign(fa_top);
                    }
                }
            }
        }

        // --- Правая страница — карточка предмета на белом листе ---
        if (selected_item >= 0 && selected_item < inv_count
            && inv_items[selected_item][2] > 0) {

            var _iname = inv_items[selected_item][3];
            var _idesc = inv_items[selected_item][4];
            var _iqty2 = inv_items[selected_item][2];

            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(_sh_tx, _sh_ty, _iname);

            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_sh_tx, _sh_ty + 24, _sh_tx + _sh_tw, _sh_ty + 24);

            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(_sh_tx, _sh_ty + 32, _idesc, -1, _sh_tw);

            // Количество — под белым листом
            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(139, 90, 43));
            draw_text(book_x + (ui_low[0] + ui_low[2]) / 2, book_y + (ui_low[1] + ui_low[3]) / 2,
                      "Количество: " + string(_iqty2));
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(_sh_cx, _sh_cy + 12, "Выбери предмет\nиз инвентаря");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        break;

    case 0: // Задания
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Заголовок вкладки рисуется общим кодом выше (единый стиль для всех вкладок)
        var _q_list_w = ui_list[2];
        var _q_rows_y = content_y;
        var _q_rows   = diary_quest_build_rows(content_x, _q_rows_y, bs);
        var _icon_r   = round(6 * bs);

        for (var _qi = 0; _qi < array_length(_q_rows); _qi++) {
            var _row = _q_rows[_qi];

            if (_row.type == "header") {
                draw_set_font(fnt_ui);
                draw_set_color(make_color_rgb(120, 80, 35));
                draw_text(content_x, _row.y, _row.text);
                continue;
            }

            var _q       = _row.q;
            var _is_sel  = (_q.id == selected_quest);
            var _is_read = diary_quest_is_read(_q.id);

            // Подсветка выбранной (активной) строки
            if (_is_sel) {
                draw_set_alpha(0.18);
                draw_set_color(c_black);
                draw_rectangle(content_x - round(3 * bs), _row.y - round(1 * bs),
                                content_x + _q_list_w, _row.y + _row.h - round(3 * bs), false);
                draw_set_alpha(1);
            }

            // Текст задания (зачёркнут, если выполнено)
            draw_set_font(fnt_ui);
            draw_set_color(_q.done ? make_color_rgb(140, 115, 90) : make_color_rgb(55, 35, 15));
            draw_text(content_x, _row.y, _q.text);
            if (_q.done) {
                var _sy2 = _row.y + string_height(_q.text) / 2;
                draw_line(content_x, _sy2, content_x + string_width(_q.text), _sy2);
            }

            // Статус-иконка справа: зелёный чек (выполнено) / серый чек (прочитано) / красный ! (новое)
            var _icx = content_x + _q_list_w - _icon_r;
            var _icy = _row.y + _row.h / 2 - round(4 * bs);

            if (_q.done) {
                draw_set_color(make_color_rgb(70, 150, 70));
                draw_roundrect_ext(_icx - _icon_r, _icy - _icon_r, _icx + _icon_r, _icy + _icon_r, 2, 2, false);
                draw_set_font(fnt_ui);
                draw_set_halign(fa_center);
                draw_set_valign(fa_middle);
                draw_set_color(c_white);
                draw_text(_icx, _icy, "v");
            } else if (_is_read) {
                draw_set_color(make_color_rgb(160, 150, 145));
                draw_roundrect_ext(_icx - _icon_r, _icy - _icon_r, _icx + _icon_r, _icy + _icon_r, 2, 2, true);
            } else {
                draw_set_color(make_color_rgb(200, 60, 50));
                draw_circle(_icx, _icy, _icon_r, false);
                // "!" рисуем примитивами, а не шрифтом — так он идеально по центру кружка
                draw_set_color(c_white);
                var _bar_hw  = max(1, round(1 * bs));
                var _bar_top = _icy - _icon_r * 0.55;
                var _bar_bot = _icy + _icon_r * 0.05;
                draw_rectangle(_icx - _bar_hw, _bar_top, _icx + _bar_hw, _bar_bot, false);
                draw_circle(_icx, _icy + _icon_r * 0.55, max(1, round(1.2 * bs)), false);
            }
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Правая страница: подробное описание выбранного задания (внутри белого листочка на арте) ---
        var _qd_x  = _sh_tx;
        var _qd_y  = _sh_ty;
        var _qd_w  = _sh_tw;

        var _sel_q = undefined;
        if (selected_quest != "") {
            var _full_list = diary_get_quest_list();
            for (var _li = 0; _li < array_length(_full_list); _li++) {
                if (_full_list[_li].id == selected_quest) { _sel_q = _full_list[_li]; break; }
            }
        }

        if (_sel_q != undefined) {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text_ext(_qd_x, _qd_y, _sel_q.text, -1, _qd_w);

            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_qd_x, _qd_y + 22, _qd_x + _qd_w, _qd_y + 22);

            draw_set_font(fnt_ui);
            draw_set_color(c_black);
            draw_text_ext(_qd_x, _qd_y + 32, _sel_q.desc, round(18 * bs), _qd_w);
        } else {
            var _qd_cx = _sh_cx;
            var _qd_cy = _sh_cy + 12;
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(_qd_cx, _qd_cy, "Выбери задание\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;
    case 3: // Растения
        draw_set_font(fnt_ui);
        draw_set_color(make_color_rgb(80, 50, 20));

        // Морковь
        draw_sprite_ext(spr_carrot_icon, 0, content_x, content_y, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, content_y, "Морковь");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, content_y + 18, "Время роста: 3 дня");

        // Картофель
        var _py = content_y + round(52 * bs);
        draw_sprite_ext(spr_potato_icon, 0, content_x, _py, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, _py, "Картофель");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, _py + 18, "Время роста: 2 дня");

        // Клубника
        var _sy = _py + round(52 * bs);
        draw_sprite_ext(spr_strawberry_seed_icon, 0, content_x, _sy, 0.7, 0.7, 0, c_white, 1);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x + 26, _sy, "Клубника");
        draw_set_color(make_color_rgb(130, 100, 60));
        draw_text(content_x + 26, _sy + 18, "Время роста: 2 дня");

        draw_set_color(c_white);
        break;
    case 2: // Рецепты
        var _all_recipes = diary_get_recipe_list();
        var _categories  = diary_get_recipe_categories();
        var _cell_fill   = make_color_rgb(234, 198, 152);   // цвета ячеек — как у карточек в арте книги
        var _cell_line   = make_color_rgb(203, 159, 108);

        // --- Кнопки-категории (левая страница, под табличкой) ---
        var _cat_x0 = book_x + ui_rcat[0];
        var _cat_x1 = book_x + ui_rcat[2];
        var _cat_y0 = book_y + ui_rcat[1];
        var _cat_y1 = book_y + ui_rcat[3];
        var _cat_w  = (_cat_x1 - _cat_x0) / array_length(_categories);
        var _cat_gap = 6;
        var _cat_corner = 6;
        for (var _ci = 0; _ci < array_length(_categories); _ci++) {
            var _cx0 = _cat_x0 + _ci * _cat_w;
            var _cx1 = _cx0 + _cat_w;
            var _cat_active = (_categories[_ci].id == recipe_category);
            var _bx0 = _cx0 + _cat_gap / 2;
            var _bx1 = _cx1 - _cat_gap / 2;
            draw_set_color(_cat_active ? make_color_rgb(250, 241, 226) : _cell_fill);
            draw_roundrect_ext(_bx0, _cat_y0, _bx1, _cat_y1, _cat_corner, _cat_corner, false);
            draw_set_color(_cat_active ? make_color_rgb(172, 104, 55) : _cell_line);
            draw_roundrect_ext(_bx0, _cat_y0, _bx1, _cat_y1, _cat_corner, _cat_corner, true);

            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_cat_active ? make_color_rgb(60, 35, 10) : make_color_rgb(120, 95, 65));
            draw_text((_cx0 + _cx1) / 2, (_cat_y0 + _cat_y1) / 2, _categories[_ci].name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Сетка рецептов 4x4 ---
        var _grid_cols = 4;
        var _grid_rows = 4;
        var _slot_size = ui_rgrid[2];
        var _grid_gap  = ui_rgrid[3];
        var _grid_x    = book_x + ui_rgrid[0];
        var _grid_y    = book_y + ui_rgrid[1];

        var _cat_recipes = [];
        for (var _ri = 0; _ri < array_length(_all_recipes); _ri++) {
            if (_all_recipes[_ri].category == recipe_category && _all_recipes[_ri].unlocked) {
                array_push(_cat_recipes, _all_recipes[_ri]);
            }
        }

        for (var _row = 0; _row < _grid_rows; _row++) {
            for (var _col = 0; _col < _grid_cols; _col++) {
                var _idx = _row * _grid_cols + _col;
                var _sx = _grid_x + _col * (_slot_size + _grid_gap);
                var _sy = _grid_y + _row * (_slot_size + _grid_gap);
                var _has_recipe = (_idx < array_length(_cat_recipes));
                var _is_sel_slot = _has_recipe && (_cat_recipes[_idx].id == selected_recipe);

                draw_set_color(_is_sel_slot ? make_color_rgb(250, 241, 226) : _cell_fill);
                draw_roundrect_ext(_sx, _sy, _sx + _slot_size, _sy + _slot_size, 6, 6, false);
                draw_set_color(_is_sel_slot ? make_color_rgb(172, 104, 55) : _cell_line);
                draw_roundrect_ext(_sx, _sy, _sx + _slot_size, _sy + _slot_size, 6, 6, true);

                if (_has_recipe) {
                    var _rc  = _cat_recipes[_idx];
                    var _icx = _sx + _slot_size / 2;
                    var _icy = _sy + _slot_size / 2;

                    if (sprite_exists(_rc.icon)) {
                        var _iw  = sprite_get_width(_rc.icon);
                        var _ih  = sprite_get_height(_rc.icon);
                        var _pad = 8;
                        var _sc  = min((_slot_size - _pad) / _iw, (_slot_size - _pad) / _ih);
                        var _dw  = _iw * _sc;
                        var _dh  = _ih * _sc;
                        draw_sprite_stretched_ext(_rc.icon, 0, _icx - _dw / 2, _icy - _dh / 2, _dw, _dh, c_white, 1);
                    } else {
                        draw_set_color(make_color_rgb(200, 170, 120));
                        draw_circle(_icx, _icy, _slot_size * 0.32, false);
                    }
                }
            }
        }

        // --- Правая страница: картинка блюда на белом листе + ингредиенты под ним (2 колонки по 3 строки) ---
        var _sel_r = undefined;
        if (selected_recipe != "") {
            for (var _li = 0; _li < array_length(_all_recipes); _li++) {
                if (_all_recipes[_li].id == selected_recipe) { _sel_r = _all_recipes[_li]; break; }
            }
        }

        if (_sel_r != undefined) {
            var _img_y0 = _sh_y0 + 28;     // ниже закладки
            var _img_y1 = _sh_y1 - 6;
            var _rp_w   = _sh_x1 - _sh_x0;
            var _img_cx = _sh_cx;
            draw_set_font(fnt_dialog_ru_bold);
            var _cap_h  = string_height(_sel_r.name) + 6;
            var _img_cy = (_img_y0 + _img_y1 - _cap_h) / 2;

            if (sprite_exists(_sel_r.image)) {
                var _iw2  = sprite_get_width(_sel_r.image);
                var _ih2  = sprite_get_height(_sel_r.image);
                var _pad2 = 24;
                var _sc2  = min((_rp_w - _pad2) / _iw2, (_img_y1 - _img_y0 - _cap_h - 4) / _ih2);
                var _dw2  = _iw2 * _sc2;
                var _dh2  = _ih2 * _sc2;
                draw_sprite_stretched_ext(_sel_r.image, 0, _img_cx - _dw2 / 2, _img_cy - _dh2 / 2, _dw2, _dh2, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(200, 170, 120));
                draw_circle(_img_cx, _img_cy, (_img_y1 - _img_y0 - _cap_h) * 0.4, false);
            }

            draw_set_font(fnt_dialog_ru_bold);
            draw_set_halign(fa_center);
            draw_set_valign(fa_bottom);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(_img_cx, _img_y1, _sel_r.name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            // Ингредиенты: две ячейки под белым листом, в каждой до 3 строк (иконка | название | количество)
            var _lw    = ui_low[2] - ui_low[0];
            var _box_w = (_lw - 16) / 2;
            var _row_h = (ui_low[3] - ui_low[1] - 8) / 3;
            for (var _bi2 = 0; _bi2 < 2; _bi2++) {
                var _bx = book_x + ui_low[0] + _bi2 * (_box_w + 16);
                draw_set_color(_cell_fill);
                draw_roundrect_ext(_bx, book_y + ui_low[1], _bx + _box_w, book_y + ui_low[3], 6, 6, false);
                draw_set_color(_cell_line);
                draw_roundrect_ext(_bx, book_y + ui_low[1], _bx + _box_w, book_y + ui_low[3], 6, 6, true);
            }
            var _icon_sz = 10;
            for (var _gi = 0; _gi < array_length(_sel_r.ingredients) && _gi < 6; _gi++) {
                var _ing = _sel_r.ingredients[_gi];
                var _bx  = book_x + ui_low[0] + (_gi div 3) * (_box_w + 16);
                var _gcy = book_y + ui_low[1] + 4 + (_gi mod 3) * _row_h + _row_h / 2;
                var _gix = _bx + 16;

                if (sprite_exists(_ing.icon)) {
                    var _iiw = sprite_get_width(_ing.icon);
                    var _iih = sprite_get_height(_ing.icon);
                    var _isc = min((_icon_sz * 2) / _iiw, (_icon_sz * 2) / _iih);
                    var _idw = _iiw * _isc;
                    var _idh = _iih * _isc;
                    draw_sprite_stretched_ext(_ing.icon, 0, _gix - _idw / 2, _gcy - _idh / 2, _idw, _idh, c_white, 1);
                } else {
                    draw_set_color(_ing.color);
                    draw_circle(_gix, _gcy, _icon_sz * 0.8, false);
                }

                draw_set_font(fnt_ui);
                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_gix + 14, _gcy, _ing.name);
                var _amt = variable_struct_exists(_ing, "amount") ? _ing.amount : 1;
                draw_set_halign(fa_right);
                draw_text(_bx + _box_w - 8, _gcy, string(_amt) + " шт");
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        } else {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(_sh_cx, _sh_cy + 12, "Выбери рецепт\nиз списка");
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
