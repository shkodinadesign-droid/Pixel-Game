// ===== DIARY DRAW GUI =====

var bs = book_scale; // короткий псевдоним

draw_set_alpha(1);

// Затемнение фона
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Фон книги — растягиваем в область book_w x book_h (иконки вкладок уже нарисованы внутри спрайта)
// Вкладка "Рецепты" использует отдельную подложку с уже нарисованными сеткой/таблицей
var _bg_spr = (current_tab == 2) ? spr_diary_bg_recipes : spr_diary_bg;
draw_sprite_stretched_ext(_bg_spr, 0, book_x, book_y, book_w, book_h, c_white, 1);

// Координаты вкладок внутри спрайта (в исходных пикселях 824x453) — подсветка активной/замок поверх арта
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
var _tab_corner = round(4 * bs);

for (var i = 0; i < 7; i++) {
    var tx1 = book_x + _tab_local[i][0] * _tab_sx;
    var ty1 = book_y + _tab_local[i][1] * _tab_sy;
    var tx2 = book_x + _tab_local[i][2] * _tab_sx;
    var ty2 = book_y + _tab_local[i][3] * _tab_sy;

    // Подсветка активной вкладки
    if (i == current_tab) {
        draw_set_alpha(0.35);
        draw_set_color(make_color_rgb(255, 250, 230));
        draw_roundrect_ext(tx1, ty1, tx2, ty2, _tab_corner, _tab_corner, false);
        draw_set_alpha(1);
    }
}

// Кнопка закрытия (зелёный крестик) — верхний правый угол книги
var _close_cx = book_x + 798 * _tab_sx;
var _close_cy = book_y + 16  * _tab_sy;
var _close_r  = round(10 * bs);
draw_set_color(make_color_rgb(70, 160, 90));
draw_circle(_close_cx, _close_cy, _close_r, false);
draw_set_color(make_color_rgb(40, 110, 60));
draw_circle(_close_cx, _close_cy, _close_r, true);
draw_set_color(c_white);
var _cross_r = _close_r * 0.45;
draw_line_width(_close_cx - _cross_r, _close_cy - _cross_r, _close_cx + _cross_r, _close_cy + _cross_r, round(2 * bs));
draw_line_width(_close_cx - _cross_r, _close_cy + _cross_r, _close_cx + _cross_r, _close_cy - _cross_r, round(2 * bs));

// Заголовок текущей вкладки (вкладка "Задания" рисует свой крупный заголовок сама, ниже)
// Отступ слева выровнен по левому краю ячеек этой вкладки (у "Рецептов" сетка начинается левее content_x)
if (current_tab != 0) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(80, 50, 20));
    var _title_x = (current_tab == 2) ? (book_x + 128 * (book_w / 824)) : (book_x + round(60 * bs));
    draw_text(_title_x, book_y + round(26 * bs), tab_names[current_tab]);
}

// Контент вкладки
var content_x = book_x + round(60 * bs);
var content_y = book_y + round(60 * bs);

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
        var slot_size = round(38 * bs);  // ~48
        var slot_gap  = round(4  * bs);  // ~5
        var grid_cols = 5;
        var grid_rows = 4;
        var grid_x    = book_x + round(60 * bs);
        var grid_y    = book_y + round(52 * bs);
        var _slot_corner = round(4 * bs);

        // --- Сетка слотов ---
        for (var _row = 0; _row < grid_rows; _row++) {
            for (var _col = 0; _col < grid_cols; _col++) {
                var _idx = _row * grid_cols + _col;
                var _sx  = grid_x + _col * (slot_size + slot_gap);
                var _sy  = grid_y + _row * (slot_size + slot_gap);

                var _is_sel = (_idx == selected_item);
                draw_set_color(_is_sel ? make_color_rgb(220, 195, 155) : make_color_rgb(200, 175, 140));
                draw_roundrect_ext(_sx, _sy, _sx + slot_size, _sy + slot_size, _slot_corner, _slot_corner, false);
                draw_set_color(_is_sel ? make_color_rgb(139, 90, 43) : make_color_rgb(160, 120, 80));
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

        // --- Правая страница — карточка предмета ---
        var detail_x = book_x + round(288 * bs);
        var detail_y = book_y + round(20  * bs);
        var detail_w = book_w - round(288 * bs) - round(20 * bs);
        var detail_h = book_h - round(20  * bs) - round(38 * bs);

        if (selected_item >= 0 && selected_item < inv_count
            && inv_items[selected_item][2] > 0) {

            var _iname = inv_items[selected_item][3];
            var _idesc = inv_items[selected_item][4];
            var _iqty2 = inv_items[selected_item][2];

            // Рамка карточки
            draw_set_alpha(0.93);
            draw_set_color(make_color_rgb(250, 242, 220));
            draw_roundrect_ext(detail_x, detail_y,
                detail_x + detail_w, detail_y + detail_h, 6, 6, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_roundrect_ext(detail_x, detail_y,
                detail_x + detail_w, detail_y + detail_h, 6, 6, true);

            // Заголовок (жирный)
            draw_set_font(fnt_ui);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(detail_x + 12, detail_y + 12, _iname);

            // Разделитель
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(detail_x + 10, detail_y + 34,
                      detail_x + detail_w - 10, detail_y + 34);

            // Описание (обычный шрифт, с переносом по ширине карточки)
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(detail_x + 12, detail_y + 42, _idesc, -1, detail_w - 22);

            // Количество — внизу справа
            draw_set_halign(fa_right);
            draw_set_color(make_color_rgb(139, 90, 43));
            draw_text(detail_x + detail_w - 10, detail_y + detail_h - 16,
                      "Кол-во: " + string(_iqty2));
            draw_set_halign(fa_left);

        } else {
            // Подсказка — по центру правой страницы, на уровне сетки
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_top);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(detail_x + detail_w / 2, detail_y,
                      "Выбери предмет\nиз инвентаря");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        break;

    case 0: // Задания
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // Заголовок вкладки — на одной линии с заголовками остальных вкладок
        var _tab0_title_y = book_y + round(26 * bs);
        draw_set_font(fnt_dialog_ru_bold);
        draw_set_color(make_color_rgb(70, 40, 15));
        draw_text_transformed(content_x, _tab0_title_y, "Задания", 1.15, 1.15, 0);

        var _q_list_w = round(205 * bs);
        var _q_rows_y = book_y + round(52 * bs);
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
        // Белый листочек на спрайте книги (824x453): x 457-735, y 77-356 — замерено по пикселям арта
        var _qd_sx = book_w / 824;
        var _qd_sy = book_h / 453;
        var _qd_x  = book_x + 471 * _qd_sx;
        var _qd_y  = book_y + 108 * _qd_sy;
        var _qd_w  = (721 - 471) * _qd_sx;

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
            draw_line(_qd_x, _qd_y + 22 * _qd_sy, _qd_x + _qd_w, _qd_y + 22 * _qd_sy);

            draw_set_font(fnt_ui);
            draw_set_color(c_black);
            draw_text_ext(_qd_x, _qd_y + 32 * _qd_sy, _sel_q.desc, round(18 * bs), _qd_w);
        } else {
            // Центр белого листочка целиком (457-735, 77-356 в исходных пикселях арта)
            var _qd_cx = book_x + 596 * _qd_sx;
            var _qd_cy = book_y + 216 * _qd_sy;
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
        // Координаты замерены по пикселям подложки spr_diary_bg_recipes (824x453)
        var _rsx = book_w / 824;
        var _rsy = book_h / 453;
        var _all_recipes = diary_get_recipe_list();
        var _categories  = diary_get_recipe_categories();

        // --- Вкладки-категории (левая страница, x 128-369, y 64-96) ---
        var _cat_x0 = book_x + 128 * _rsx;
        var _cat_x1 = book_x + 369 * _rsx;
        var _cat_y0 = book_y + 64  * _rsy;
        var _cat_y1 = book_y + 96  * _rsy;
        var _cat_w  = (_cat_x1 - _cat_x0) / array_length(_categories);

        for (var _ci = 0; _ci < array_length(_categories); _ci++) {
            var _cx0 = _cat_x0 + _ci * _cat_w;
            var _cx1 = _cx0 + _cat_w;
            var _cat_active = (_categories[_ci].id == recipe_category);

            if (_cat_active) {
                draw_set_alpha(0.35);
                draw_set_color(make_color_rgb(255, 250, 230));
                draw_rectangle(_cx0, _cat_y0, _cx1, _cat_y1, false);
                draw_set_alpha(1);
            }

            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(_cat_active ? make_color_rgb(60, 35, 10) : make_color_rgb(120, 95, 65));
            draw_text((_cx0 + _cx1) / 2, (_cat_y0 + _cat_y1) / 2, _categories[_ci].name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Сетка рецептов 4x4 (левая страница, x 128-369, y 128-369) ---
        var _grid_cols = 4;
        var _grid_rows = 4;
        var _grid_gap  = 15 * _rsx;
        var _slot_size = ((369 - 128) * _rsx - (_grid_cols - 1) * _grid_gap) / _grid_cols;
        var _grid_x    = book_x + 128 * _rsx;
        var _grid_y    = book_y + 128 * _rsy;
        var _icon_area_h = _slot_size * 0.62;

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

                if (_is_sel_slot) {
                    draw_set_alpha(0.35);
                    draw_set_color(make_color_rgb(255, 250, 230));
                    draw_rectangle(_sx, _sy, _sx + _slot_size, _sy + _slot_size, false);
                    draw_set_alpha(1);
                }

                if (_has_recipe) {
                    var _rc  = _cat_recipes[_idx];
                    var _icx = _sx + _slot_size / 2;
                    var _icy = _sy + _icon_area_h / 2;

                    if (sprite_exists(_rc.icon)) {
                        var _iw  = sprite_get_width(_rc.icon);
                        var _ih  = sprite_get_height(_rc.icon);
                        var _pad = 6 * _rsx;
                        var _sc  = min((_slot_size - _pad) / _iw, (_icon_area_h - _pad) / _ih);
                        var _dw  = _iw * _sc;
                        var _dh  = _ih * _sc;
                        draw_sprite_stretched_ext(_rc.icon, 0, _icx - _dw / 2, _icy - _dh / 2, _dw, _dh, c_white, 1);
                    } else {
                        draw_set_color(make_color_rgb(200, 170, 120));
                        draw_circle(_icx, _icy, _icon_area_h * 0.32, false);
                    }

                    draw_set_font(fnt_ui);
                    draw_set_halign(fa_center);
                    draw_set_valign(fa_top);
                    draw_set_color(make_color_rgb(70, 45, 20));
                    draw_text_ext(_sx + _slot_size / 2, _sy + _icon_area_h + 2 * _rsy, _rc.name, -1, _slot_size - 4 * _rsx);
                    draw_set_halign(fa_left);
                    draw_set_valign(fa_top);
                }
            }
        }

        if (array_length(_cat_recipes) == 0) {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(170, 145, 115));
            draw_text_ext(_grid_x + (_slot_size + _grid_gap) * 2 - _grid_gap / 2,
                          _grid_y + (_slot_size + _grid_gap) * 2 - _grid_gap / 2,
                          "Рецептов этой\nкатегории пока нет", -1, (369 - 128) * _rsx - 10 * _rsx);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        // --- Правая страница: картинка блюда (x 449-736, y 65-162) + таблица ингредиентов (y 191-384, 6 строк) ---
        var _rp_x0 = book_x + 449 * _rsx;
        var _rp_x1 = book_x + 736 * _rsx;
        var _rp_w  = _rp_x1 - _rp_x0;

        var _sel_r = undefined;
        if (selected_recipe != "") {
            for (var _li = 0; _li < array_length(_all_recipes); _li++) {
                if (_all_recipes[_li].id == selected_recipe) { _sel_r = _all_recipes[_li]; break; }
            }
        }

        if (_sel_r != undefined) {
            // Картинка блюда внутри прямоугольника, уже нарисованного на подложке
            var _img_y0 = book_y + 65  * _rsy;
            var _img_y1 = book_y + 162 * _rsy;
            var _img_cx = _rp_x0 + _rp_w / 2;
            var _img_cy = (_img_y0 + _img_y1) / 2;

            if (sprite_exists(_sel_r.image)) {
                var _iw2  = sprite_get_width(_sel_r.image);
                var _ih2  = sprite_get_height(_sel_r.image);
                var _pad2 = 14 * _rsx;
                var _sc2  = min((_rp_w - _pad2) / _iw2, (_img_y1 - _img_y0 - _pad2) / _ih2);
                var _dw2  = _iw2 * _sc2;
                var _dh2  = _ih2 * _sc2;
                draw_sprite_stretched_ext(_sel_r.image, 0, _img_cx - _dw2 / 2, _img_cy - _dh2 / 2, _dw2, _dh2, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(200, 170, 120));
                draw_circle(_img_cx, _img_cy, min(_rp_w, _img_y1 - _img_y0) * 0.32, false);
            }

            // Название крупным шрифтом поверх картинки снизу
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_bottom);
            draw_set_color(make_color_rgb(70, 35, 5));
            draw_text(_img_cx, _img_y1 - 4 * _rsy, _sel_r.name);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);

            // Таблица ингредиентов: колонка иконки (449-481) + колонка названия (482-624), 6 строк (191-384)
            var _tbl_icon_cx = book_x + ((449 + 481) / 2) * _rsx;
            var _tbl_name_x  = book_x + 486 * _rsx;
            var _tbl_y0      = book_y + 191 * _rsy;
            var _tbl_row_h   = (384 - 191) * _rsy / 6;
            var _icon_sz     = 11 * _rsx;

            for (var _gi = 0; _gi < array_length(_sel_r.ingredients) && _gi < 6; _gi++) {
                var _ing = _sel_r.ingredients[_gi];
                var _gcy = _tbl_y0 + _gi * _tbl_row_h + _tbl_row_h / 2;

                if (sprite_exists(_ing.icon)) {
                    var _iiw = sprite_get_width(_ing.icon);
                    var _iih = sprite_get_height(_ing.icon);
                    var _isc = min((_icon_sz * 2) / _iiw, (_icon_sz * 2) / _iih);
                    var _idw = _iiw * _isc;
                    var _idh = _iih * _isc;
                    draw_sprite_stretched_ext(_ing.icon, 0, _tbl_icon_cx - _idw / 2, _gcy - _idh / 2, _idw, _idh, c_white, 1);
                } else {
                    draw_set_color(_ing.color);
                    draw_circle(_tbl_icon_cx, _gcy, _icon_sz, false);
                }

                draw_set_font(fnt_ui);
                draw_set_halign(fa_left);
                draw_set_valign(fa_middle);
                draw_set_color(make_color_rgb(55, 35, 15));
                draw_text(_tbl_name_x, _gcy, _ing.name);
                draw_set_halign(fa_left);
                draw_set_valign(fa_top);
            }
        } else {
            var _rd_cx = _rp_x0 + _rp_w / 2;
            var _rd_cy = book_y + 113 * _rsy;
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(_rd_cx, _rd_cy, "Выбери рецепт\nиз списка");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
        break;
    case 5: // Дружба
        draw_set_font(fnt_ui);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(content_x, content_y, "Бабушка Мэгги");

        // Кекс — появляется только после того как Мэгги привела котика
        if (!variable_global_exists("kitten_arrived")) global.kitten_arrived = false;
        if (global.kitten_arrived) {
            var _ky = content_y + 32;
            // Иконка сердечко (примитивами — символ ♥ не поддерживается шрифтом)
            draw_set_color(make_color_rgb(255, 80, 120));
            var _hx2 = content_x + 6;
            var _hy2 = _ky + 6;
            draw_circle(_hx2 - 3, _hy2 - 2, 4, false);
            draw_circle(_hx2 + 3, _hy2 - 2, 4, false);
            draw_triangle(_hx2 - 7, _hy2 - 1, _hx2 + 7, _hy2 - 1, _hx2, _hy2 + 7, false);
            // Имя и описание
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(content_x + 20, _ky, "Кекс");
            draw_set_color(make_color_rgb(120, 80, 40));
            draw_text(content_x + 20, _ky + 20, "Мой любимый друг");
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
