// ===== DIARY DRAW GUI =====

var bs = book_scale; // короткий псевдоним

draw_set_alpha(1);

// Затемнение фона
draw_set_color(c_black);
draw_set_alpha(0.5);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// Фон книги — растягиваем в область book_w x book_h (иконки вкладок уже нарисованы внутри спрайта)
draw_sprite_stretched_ext(spr_diary_bg, 0, book_x, book_y, book_w, book_h, c_white, 1);

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
var _recipes_unlocked = variable_global_exists("justin_bakery_intro_done") && global.justin_bakery_intro_done;

for (var i = 0; i < 7; i++) {
    var tx1 = book_x + _tab_local[i][0] * _tab_sx;
    var ty1 = book_y + _tab_local[i][1] * _tab_sy;
    var tx2 = book_x + _tab_local[i][2] * _tab_sx;
    var ty2 = book_y + _tab_local[i][3] * _tab_sy;

    var _locked = (i == 2 && !_recipes_unlocked);

    // Подсветка активной вкладки
    if (i == current_tab && !_locked) {
        draw_set_alpha(0.35);
        draw_set_color(make_color_rgb(255, 250, 230));
        draw_roundrect_ext(tx1, ty1, tx2, ty2, _tab_corner, _tab_corner, false);
        draw_set_alpha(1);
    }

    // Затемнение + замок поверх заблокированной вкладки
    if (_locked) {
        draw_set_alpha(0.55);
        draw_set_color(make_color_rgb(60, 50, 45));
        draw_roundrect_ext(tx1, ty1, tx2, ty2, _tab_corner, _tab_corner, false);
        draw_set_alpha(1);

        var _lx = (tx1 + tx2) / 2;
        var _ly = (ty1 + ty2) / 2 + round(1 * bs);
        var _lw = round(7 * bs);
        var _lh = round(6 * bs);
        draw_set_color(make_color_rgb(230, 220, 210));
        draw_roundrect_ext(_lx - _lw / 2, _ly, _lx + _lw / 2, _ly + _lh, 2, 2, false);
        draw_ellipse(_lx - _lw / 3, _ly - _lh * 0.8, _lx + _lw / 3, _ly + 1, true);
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
if (current_tab != 0) {
    draw_set_font(fnt_ui);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(80, 50, 20));
    draw_text(book_x + round(40 * bs), book_y + round(20 * bs), tab_names[current_tab]);
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
        var grid_rows = 3;
        var grid_x    = book_x + round(60 * bs);
        var grid_y    = book_y + round(48 * bs);
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

        // Заголовок вкладки — крупный, жирный шрифт
        draw_set_font(fnt_dialog_ru_bold);
        draw_set_color(make_color_rgb(70, 40, 15));
        draw_text_transformed(content_x, content_y, "Задания", 1.15, 1.15, 0);

        var _q_list_w = round(205 * bs);
        var _q_rows_y = content_y + round(26 * bs);
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
        var _qd_y  = book_y + 91  * _qd_sy;
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

            draw_set_font(fnt_diary_hand);
            draw_set_color(c_black);
            draw_text_ext(_qd_x, _qd_y + 32 * _qd_sy, _sel_q.desc, round(20 * bs), _qd_w);
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
        if (!_recipes_unlocked) {
            draw_set_font(fnt_ui);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_set_color(make_color_rgb(160, 130, 100));
            draw_text(book_x + book_w / 2, book_y + book_h / 2, "Рецепты пока недоступны");
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
            break;
        }

        // --- Карточка рецепта: Картофельный пирог ---
        var _rec_x = content_x;
        var _rec_y = content_y;

        // Название
        draw_set_font(fnt_ui);
        draw_set_color(make_color_rgb(80, 50, 20));
        draw_text(_rec_x, _rec_y, "Картофельный пирог");

        // Разделитель
        draw_set_color(make_color_rgb(160, 120, 70));
        draw_line(_rec_x, _rec_y + round(22 * bs),
                  _rec_x + round(220 * bs), _rec_y + round(22 * bs));

        // Ингредиенты одной строкой
        draw_set_font(fnt_ui);
        draw_set_color(make_color_rgb(80, 55, 25));
        draw_text(_rec_x, _rec_y + round(30 * bs),
                  "Картофель, Молоко, Яйцо, Мука, Дрожжи");

        // Кнопка "Подробнее"
        var _pbtn_w = round(90 * bs);
        var _pbtn_h = round(22 * bs);
        var _pbtn_x = _rec_x;
        var _pbtn_y = _rec_y + round(56 * bs);
        var _pbtn_hover = (device_mouse_x_to_gui(0) >= _pbtn_x && device_mouse_x_to_gui(0) <= _pbtn_x + _pbtn_w &&
                           device_mouse_y_to_gui(0) >= _pbtn_y && device_mouse_y_to_gui(0) <= _pbtn_y + _pbtn_h);

        draw_set_color(recipe_detail_open
            ? make_color_rgb(100, 65, 25)
            : (_pbtn_hover ? make_color_rgb(120, 80, 35) : make_color_rgb(160, 115, 60)));
        draw_roundrect_ext(_pbtn_x, _pbtn_y, _pbtn_x + _pbtn_w, _pbtn_y + _pbtn_h, 4, 4, false);
        draw_set_color(make_color_rgb(230, 200, 155));
        draw_roundrect_ext(_pbtn_x, _pbtn_y, _pbtn_x + _pbtn_w, _pbtn_y + _pbtn_h, 4, 4, true);
        draw_set_font(fnt_ui);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_color(c_white);
        draw_text(_pbtn_x + _pbtn_w / 2, _pbtn_y + _pbtn_h / 2,
                  recipe_detail_open ? "Свернуть" : "Подробнее");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);

        // --- Рецепт кофе (после письма бабули) ---
        if (variable_global_exists("coffee_letter_read") && global.coffee_letter_read) {
            var _coffee_y = _pbtn_y + _pbtn_h + round(18 * bs);

            // Разделитель перед рецептом
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_rec_x, _coffee_y, _rec_x + round(220 * bs), _coffee_y);
            _coffee_y += round(10 * bs);

            // Название рецепта
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(_rec_x, _coffee_y, "Латте");

            // Линия под названием
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_rec_x, _coffee_y + round(22 * bs),
                      _rec_x + round(220 * bs), _coffee_y + round(22 * bs));

            // Ингредиенты
            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(80, 55, 25));
            draw_text(_rec_x, _coffee_y + round(30 * bs),
                      "Зерна кофе, Молоко, Сахар");
        }

        // --- Правая страница: детали рецепта ---
        if (recipe_detail_open) {
            var _det_x = book_x + round(288 * bs);
            var _det_y = book_y + round(20  * bs);
            var _det_w = book_w - round(288 * bs) - round(20 * bs);
            var _det_h = book_h - round(20  * bs) - round(38 * bs);

            draw_set_alpha(0.93);
            draw_set_color(make_color_rgb(250, 242, 220));
            draw_roundrect_ext(_det_x, _det_y, _det_x + _det_w, _det_y + _det_h, 6, 6, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_roundrect_ext(_det_x, _det_y, _det_x + _det_w, _det_y + _det_h, 6, 6, true);

            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(80, 50, 20));
            draw_text(_det_x + 12, _det_y + 12, "Картофельный пирог");
            draw_set_color(make_color_rgb(160, 120, 70));
            draw_line(_det_x + 10, _det_y + 34, _det_x + _det_w - 10, _det_y + 34);

            draw_set_font(fnt_ui);
            draw_set_color(make_color_rgb(55, 35, 15));
            draw_text_ext(_det_x + 12, _det_y + 42,
                "Любимый пирог Джастина по рецепту бабушки Сони." +
                "\n\nИнгредиенты:" +
                "\nКартофель x1, Молоко x1, Яйцо x1" +
                "\nМука x1, Дрожжи x1" +
                "\n\nПриготовить: подойди к рабочему столу в пекарне и нажми E.",
                -1, _det_w - 22);
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
